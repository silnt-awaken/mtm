#!/usr/bin/env node

/**
 * Test script to verify Solana integration for MTM
 * Tests wallet connection, token account setup, and transfer simulation
 */

import { Connection, PublicKey, Keypair } from '@solana/web3.js';
import { getAssociatedTokenAddress, getMint } from '@solana/spl-token';
import bs58 from 'bs58';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
const envFile = path.join(__dirname, '..', '.env');
let config = {};

if (fs.existsSync(envFile)) {
  const envContent = fs.readFileSync(envFile, 'utf8');
  envContent.split('\n').forEach(line => {
    const [key, value] = line.split('=');
    if (key && value) {
      config[key.trim()] = value.trim();
    }
  });
}

const SOLANA_RPC_URL = config.SOLANA_RPC_URL || 'https://api.devnet.solana.com';
const MTM_TOKEN_MINT = config.MTM_TOKEN_MINT;
const REWARD_WALLET_PRIVATE_KEY = config.REWARD_WALLET_PRIVATE_KEY;

const connection = new Connection(SOLANA_RPC_URL, 'confirmed');

async function testConnection() {
  console.log('🌐 Testing Solana connection...');
  console.log(`   RPC URL: ${SOLANA_RPC_URL}`);
  
  try {
    const version = await connection.getVersion();
    const slot = await connection.getSlot();
    
    console.log('✅ Connection successful!');
    console.log(`   Solana version: ${version['solana-core']}`);
    console.log(`   Current slot: ${slot}\n`);
    
    return true;
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
    return false;
  }
}

async function testRewardWallet() {
  console.log('🔑 Testing reward wallet...');
  
  if (!REWARD_WALLET_PRIVATE_KEY || REWARD_WALLET_PRIVATE_KEY === 'your_reward_wallet_private_key_here') {
    console.error('❌ REWARD_WALLET_PRIVATE_KEY not configured');
    console.log('   💡 Run: cd scripts && npm run setup-wallet\n');
    return null;
  }
  
  try {
    let wallet;
    
    // Try to decode private key
    if (REWARD_WALLET_PRIVATE_KEY.startsWith('[')) {
      // JSON array format
      const keyArray = JSON.parse(REWARD_WALLET_PRIVATE_KEY);
      wallet = Keypair.fromSecretKey(new Uint8Array(keyArray));
    } else {
      // Base58 format
      wallet = Keypair.fromSecretKey(bs58.decode(REWARD_WALLET_PRIVATE_KEY));
    }
    
    const publicKey = wallet.publicKey.toBase58();
    const balance = await connection.getBalance(wallet.publicKey);
    
    console.log('✅ Reward wallet loaded successfully!');
    console.log(`   Public Key: ${publicKey}`);
    console.log(`   SOL Balance: ${balance / 1000000000} SOL`);
    
    if (balance === 0) {
      console.log('   ⚠️  Wallet has no SOL for transaction fees');
      if (SOLANA_RPC_URL.includes('devnet')) {
        console.log('   💡 Run airdrop: solana airdrop 1 ' + publicKey + ' --url devnet');
      } else {
        console.log('   💡 Send SOL to this address for transaction fees');
      }
    }
    
    console.log('');
    return wallet;
  } catch (error) {
    console.error('❌ Failed to load reward wallet:', error.message);
    return null;
  }
}

async function testTokenMint() {
  console.log('🪙 Testing token mint...');
  
  if (!MTM_TOKEN_MINT || MTM_TOKEN_MINT === 'your_mtm_token_mint_address_here') {
    console.error('❌ MTM_TOKEN_MINT not configured');
    console.log('   💡 Set your token mint address in .env');
    console.log('   💡 For testing, you can create a test token on devnet\n');
    return null;
  }
  
  try {
    const mintPublicKey = new PublicKey(MTM_TOKEN_MINT);
    const mintInfo = await getMint(connection, mintPublicKey);
    
    console.log('✅ Token mint found!');
    console.log(`   Mint Address: ${MTM_TOKEN_MINT}`);
    console.log(`   Decimals: ${mintInfo.decimals}`);
    console.log(`   Supply: ${mintInfo.supply.toString()}`);
    console.log(`   Mint Authority: ${mintInfo.mintAuthority?.toBase58() || 'None'}`);
    console.log(`   Freeze Authority: ${mintInfo.freezeAuthority?.toBase58() || 'None'}\n`);
    
    return mintInfo;
  } catch (error) {
    console.error('❌ Failed to fetch mint info:', error.message);
    console.log('   💡 Check that MTM_TOKEN_MINT address is correct');
    console.log('   💡 Ensure you\'re using the right network (mainnet/devnet)\n');
    return null;
  }
}

