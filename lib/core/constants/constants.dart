class AppConstants {
  // App Info
  static const String appName = 'MTM';
  static const String appDescription = 'Music That Matters';
  
  // Solana Network
  static const String solanaNetwork = 'mainnet-beta'; // or 'devnet' for testing
  static const String splTokenMint = 'YOUR_SPL_TOKEN_MINT_ADDRESS_HERE';
  
  // Reward Thresholds (in seconds)
  static const int minimumListenDuration = 30; // 30 seconds minimum
  static const int fullTrackThreshold = 240; // 4 minutes for full track reward
  static const int dailyListenCap = 86400; // 24 hours max per day
  
  // Reward Amounts (in smallest token units)
  static const int baseRewardAmount = 1000000; // 1 token (assuming 6 decimals)
  static const int fullTrackBonus = 500000; // 0.5 token bonus
  static const int dailyStreakBonus = 250000; // 0.25 token for daily streak
  
  // Anti-Bot Detection
  static const int maxListensPerHour = 60;
  static const int maxDailyListens = 500;
  static const int minimumBreakBetweenTracks = 5; // 5 seconds
  
  // Leaderboard
  static const int leaderboardLimit = 100;
  static const int topListenerReward = 10000000; // 10 tokens for #1 spot
  
  // Audio Quality Validation
  static const int minimumBitrate = 128; // kbps
  static const double minimumVolume = 0.1; // 10% minimum volume
  
  // Collection Names (Firestore)
  static const String usersCollection = 'users';
  static const String tracksCollection = 'tracks';
  static const String listenSessionsCollection = 'listen_sessions';
  static const String rewardsCollection = 'rewards';
  static const String artistsCollection = 'artists';
  static const String leaderboardCollection = 'leaderboard';
  static const String configCollection = 'app_config';
  
  // Routes
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String artistRoute = '/artist';
  static const String leaderboardRoute = '/leaderboard';
  static const String rewardsRoute = '/rewards';
  static const String playerRoute = '/player';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String walletAddressKey = 'wallet_address';
  static const String lastSyncKey = 'last_sync';
  static const String dailyStreakKey = 'daily_streak';
  static const String totalListenTimeKey = 'total_listen_time';
}