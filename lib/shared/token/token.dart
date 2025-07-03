import 'package:equatable/equatable.dart';

class SPLToken extends Equatable {
  final String mintAddress;
  final String name;
  final String symbol;
  final int decimals;
  final String? logoUrl;
  final String? description;
  final bool isVerified;
  final Map<String, dynamic> metadata;

  const SPLToken({
    required this.mintAddress,
    required this.name,
    required this.symbol,
    required this.decimals,
    this.logoUrl,
    this.description,
    required this.isVerified,
    required this.metadata,
  });

  factory SPLToken.fromMap(Map<String, dynamic> map) {
    return SPLToken(
      mintAddress: map['mintAddress'] ?? '',
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
      decimals: map['decimals'] ?? 6,
      logoUrl: map['logoUrl'],
      description: map['description'],
      isVerified: map['isVerified'] ?? false,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mintAddress': mintAddress,
      'name': name,
      'symbol': symbol,
      'decimals': decimals,
      'logoUrl': logoUrl,
      'description': description,
      'isVerified': isVerified,
      'metadata': metadata,
    };
  }

  SPLToken copyWith({
    String? mintAddress,
    String? name,
    String? symbol,
    int? decimals,
    String? logoUrl,
    String? description,
    bool? isVerified,
    Map<String, dynamic>? metadata,
  }) {
    return SPLToken(
      mintAddress: mintAddress ?? this.mintAddress,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      decimals: decimals ?? this.decimals,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        mintAddress,
        name,
        symbol,
        decimals,
        logoUrl,
        description,
        isVerified,
        metadata,
      ];

  // Helper methods for token amount calculations
  double fromSmallestUnit(int amount) {
    return amount / (10 * decimals);
  }

  int toSmallestUnit(double amount) {
    return (amount * (10 * decimals)).round();
  }

  String formatAmount(int smallestUnitAmount, {int precision = 2}) {
    final amount = fromSmallestUnit(smallestUnitAmount);
    return amount.toStringAsFixed(precision);
  }

  // Standard MTM token configuration
  static const SPLToken mtmToken = SPLToken(
    mintAddress: 'YOUR_MTM_TOKEN_MINT_ADDRESS', // Replace with actual mint
    name: 'Music That Matters Token',
    symbol: 'MTM',
    decimals: 6,
    description: 'Reward token for authentic music listening on MTM platform',
    isVerified: true,
    metadata: {
      'website': 'https://musicthatmatters.app',
      'twitter': '@MTMToken',
      'discord': 'https://discord.gg/mtm',
    },
  );
}

class TokenBalance extends Equatable {
  final String walletAddress;
  final SPLToken token;
  final int balance; // in smallest units
  final DateTime lastUpdated;
  final bool isStaked;
  final int stakedAmount; // in smallest units
  final int availableAmount; // in smallest units

  const TokenBalance({
    required this.walletAddress,
    required this.token,
    required this.balance,
    required this.lastUpdated,
    this.isStaked = false,
    this.stakedAmount = 0,
    required this.availableAmount,
  });

