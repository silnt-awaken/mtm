import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import { onDocumentCreated, onDocumentWritten } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import admin from "firebase-admin";
import { Connection, PublicKey, Transaction, SystemProgram, LAMPORTS_PER_SOL, Keypair } from "@solana/web3.js";
import { createTransferInstruction, getAssociatedTokenAddress, TOKEN_PROGRAM_ID } from "@solana/spl-token";

admin.initializeApp();

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

// Solana configuration
const SOLANA_RPC_URL = process.env.SOLANA_RPC_URL || "https://api.mainnet-beta.solana.com";
const MTM_TOKEN_MINT = process.env.MTM_TOKEN_MINT || "YOUR_MTM_TOKEN_MINT_ADDRESS";
const REWARD_WALLET_PRIVATE_KEY = process.env.REWARD_WALLET_PRIVATE_KEY;

const connection = new Connection(SOLANA_RPC_URL, "confirmed");

// Initialize reward wallet
let rewardWallet = null;
let rewardTokenAccount = null;

if (REWARD_WALLET_PRIVATE_KEY) {
  try {
    // Parse private key (expecting base58 encoded string or Uint8Array)
    let privateKeyBytes;
    if (typeof REWARD_WALLET_PRIVATE_KEY === 'string') {
      // Try to parse as JSON array first, then as base58
      try {
        privateKeyBytes = new Uint8Array(JSON.parse(REWARD_WALLET_PRIVATE_KEY));
      } catch {
        // Assume it's base58 encoded
        const bs58 = require('bs58');
        privateKeyBytes = bs58.decode(REWARD_WALLET_PRIVATE_KEY);
      }
    } else {
      privateKeyBytes = new Uint8Array(REWARD_WALLET_PRIVATE_KEY);
    }
    
    rewardWallet = Keypair.fromSecretKey(privateKeyBytes);
    console.log(`Reward wallet initialized: ${rewardWallet.publicKey.toBase58()}`);
    
    // Initialize reward token account
    const mintPublicKey = new PublicKey(MTM_TOKEN_MINT);
    rewardTokenAccount = getAssociatedTokenAddress(
      mintPublicKey,
      rewardWallet.publicKey
    );
    
  } catch (error) {
    console.error('Failed to initialize reward wallet:', error);
  }
} else {
  console.warn('REWARD_WALLET_PRIVATE_KEY not configured - SPL token transfers will fail');
}

// Validate listen session and calculate rewards
export const validateListenSession = onCall(async (request) => {
  const { data, auth } = request;
  
  if (!auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }

  const { sessionData } = data;
  const userId = auth.uid;

  try {
    // Validate session data
    const isValid = await validateSessionData(sessionData, userId);
    
    if (!isValid.valid) {
      return { valid: false, reason: isValid.reason };
    }

    // Check for anti-bot patterns
    const isSuspicious = await checkSuspiciousActivity(userId, sessionData);
    
    if (isSuspicious) {
      return { valid: false, reason: "Suspicious activity detected" };
    }

    // Calculate reward amount
    const rewardAmount = calculateRewardAmount(sessionData);

    // Create reward transaction
    const rewardId = await createRewardTransaction(userId, sessionData, rewardAmount);

    return {
      valid: true,
      rewardAmount,
      rewardId,
    };
  } catch (error) {
    console.error("Error validating listen session:", error);
    throw new HttpsError("internal", "Failed to validate session");
  }
});

