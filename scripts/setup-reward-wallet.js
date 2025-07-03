#!/usr/bin/env node

/**
 * Utility script to generate and configure a Solana reward wallet for MTM
 * This script helps set up the reward wallet that will distribute SPL tokens to users
 */

import { Keypair, Connection, PublicKey } from '@solana/web3.js';
import { getAssociatedTokenAddress, createAssociatedTokenAccountInstruction } from '@solana/spl-token';
import fs from 'fs';
import path from 'path';
import bs58 from 'bs58';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SOLANA_RPC_URL = process.env.SOLANA_RPC_URL || 'https://api.devnet.solana.com';
const connection = new Connection(SOLANA_RPC_URL, 'confirmed');

async function generateRewardWallet() {
  console.log('🔑 Generating new reward wallet...\n');
  
  // Generate new keypair
  const wallet = Keypair.generate();
  const publicKey = wallet.publicKey.toBase58();
  const privateKeyBytes = wallet.secretKey;
  const privateKeyBase58 = bs58.encode(privateKeyBytes);
  const privateKeyArray = Array.from(privateKeyBytes);
  
  console.log('✅ Reward wallet generated successfully!');
  console.log('📋 Wallet Details:');
  console.log(`   Public Key:  ${publicKey}`);
  console.log(`   Network:     ${SOLANA_RPC_URL.includes('devnet') ? 'Devnet' : 'Mainnet'}\n`);
  
  // Save wallet file
  const walletDir = path.join(__dirname, '..', 'wallets');
  if (!fs.existsSync(walletDir)) {
    fs.mkdirSync(walletDir, { recursive: true });
  }
  
  const walletFile = path.join(walletDir, 'reward-wallet.json');
  fs.writeFileSync(walletFile, JSON.stringify(privateKeyArray, null, 2));
  console.log(`💾 Wallet saved to: ${walletFile}`);
  
  // Update .env file
  const envFile = path.join(__dirname, '..', '.env');
  const envExampleFile = path.join(__dirname, '..', '.env.example');
  
  let envContent = '';
  if (fs.existsSync(envFile)) {
    envContent = fs.readFileSync(envFile, 'utf8');
  } else if (fs.existsSync(envExampleFile)) {
    envContent = fs.readFileSync(envExampleFile, 'utf8');
  }
  
  // Update or add REWARD_WALLET_PRIVATE_KEY
  if (envContent.includes('REWARD_WALLET_PRIVATE_KEY=')) {
    envContent = envContent.replace(
      /REWARD_WALLET_PRIVATE_KEY=.*/,
      `REWARD_WALLET_PRIVATE_KEY=${privateKeyBase58}`
    );
  } else {
    envContent += `\nREWARD_WALLET_PRIVATE_KEY=${privateKeyBase58}\n`;
  }
  
  fs.writeFileSync(envFile, envContent);
  console.log(`📝 Updated .env file with reward wallet private key\n`);
  
  return { wallet, publicKey, privateKeyBase58 };
}

async function checkTokenAccount(walletPublicKey, tokenMint) {
  try {
    const mintPublicKey = new PublicKey(tokenMint);
    const walletPubKey = new PublicKey(walletPublicKey);
    
    const associatedTokenAccount = await getAssociatedTokenAddress(
      mintPublicKey,
      walletPubKey
    );
    
    const accountInfo = await connection.getAccountInfo(associatedTokenAccount);
    
    console.log('🪙 Token Account Status:');
    console.log(`   Associated Token Account: ${associatedTokenAccount.toBase58()}`);
    console.log(`   Account Exists: ${accountInfo ? '✅ Yes' : '❌ No'}`);
    
    if (!accountInfo) {
      console.log('   ⚠️  You need to create the associated token account before receiving tokens');
      console.log('   💡 This will be automatically created on first transfer');
    } else {
      const balance = await connection.getTokenAccountBalance(associatedTokenAccount);
      console.log(`   Current Balance: ${balance.value.uiAmount || 0} tokens`);
    }
    
    return { associatedTokenAccount, exists: !!accountInfo };
  } catch (error) {
    console.error('❌ Error checking token account:', error.message);
    return null;
  }
}

