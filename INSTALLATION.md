# MTM Installation Guide 🚀

This guide will walk you through setting up MTM (Music That Matters) from scratch, including all blockchain and backend integrations.

## Prerequisites Checklist ✅

Before starting, ensure you have:

- [ ] **Flutter SDK 3.7+** - [Install Flutter](https://flutter.dev/docs/get-started/install)
- [ ] **Dart SDK 3.0+** - (included with Flutter)
- [ ] **Node.js 18+** - [Install Node.js](https://nodejs.org/)
- [ ] **Firebase CLI** - `npm install -g firebase-tools`
- [ ] **Solana CLI** - [Install Solana](https://docs.solana.com/cli/install-solana-cli-tools)
- [ ] **Git** - For version control

## Step-by-Step Setup 📋

### 1. Clone and Install Dependencies

```bash
# Clone the repository
git clone <your-mtm-repo>
cd mtm

# Install Flutter dependencies
flutter pub get

# Install Firebase Functions dependencies
cd functions
npm install
cd ..

# Install utility scripts dependencies
cd scripts
npm install
cd ..
```

### 2. Firebase Project Setup

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Create a project"
   - Name it "MTM" or similar
   - Enable Google Analytics (optional)

2. **Enable Required Services**:
   - **Firestore Database**: Click "Create database" → Start in test mode
   - **Authentication**: Enable Email/Password provider
   - **Cloud Functions**: Will be enabled when you deploy
   - **Analytics**: Optional but recommended

3. **Get Configuration**:
   - Project Settings → General → Your apps
   - Add Android app (optional): `com.example.mtm`
   - Add iOS app (optional): `com.example.mtm`
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 3. Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit the .env file with your settings
nano .env  # or use your preferred editor
```

Fill in your configuration:

```env
# Privy Configuration (get from https://privy.io)
PRIVY_APP_ID=your_privy_app_id_here
PRIVY_CLIENT_ID=your_privy_client_id_here

# Solana Configuration
SOLANA_NETWORK=devnet  # or mainnet-beta for production
SOLANA_RPC_URL=https://api.devnet.solana.com
MTM_TOKEN_MINT=your_mtm_token_mint_address_here

# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_APP_ID=your_firebase_app_id_here

# Reward Configuration (adjust as needed)
BASE_REWARD_AMOUNT=1000000
MINIMUM_LISTEN_DURATION=30
MAXIMUM_DAILY_LISTENS=500
MINIMUM_VOLUME=0.1

# Anti-Bot Configuration
MAX_LISTENS_PER_HOUR=60
MINIMUM_BREAK_BETWEEN_TRACKS=5
```

### 4. Solana Blockchain Setup

#### Option A: Automated Setup (Recommended)

```bash
cd scripts

# Generate reward wallet and configure environment
npm run setup-wallet

# Test the Solana integration
npm run test-solana
```

#### Option B: Manual Setup

```bash
# Generate reward wallet
solana-keygen new --outfile wallets/reward-wallet.json

# Get the public key (you'll need this for funding)
REWARD_WALLET_PUBKEY=$(solana-keygen pubkey wallets/reward-wallet.json)
echo "Reward wallet public key: $REWARD_WALLET_PUBKEY"

# For devnet: Request airdrop
solana airdrop 2 $REWARD_WALLET_PUBKEY --url devnet

# Add private key to .env (base58 format)
PRIVATE_KEY_BASE58=$(cat wallets/reward-wallet.json | jq -r 'map(tostring) | join(",")' | node -e 'const bs58=require("bs58"); console.log(bs58.encode(Buffer.from(require("fs").readFileSync(0,"utf8").trim().split(",").map(Number))))')
echo "REWARD_WALLET_PRIVATE_KEY=$PRIVATE_KEY_BASE58" >> .env
```

### 5. Token Mint Setup

If you don't have an existing SPL token:

```bash
# Create new token mint (devnet)
MINT_ADDRESS=$(spl-token create-token --decimals 6 | grep "Creating token" | awk '{print $3}')
echo "MTM Token Mint: $MINT_ADDRESS"

# Create token account for reward wallet
spl-token create-account $MINT_ADDRESS --owner wallets/reward-wallet.json

# Mint initial supply (adjust amount as needed)
spl-token mint $MINT_ADDRESS 1000000 --mint-authority wallets/reward-wallet.json

# Update .env with mint address
echo "MTM_TOKEN_MINT=$MINT_ADDRESS" >> .env
```

### 6. Privy Wallet Setup

1. **Create Privy Account**:
   - Go to [privy.io](https://privy.io)
   - Sign up for a developer account
   - Create a new app

2. **Configure Privy**:
   - Enable Email/OTP login
   - Enable Solana wallet support
   - Add your app domains (localhost for development)
   - Copy App ID and Client ID to `.env`

### 7. Firebase Configuration

```bash
# Login to Firebase
firebase login

# Initialize Firebase project
firebase use your-firebase-project-id

# Update firebase.json with your project details
nano firebase.json

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firebase Functions
cd functions
npm run deploy
cd ..
```

### 8. Final Testing

```bash
# Test Solana integration
cd scripts
npm run test-solana

# Test Flutter app
flutter doctor
flutter run

# Test Firebase Functions locally
cd functions
firebase emulators:start --only functions
```

## Verification Checklist ✅

Verify your setup is complete:

- [ ] **Flutter app runs** without errors
- [ ] **Firebase Functions deployed** successfully
- [ ] **Solana wallet configured** with SOL balance
- [ ] **Token mint created** and reward wallet has tokens
- [ ] **Privy authentication** works in the app
- [ ] **Environment variables** all set correctly
- [ ] **Test user can sign up** and connect wallet

## Troubleshooting 🔧

### Common Issues

1. **"Reward wallet not configured"**:
   - Run `cd scripts && npm run setup-wallet`
   - Check `.env` file has `REWARD_WALLET_PRIVATE_KEY`

2. **"Failed to connect to Solana"**:
   - Check `SOLANA_RPC_URL` in `.env`
   - Try switching between devnet and mainnet
   - Verify internet connection

3. **"Firebase Functions deployment failed"**:
   - Check `firebase.json` project ID
   - Verify you're logged in: `firebase login`
   - Check billing is enabled for your Firebase project

4. **"Token account doesn't exist"**:
   - Run `npm run test-solana` to diagnose
   - Create manually: `spl-token create-account <MINT> --owner <WALLET>`

5. **"Privy authentication failed"**:
   - Verify App ID and Client ID in `.env`
   - Check Privy dashboard configuration
   - Ensure localhost is in allowed domains

### Getting Help

If you encounter issues:

1. Check the [Firebase Console](https://console.firebase.google.com) for errors
2. Run `npm run test-solana` for blockchain diagnostics
3. Check Flutter logs: `flutter logs`
4. Review Firebase Function logs: `firebase functions:log`

## Production Deployment 🌟

For production deployment:

1. **Switch to Mainnet**:
   ```bash
   # Update .env
   SOLANA_NETWORK=mainnet-beta
   SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
   ```

2. **Fund Production Wallet**:
   - Send SOL for transaction fees
   - Send MTM tokens for rewards

3. **Update Privy Configuration**:
   - Add production domains
   - Enable production mode

4. **Deploy Mobile Apps**:
   ```bash
   flutter build appbundle --release  # Android
   flutter build ios --release        # iOS
   ```

5. **Monitor & Scale**:
   - Set up Firebase monitoring
   - Configure auto-scaling for functions
   - Monitor Solana wallet balances

## Security Notes 🔒

- Never commit `.env` files to version control
- Store production private keys securely (consider Google Secret Manager)
- Use strong authentication methods in production
- Regularly rotate wallet keys
- Monitor for suspicious activity patterns

Congratulations! 🎉 Your MTM app is now ready for music that matters!