// Process pending rewards (batch SPL token transfers)
export const processRewards = onSchedule(
  {
    schedule: "every 10 minutes",
    timeZone: "America/New_York",
  },
  async () => {
    try {
      console.log("Processing pending rewards...");

      // Get pending reward transactions
      const pendingRewards = await db
        .collection("rewards")
        .where("status", "==", "pending")
        .where("type", "==", "reward")
        .limit(50) // Process in batches
        .get();

      if (pendingRewards.empty) {
        console.log("No pending rewards to process");
        return;
      }

      console.log(`Processing ${pendingRewards.size} pending rewards`);

      const batch = db.batch();
      const transferPromises = [];

      for (const doc of pendingRewards.docs) {
        const reward = doc.data();
        
        // Create SPL token transfer
        const transferPromise = transferSPLTokens(
          reward.toAddress,
          reward.amount,
          doc.id
        );
        
        transferPromises.push(transferPromise);

        // Update status to processing
        batch.update(doc.ref, {
          status: "processing",
          updatedAt: FieldValue.serverTimestamp(),
        });
      }

      // Update all to processing
      await batch.commit();

      // Execute transfers
      const results = await Promise.allSettled(transferPromises);

      // Update results
      const resultBatch = db.batch();
      
      results.forEach((result, index) => {
        const docRef = pendingRewards.docs[index].ref;
        
        if (result.status === "fulfilled") {
          resultBatch.update(docRef, {
            status: "completed",
            transactionSignature: result.value.signature,
            completedAt: FieldValue.serverTimestamp(),
          });
        } else {
          resultBatch.update(docRef, {
            status: "failed",
            failureReason: result.reason?.message || "Unknown error",
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      });

      await resultBatch.commit();
      
      const successful = results.filter(r => r.status === "fulfilled").length;
      const failed = results.filter(r => r.status === "rejected").length;
      
      console.log(`Rewards processed: ${successful} successful, ${failed} failed`);

    } catch (error) {
      console.error("Error processing rewards:", error);
    }
  }
);

// Auto-update user stats when rewards are completed
export const updateUserStatsOnReward = onDocumentWritten(
  { document: "rewards/{rewardId}" },
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();

    // Check if reward was just completed
    if (before?.status !== "completed" && after?.status === "completed") {
      const userId = after.userId;
      const amount = after.amount;

      try {
        // Update user stats
        await db.collection("users").doc(userId).update({
          totalRewards: FieldValue.increment(amount),
          "stats.rewardsEarned": FieldValue.increment(amount),
          updatedAt: FieldValue.serverTimestamp(),
        });

        console.log(`Updated user ${userId} stats with reward ${amount}`);
      } catch (error) {
        console.error("Error updating user stats:", error);
      }
    }
  }
);

// Clean up old listen sessions
export const cleanupOldSessions = onSchedule(
  {
    schedule: "0 2 * * *", // Daily at 2 AM
    timeZone: "America/New_York",
  },
  async () => {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const oldSessions = await db
        .collection("listen_sessions")
        .where("createdAt", "<", thirtyDaysAgo)
        .limit(500)
        .get();

      if (oldSessions.empty) {
        console.log("No old sessions to clean up");
        return;
      }

      const batch = db.batch();
      oldSessions.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`Cleaned up ${oldSessions.size} old sessions`);
    } catch (error) {
      console.error("Error cleaning up old sessions:", error);
    }
  }
);

// Get server timestamp
export const getServerTime = onRequest(async (req, res) => {
  res.json({ timestamp: Date.now() });
});

// Helper Functions

async function validateSessionData(sessionData, userId) {
  const { trackId, duration, volume, startTime, endTime } = sessionData;

  // Basic validation
  if (!trackId || !duration || volume === undefined || !startTime || !endTime) {
    return { valid: false, reason: "Missing required session data" };
  }

  // Duration validation
  if (duration < 30) { // Minimum 30 seconds
    return { valid: false, reason: "Listen duration too short" };
  }

  if (duration > 3600) { // Maximum 1 hour
    return { valid: false, reason: "Listen duration too long" };
  }

  // Volume validation
  if (volume < 0.1) { // Minimum 10% volume
    return { valid: false, reason: "Volume too low" };
  }

  // Time validation
  if (endTime <= startTime) {
    return { valid: false, reason: "Invalid time range" };
  }

  const calculatedDuration = Math.floor((endTime - startTime) / 1000);
  if (Math.abs(calculatedDuration - duration) > 5) { // 5 second tolerance
    return { valid: false, reason: "Duration mismatch" };
  }

  // Check if track exists
  const trackDoc = await db.collection("tracks").doc(trackId).get();
  if (!trackDoc.exists || !trackDoc.data()?.isActive) {
    return { valid: false, reason: "Invalid track" };
  }

  return { valid: true };
}