async function fundWallet(publicKey) {
  if (!SOLANA_RPC_URL.includes('devnet')) {
    console.log('💰 Funding:');
    console.log('   ⚠️  On mainnet, you need to manually fund this wallet with SOL');
    console.log('   💡 Send SOL to the public key above for transaction fees');
    return;
  }
  
  try {
    console.log('💰 Requesting devnet airdrop...');
    const pubKey = new PublicKey(publicKey);
    const signature = await connection.requestAirdrop(pubKey, 1000000000); // 1 SOL
    await connection.confirmTransaction(signature);
    
    const balance = await connection.getBalance(pubKey);
    console.log(`✅ Airdrop successful! Balance: ${balance / 1000000000} SOL\n`);
  } catch (error) {
    console.error('❌ Airdrop failed:', error.message);
    console.log('💡 You may need to fund the wallet manually\n');
  }
}

async function main() {
  console.log('🎵 MTM Reward Wallet Setup\n');
  console.log('This script will:');
  console.log('1. Generate a new Solana keypair for reward distribution');
  console.log('2. Save the wallet configuration');
  console.log('3. Update your .env file');
  console.log('4. Check token account status (if MTM_TOKEN_MINT is set)');
  console.log('5. Fund the wallet (devnet only)\n');
  
  const args = process.argv.slice(2);
  const force = args.includes('--force');
  
  // Check if wallet already exists
  const envFile = path.join(__dirname, '..', '.env');
  if (fs.existsSync(envFile) && !force) {
    const envContent = fs.readFileSync(envFile, 'utf8');
    const match = envContent.match(/REWARD_WALLET_PRIVATE_KEY=(.+)/);
    
    if (match && match[1] && match[1] !== 'your_reward_wallet_private_key_here') {
      console.log('⚠️  Reward wallet already configured!');
      console.log('   Use --force to overwrite existing wallet\n');
      
      try {
        const privateKey = match[1];
        let wallet;
        
        // Try to decode existing key
        if (privateKey.startsWith('[')) {
          // JSON array format
          const keyArray = JSON.parse(privateKey);
          wallet = Keypair.fromSecretKey(new Uint8Array(keyArray));
        } else {
          // Base58 format
          wallet = Keypair.fromSecretKey(bs58.decode(privateKey));
        }
        
        console.log('📋 Current Wallet:');
        console.log(`   Public Key: ${wallet.publicKey.toBase58()}`);
        
        // Check balance
        const balance = await connection.getBalance(wallet.publicKey);
        console.log(`   SOL Balance: ${balance / 1000000000}\n`);
        
        // Check token account if mint is configured
        const mtmTokenMint = process.env.MTM_TOKEN_MINT;
        if (mtmTokenMint && mtmTokenMint !== 'your_mtm_token_mint_address_here') {
          await checkTokenAccount(wallet.publicKey.toBase58(), mtmTokenMint);
        }
        
        return;
      } catch (error) {
        console.log('❌ Error reading existing wallet, generating new one...\n');
      }
    }
  }
  
  // Generate new wallet
  const { wallet, publicKey } = await generateRewardWallet();
  
  // Fund wallet (devnet only)
  await fundWallet(publicKey);
  
  // Check token account if mint is configured
  const mtmTokenMint = process.env.MTM_TOKEN_MINT;
  if (mtmTokenMint && mtmTokenMint !== 'your_mtm_token_mint_address_here') {
    console.log('🪙 Checking token account for MTM tokens...\n');
    await checkTokenAccount(publicKey, mtmTokenMint);
  } else {
    console.log('💡 Set MTM_TOKEN_MINT in .env to check token account status');
  }
  
  console.log('\n✅ Setup complete!');
  console.log('\n📝 Next steps:');
  console.log('1. Set your MTM_TOKEN_MINT address in .env');
  console.log('2. Fund the wallet with SOL for transaction fees');
  console.log('3. Fund the wallet with MTM tokens to distribute as rewards');
  console.log('4. Deploy your Firebase functions');
  console.log('\n🚀 Your reward system is ready to go!');
}

// Handle script execution
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(error => {
    console.error('❌ Setup failed:', error);
    process.exit(1);
  });
}

export { generateRewardWallet, checkTokenAccount, fundWallet };