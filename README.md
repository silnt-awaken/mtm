# MTM (Music That Matters) 🎵

A cross-platform Flutter app that rewards authentic music listeners with SPL tokens on the Solana blockchain.

## 🎯 Overview

MTM revolutionizes music streaming by creating a direct economic relationship between listeners and artists. Users earn SPL tokens for genuine music listening while artists receive rewards based on authentic engagement.

### Key Features

- **🎧 Listen & Earn**: Earn MTM tokens for authentic music listening (30+ seconds, proper volume)
- **🔐 Secure Wallet**: Privy-powered wallet integration with multi-device support
- **🎨 Artist Dashboard**: Upload tracks, manage content, and track earnings
- **🏆 Leaderboards**: Compete with other listeners for bonus rewards
- **📊 Anti-Bot Protection**: Advanced validation to ensure authentic engagement
- **📱 Cross-Platform**: Native iOS and Android apps built with Flutter

## 🏗️ Architecture

MTM follows the same modular architecture as WAGUS, emphasizing clean separation of concerns and scalability.

### Project Structure

```
lib/
├── core/                    # Core utilities and configuration
│   ├── config/             # App configuration and settings
│   ├── constants/          # App-wide constants
│   ├── extensions/         # Dart extensions
│   ├── theme/             # App theming and colors
│   └── utils/             # Utility functions
├── features/              # Feature-based modules
│   ├── auth/              # Authentication (Privy integration)
│   ├── listen/            # Music playback and session tracking
│   ├── rewards/           # Token rewards and transactions
│   ├── profile/           # User profile management
│   ├── artist/            # Artist dashboard and tools
│   ├── leaderboard/       # User rankings and competitions
│   └── anti_bot/          # Bot detection and prevention
├── presentation/          # App-wide UI components
├── routing/               # Navigation and routing
├── services/              # Cross-cutting services
│   ├── privy_service.dart # Wallet management
│   ├── user_service.dart  # User operations
│   └── audio_service.dart # Music playback
└── shared/                # Shared models and widgets
    ├── user/              # User data models
    ├── token/             # Token and transaction models
    ├── track/             # Music track models
    └── widgets/           # Reusable UI components
```

### Technology Stack

- **Frontend**: Flutter 3.7+ with Dart
- **State Management**: BLoC pattern with flutter_bloc
- **Navigation**: go_router for declarative routing
- **Audio**: just_audio for music playback
- **Blockchain**: Solana with SPL tokens
- **Wallet**: Privy for secure key management
- **Backend**: Firebase (Firestore, Functions, Auth)
- **Analytics**: Firebase Analytics

## 🔧 Setup & Installation

### Prerequisites

- Flutter SDK 3.7+
- Dart SDK 3.0+
- Firebase project setup
- Privy app configuration
- Solana wallet for testing

### Environment Configuration

1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Configure your environment variables:
   ```env
   # Privy Configuration
   PRIVY_APP_ID=your_privy_app_id_here
   PRIVY_CLIENT_ID=your_privy_client_id_here

   # Solana Configuration
   SOLANA_NETWORK=mainnet-beta
   MTM_TOKEN_MINT=your_mtm_token_mint_address_here

   # Firebase Configuration
   FIREBASE_PROJECT_ID=mtm-app
   ```

### Firebase Setup

1. Create a new Firebase project
2. Enable Firestore, Authentication, and Cloud Functions
3. Update `firebase.json` with your project details
4. Install Firebase CLI and deploy functions:
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

### Solana Wallet Setup

1. Generate reward wallet:
   ```bash
   cd scripts
   npm install
   npm run setup-wallet
   ```

2. Test Solana integration:
   ```bash
   npm run test-solana
   ```