async function checkSuspiciousActivity(userId, sessionData) {
  const oneHourAgo = Date.now() - (60 * 60 * 1000);
  
  // Check recent sessions
  const recentSessions = await db
    .collection("listen_sessions")
    .where("userId", "==", userId)
    .where("startTime", ">", oneHourAgo)
    .get();

  // Too many sessions in one hour
  if (recentSessions.size > 60) {
    return true;
  }

  // Check for rapid successive sessions
  const sessions = recentSessions.docs
    .map(doc => doc.data())
    .sort((a, b) => b.endTime - a.endTime);

  for (let i = 1; i < sessions.length; i++) {
    const current = sessions[i];
    const previous = sessions[i - 1];
    const gap = (previous.startTime - current.endTime) / 1000;

    // Less than 5 seconds between tracks
    if (gap < 5) {
      return true;
    }
  }

  return false;
}

function calculateRewardAmount(sessionData) {
  const { duration, volume } = sessionData;
  let baseReward = 1000000; // 1 MTM token (6 decimals)

  // Duration-based multiplier
  let multiplier = 1.0;
  if (duration >= 240) { // 4+ minutes
    multiplier = 1.5;
  } else if (duration >= 120) { // 2+ minutes
    multiplier = 1.2;
  }

  // Volume-based multiplier
  if (volume >= 0.8) {
    multiplier *= 1.1;
  }

  return Math.floor(baseReward * multiplier);
}

async function createRewardTransaction(userId, sessionData, amount) {
  const { trackId } = sessionData;

  // Get user wallet address
  const userDoc = await db.collection("users").doc(userId).get();
  const walletAddress = userDoc.data()?.walletAddress;

  if (!walletAddress) {
    throw new Error("User has no wallet address");
  }

  // Create reward document
  const rewardData = {
    userId,
    type: "reward",
    status: "pending",
    tokenMint: MTM_TOKEN_MINT,
    amount,
    toAddress: walletAddress,
    reason: "listening",
    metadata: {
      trackId,
      sessionData,
    },
    createdAt: FieldValue.serverTimestamp(),
  };

  const rewardRef = await db.collection("rewards").add(rewardData);
  return rewardRef.id;
}

async function transferSPLTokens(toAddress, amount, rewardId) {
  if (!rewardWallet) {
    throw new Error("Reward wallet not configured");
  }

  try {
    const toPublicKey = new PublicKey(toAddress);
    const mintPublicKey = new PublicKey(MTM_TOKEN_MINT);
    
    // Get source token account (await the promise)
    const fromTokenAccount = await rewardTokenAccount;
    
    // Get destination associated token account
    const toTokenAccount = await getAssociatedTokenAddress(
      mintPublicKey,
      toPublicKey
    );

    // Check if destination token account exists, create if it doesn't
    const toAccountInfo = await connection.getAccountInfo(toTokenAccount);
    const transaction = new Transaction();
    
    if (!toAccountInfo) {
      // Create associated token account instruction
      const { createAssociatedTokenAccountInstruction } = require('@solana/spl-token');
      const createATAInstruction = createAssociatedTokenAccountInstruction(
        rewardWallet.publicKey, // Payer
        toTokenAccount,         // Associated token account
        toPublicKey,           // Owner
        mintPublicKey          // Mint
      );
      transaction.add(createATAInstruction);
    }

    // Create transfer instruction
    const transferInstruction = createTransferInstruction(
      fromTokenAccount,         // Source account
      toTokenAccount,          // Destination account
      rewardWallet.publicKey,  // Owner
      amount,
      [],
      TOKEN_PROGRAM_ID
    );
    
    transaction.add(transferInstruction);

    // Get recent blockhash
    const { blockhash } = await connection.getLatestBlockhash();
    transaction.recentBlockhash = blockhash;
    transaction.feePayer = rewardWallet.publicKey;
    
    // Sign and send transaction
    const signature = await connection.sendTransaction(transaction, [rewardWallet], {
      skipPreflight: false,
      preflightCommitment: "confirmed"
    });
    
    // Wait for confirmation
    await connection.confirmTransaction({
      signature,
      blockhash,
      lastValidBlockHeight: (await connection.getLatestBlockhash()).lastValidBlockHeight
    });

    console.log(`SPL token transfer completed: ${signature}`);
    
    return { signature, success: true };
  } catch (error) {
    console.error(`SPL token transfer failed for reward ${rewardId}:`, error);
    throw error;
  }
}