  factory TokenBalance.fromMap(Map<String, dynamic> map, SPLToken token) {
    return TokenBalance(
      walletAddress: map['walletAddress'] ?? '',
      token: token,
      balance: map['balance'] ?? 0,
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isStaked: map['isStaked'] ?? false,
      stakedAmount: map['stakedAmount'] ?? 0,
      availableAmount: map['availableAmount'] ?? map['balance'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'walletAddress': walletAddress,
      'tokenMint': token.mintAddress,
      'balance': balance,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isStaked': isStaked,
      'stakedAmount': stakedAmount,
      'availableAmount': availableAmount,
    };
  }

  TokenBalance copyWith({
    String? walletAddress,
    SPLToken? token,
    int? balance,
    DateTime? lastUpdated,
    bool? isStaked,
    int? stakedAmount,
    int? availableAmount,
  }) {
    return TokenBalance(
      walletAddress: walletAddress ?? this.walletAddress,
      token: token ?? this.token,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isStaked: isStaked ?? this.isStaked,
      stakedAmount: stakedAmount ?? this.stakedAmount,
      availableAmount: availableAmount ?? this.availableAmount,
    );
  }

  @override
  List<Object?> get props => [
        walletAddress,
        token,
        balance,
        lastUpdated,
        isStaked,
        stakedAmount,
        availableAmount,
      ];

  // Helper getters
  String get formattedBalance => token.formatAmount(balance);
  String get formattedAvailableAmount => token.formatAmount(availableAmount);
  String get formattedStakedAmount => token.formatAmount(stakedAmount);
  
  double get balanceAsDouble => token.fromSmallestUnit(balance);
  double get availableAsDouble => token.fromSmallestUnit(availableAmount);
  double get stakedAsDouble => token.fromSmallestUnit(stakedAmount);

  bool get hasBalance => balance > 0;
  bool get hasAvailable => availableAmount > 0;
  bool get hasStaked => stakedAmount > 0;

  // Calculate percentage staked
  double get stakedPercentage {
    if (balance == 0) return 0.0;
    return (stakedAmount / balance) * 100;
  }
}

class TokenReward extends Equatable {
  final String id;
  final String userId;
  final String trackId;
  final String artistId;
  final SPLToken token;
  final int amount; // in smallest units
  final String reason;
  final DateTime earnedAt;
  final bool isPaid;
  final String? transactionSignature;
  final Map<String, dynamic> metadata;

  const TokenReward({
    required this.id,
    required this.userId,
    required this.trackId,
    required this.artistId,
    required this.token,
    required this.amount,
    required this.reason,
    required this.earnedAt,
    required this.isPaid,
    this.transactionSignature,
    required this.metadata,
  });

  factory TokenReward.fromMap(Map<String, dynamic> map, SPLToken token) {
    return TokenReward(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      trackId: map['trackId'] ?? '',
      artistId: map['artistId'] ?? '',
      token: token,
      amount: map['amount'] ?? 0,
      reason: map['reason'] ?? '',
      earnedAt: DateTime.parse(map['earnedAt'] ?? DateTime.now().toIso8601String()),
      isPaid: map['isPaid'] ?? false,
      transactionSignature: map['transactionSignature'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'trackId': trackId,
      'artistId': artistId,
      'tokenMint': token.mintAddress,
      'amount': amount,
      'reason': reason,
      'earnedAt': earnedAt.toIso8601String(),
      'isPaid': isPaid,
      'transactionSignature': transactionSignature,
      'metadata': metadata,
    };
  }

  TokenReward copyWith({
    String? id,
    String? userId,
    String? trackId,
    String? artistId,
    SPLToken? token,
    int? amount,
    String? reason,
    DateTime? earnedAt,
    bool? isPaid,
    String? transactionSignature,
    Map<String, dynamic>? metadata,
  }) {
    return TokenReward(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trackId: trackId ?? this.trackId,
      artistId: artistId ?? this.artistId,
      token: token ?? this.token,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      earnedAt: earnedAt ?? this.earnedAt,
      isPaid: isPaid ?? this.isPaid,
      transactionSignature: transactionSignature ?? this.transactionSignature,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        trackId,
        artistId,
        token,
        amount,
        reason,
        earnedAt,
        isPaid,
        transactionSignature,
        metadata,
      ];

  // Helper getters
  String get formattedAmount => token.formatAmount(amount);
  double get amountAsDouble => token.fromSmallestUnit(amount);
  
  bool get isPending => !isPaid;
  bool get isCompleted => isPaid && transactionSignature != null;
}

// Reward reasons enum
abstract class RewardReasons {
  static const String listening = 'listening';
  static const String dailyStreak = 'daily_streak';
  static const String newTrackDiscovery = 'new_track_discovery';
  static const String fullTrackPlay = 'full_track_play';
  static const String artistSupport = 'artist_support';
  static const String leaderboardReward = 'leaderboard_reward';
  static const String referralBonus = 'referral_bonus';
  static const String weeklyChallenge = 'weekly_challenge';
}