### Flutter Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate platform-specific files:
   ```bash
   flutter build appbundle  # For Android
   flutter build ios        # For iOS
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## 🎵 How It Works

### Listen-to-Earn Mechanism

1. **Authentication**: Users sign in with email/OTP or connect existing wallet
2. **Music Discovery**: Browse tracks, search by genre, or get recommendations
3. **Authentic Listening**: Play tracks for minimum duration with proper volume
4. **Validation**: Server-side validation prevents gaming the system
5. **Rewards**: Earn MTM tokens based on listening behavior and streaks
6. **Claiming**: Tokens are automatically distributed to user wallets

### Anti-Bot Protection

- **Minimum Listen Time**: 30 seconds required for rewards
- **Volume Monitoring**: Must maintain >10% volume
- **Rate Limiting**: Maximum listens per hour/day
- **Behavioral Analysis**: Pattern detection for suspicious activity
- **Hash Validation**: Cryptographic session verification

### Reward Structure

```dart
Base Reward: 1 MTM token per valid session
Multipliers:
- Full track (>80%): 1.5x
- Partial track (>50%): 1.2x
- New discovery: 1.1x
- Daily streak: 1.25x
- Volume boost (>80%): 1.1x
```

## 🔗 Blockchain Integration

### Solana SPL Tokens

MTM uses Solana's high-performance blockchain for token operations:

- **Low Fees**: Minimal transaction costs
- **Fast Confirmation**: Sub-second finality
- **Scalability**: Thousands of transactions per second
- **Eco-Friendly**: Proof-of-Stake consensus

### Smart Contract Features

- **Automated Rewards**: Cloud Functions trigger token transfers
- **Batch Processing**: Efficient bulk reward distribution
- **Error Handling**: Robust retry mechanisms
- **Audit Trail**: Complete transaction history

## 🎨 Artist Features

### Content Management
- Upload high-quality audio files
- Manage track metadata and artwork
- Set genre tags and descriptions
- Track performance analytics

### Revenue Sharing
- Earn from authentic listener engagement
- Real-time reward tracking
- Transparent payment system
- Direct wallet payouts

### Verification System
- Artist profile verification
- Content authenticity checks
- Community guidelines enforcement
- Support ticket system

## 📊 Firebase Backend

### Cloud Functions

Located in `/functions/index.js`:

- **validateListenSession**: Server-side session validation
- **processRewards**: Batch SPL token distribution
- **updateUserStatsOnReward**: Automatic stat updates
- **cleanupOldSessions**: Data maintenance

### Firestore Collections

```
users/               # User profiles and preferences
tracks/             # Music track metadata
listen_sessions/    # Listening session records
rewards/           # Pending and completed rewards
artists/           # Artist profiles and content
leaderboard/       # User rankings and stats
app_config/        # Global app configuration
```

### Security Rules

- **User Data**: Users can only access their own data
- **Artist Content**: Verified artists can manage their tracks
- **Listen Sessions**: Server-validated before rewards
- **Admin Operations**: Function-only writes for sensitive data

## 🔒 Security & Privacy

### Wallet Security
- **Privy Integration**: Industry-standard key management
- **Multi-Device Sync**: Secure key backup and recovery
- **Biometric Auth**: Optional fingerprint/Face ID protection
- **Session Management**: Automatic timeout and refresh

### Data Protection
- **End-to-End Encryption**: Sensitive data encrypted in transit
- **GDPR Compliance**: User data control and deletion rights
- **Minimal Collection**: Only necessary data stored
- **Audit Logging**: Complete activity tracking

## 🚀 Deployment

### Mobile App Stores

```bash
# Android (Google Play)
flutter build appbundle --release
# Upload to Google Play Console

# iOS (App Store)
flutter build ios --release
# Archive and upload via Xcode
```

### Backend Deployment

```bash
# Firebase Functions
cd functions
npm run deploy

# Firestore Rules
firebase deploy --only firestore:rules

# Storage Rules
firebase deploy --only storage
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Firebase Emulation
```bash
firebase emulators:start
```

## 🛠️ Utility Scripts

MTM includes helpful scripts in the `/scripts` directory for blockchain setup and testing:

### Reward Wallet Setup
```bash
cd scripts
npm install

# Generate and configure reward wallet
npm run setup-wallet

# Force regenerate wallet (overwrites existing)
npm run setup-wallet-force
```

This script will:
- Generate a new Solana keypair for reward distribution
- Save the wallet configuration securely
- Update your `.env` file automatically
- Fund the wallet on devnet (if applicable)
- Display setup instructions

### Solana Integration Testing
```bash
npm run test-solana
```

This script validates:
- Solana RPC connection
- Reward wallet configuration and balance
- Token mint validation
- Associated token account setup
- Reward simulation

### Manual Wallet Management

If you prefer manual setup:

```bash
# Generate new wallet
solana-keygen new --outfile reward-wallet.json

# Get public key (for funding)
solana-keygen pubkey reward-wallet.json

# Check balance
solana balance <PUBLIC_KEY> --url devnet

# Create token account
spl-token create-account <MINT_ADDRESS> --owner reward-wallet.json
```

## 📈 Monitoring & Analytics

### Performance Metrics
- **Listen Session Success Rate**: Percentage of valid sessions
- **Reward Distribution Speed**: Average time to token delivery
- **User Retention**: Daily/weekly/monthly active users
- **Bot Detection Rate**: Suspicious activity caught

### Business Intelligence
- **Track Popularity**: Most-played songs and artists
- **User Engagement**: Listening patterns and preferences
- **Revenue Analytics**: Token distribution and economics
- **Geographic Insights**: Usage by region

## 🛠️ Development Workflow

### Git Flow
- **main**: Production releases
- **develop**: Integration branch
- **feature/***: New features
- **hotfix/***: Critical fixes

### Code Quality
- **Linting**: Enforced code style
- **Type Safety**: Strict null safety
- **Documentation**: Comprehensive inline docs
- **Testing**: Unit and integration tests

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit pull request with description
5. Code review and merge

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation
- **API Reference**: `/docs/api.md`
- **User Guide**: `/docs/user-guide.md`
- **Artist Handbook**: `/docs/artist-guide.md`

### Community
- **Discord**: https://discord.gg/mtm
- **Twitter**: @MTMToken
- **Email**: support@musicthatmatters.app

## 🗺️ Roadmap

### Phase 1 (Q1 2024)
- [x] Core listening and reward system
- [x] Basic artist dashboard
- [x] Privy wallet integration
- [ ] Beta testing program

### Phase 2 (Q2 2024)
- [ ] Advanced analytics dashboard
- [ ] Social features and playlists
- [ ] Artist verification program
- [ ] Mobile app store release

### Phase 3 (Q3 2024)
- [ ] NFT integration for exclusive content
- [ ] Cross-platform sync
- [ ] Advanced recommendation engine
- [ ] Partnership integrations

### Phase 4 (Q4 2024)
- [ ] DAO governance features
- [ ] Advanced DeFi integrations
- [ ] Global expansion
- [ ] Enterprise partnerships

---

**Built with ❤️ for the music community**

*MTM - Where authentic listening meets fair rewards*