async function testTokenAccount(wallet, mintInfo) {
  if (!wallet || !mintInfo) {
    return null;
  }
  
  console.log('💰 Testing reward wallet token account...');
  
  try {
    const mintPublicKey = new PublicKey(MTM_TOKEN_MINT);
    const associatedTokenAccount = await getAssociatedTokenAddress(
      mintPublicKey,
      wallet.publicKey
    );
    
    const accountInfo = await connection.getAccountInfo(associatedTokenAccount);
    
    console.log(`   Associated Token Account: ${associatedTokenAccount.toBase58()}`);
    
    if (!accountInfo) {
      console.log('   ❌ Token account does not exist');
      console.log('   💡 Create it with: spl-token create-account ' + MTM_TOKEN_MINT + ' --owner ' + wallet.publicKey.toBase58());
    } else {
      const balance = await connection.getTokenAccountBalance(associatedTokenAccount);
      const uiAmount = balance.value.uiAmount || 0;
      
      console.log('   ✅ Token account exists');
      console.log(`   Balance: ${uiAmount} MTM tokens`);
      
      if (uiAmount === 0) {
        console.log('   ⚠️  No MTM tokens to distribute as rewards');
        console.log('   💡 Mint tokens to this account or transfer from another wallet');
      }
    }
    
    console.log('');
    return { associatedTokenAccount, exists: !!accountInfo };
  } catch (error) {
    console.error('❌ Failed to check token account:', error.message);
    return null;
  }
}

async function simulateReward(wallet, tokenAccount) {
  if (!wallet || !tokenAccount?.exists) {
    console.log('⏭️  Skipping reward simulation (wallet or token account not ready)\n');
    return;
  }
  
  console.log('🎁 Simulating reward transfer...');
  
  try {
    // Simulate a test user address
    const testUser = Keypair.generate();
    const testUserTokenAccount = await getAssociatedTokenAddress(
      new PublicKey(MTM_TOKEN_MINT),
      testUser.publicKey
    );
    
    console.log(`   Test user: ${testUser.publicKey.toBase58()}`);
    console.log(`   Test user token account: ${testUserTokenAccount.toBase58()}`);
    console.log('   💡 This is just a simulation - no actual transfer will occur');
    console.log('   💡 The Firebase function will handle real transfers\n');
    
    return true;
  } catch (error) {
    console.error('❌ Simulation failed:', error.message);
    return false;
  }
}

async function main() {
  console.log('🎵 MTM Solana Integration Test\n');
  console.log('This script will test:');
  console.log('1. Solana RPC connection');
  console.log('2. Reward wallet configuration');
  console.log('3. Token mint validation');
  console.log('4. Token account setup');
  console.log('5. Reward simulation\n');
  
  // Test connection
  const connectionOk = await testConnection();
  if (!connectionOk) {
    console.log('❌ Cannot proceed without Solana connection');
    process.exit(1);
  }
  
  // Test reward wallet
  const wallet = await testRewardWallet();
  
  // Test token mint
  const mintInfo = await testTokenMint();
  
  // Test token account
  const tokenAccount = await testTokenAccount(wallet, mintInfo);
  
  // Simulate reward
  await simulateReward(wallet, tokenAccount);
  
  // Summary
  console.log('📊 Test Summary:');
  console.log(`   Solana Connection: ${connectionOk ? '✅' : '❌'}`);
  console.log(`   Reward Wallet: ${wallet ? '✅' : '❌'}`);
  console.log(`   Token Mint: ${mintInfo ? '✅' : '❌'}`);
  console.log(`   Token Account: ${tokenAccount?.exists ? '✅' : '❌'}`);
  
  const allGood = connectionOk && wallet && mintInfo && tokenAccount?.exists;
  
  if (allGood) {
    console.log('\n🎉 All tests passed! Your Solana integration is ready.');
    console.log('💡 Deploy your Firebase functions to start distributing rewards.');
  } else {
    console.log('\n⚠️  Some tests failed. Please address the issues above.');
    console.log('💡 Use the suggested commands to fix any problems.');
  }
}

// Handle script execution
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(error => {
    console.error('❌ Test failed:', error);
    process.exit(1);
  });
}