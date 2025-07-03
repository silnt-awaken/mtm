import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MTMUser extends Equatable {
  final String id;
  final String? email;
  final String? walletAddress;
  final String displayName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActiveDate;
  final int totalListenTime; // in seconds
  final int totalRewards; // in token smallest units
  final int dailyStreak;
  final bool isVerified;
  final bool isArtist;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> stats;
  final ArtistProfile? artistProfile;

  const MTMUser({
    required this.id,
    this.email,
    this.walletAddress,
    required this.displayName,
    this.createdAt,
    this.updatedAt,
    this.lastActiveDate,
    required this.totalListenTime,
    required this.totalRewards,
    required this.dailyStreak,
    required this.isVerified,
    required this.isArtist,
    required this.preferences,
    required this.stats,
    this.artistProfile,
  });

  factory MTMUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MTMUser(
      id: doc.id,
      email: data['email'],
      walletAddress: data['walletAddress'],
      displayName: data['displayName'] ?? 'Music Lover',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
      totalListenTime: data['totalListenTime'] ?? 0,
      totalRewards: data['totalRewards'] ?? 0,
      dailyStreak: data['dailyStreak'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      isArtist: data['isArtist'] ?? false,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      stats: Map<String, dynamic>.from(data['stats'] ?? {}),
      artistProfile: data['artistProfile'] != null 
          ? ArtistProfile.fromMap(data['artistProfile'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'walletAddress': walletAddress,
      'displayName': displayName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastActiveDate': lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      'totalListenTime': totalListenTime,
      'totalRewards': totalRewards,
      'dailyStreak': dailyStreak,
      'isVerified': isVerified,
      'isArtist': isArtist,
      'preferences': preferences,
      'stats': stats,
      'artistProfile': artistProfile?.toMap(),
    };
  }

  MTMUser copyWith({
    String? id,
    String? email,
    String? walletAddress,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveDate,
    int? totalListenTime,
    int? totalRewards,
    int? dailyStreak,
    bool? isVerified,
    bool? isArtist,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? stats,
    ArtistProfile? artistProfile,
  }) {
    return MTMUser(
      id: id ?? this.id,
      email: email ?? this.email,
      walletAddress: walletAddress ?? this.walletAddress,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalListenTime: totalListenTime ?? this.totalListenTime,
      totalRewards: totalRewards ?? this.totalRewards,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      isVerified: isVerified ?? this.isVerified,
      isArtist: isArtist ?? this.isArtist,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      artistProfile: artistProfile ?? this.artistProfile,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        walletAddress,
        displayName,
        createdAt,
        updatedAt,
        lastActiveDate,
        totalListenTime,
        totalRewards,
        dailyStreak,
        isVerified,
        isArtist,
        preferences,
        stats,
        artistProfile,
      ];

  // Helper getters
  String get formattedTotalRewards {
    return (totalRewards / 1000000).toStringAsFixed(2); // Assuming 6 decimals
  }

  String get formattedListenTime {
    final hours = totalListenTime ~/ 3600;
    final minutes = (totalListenTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  int get tracksPlayed => stats['tracksPlayed'] ?? 0;
  int get artistsDiscovered => stats['artistsDiscovered'] ?? 0;
  int get rewardsEarned => stats['rewardsEarned'] ?? 0;
  int get longestStreak => stats['longestStreak'] ?? 0;

  bool get notificationsEnabled => preferences['notifications'] ?? true;
  bool get shareListening => preferences['shareListening'] ?? false;
  bool get autoPlay => preferences['autoPlay'] ?? true;
  double get preferredVolume => (preferences['volume'] ?? 0.8).toDouble();
}

class ArtistProfile extends Equatable {
  final String artistName;
  final String? bio;
  final String? websiteUrl;
  final List<String> socialLinks;
  final String verificationStatus; // pending, verified, rejected
  final DateTime? createdAt;

  const ArtistProfile({
    required this.artistName,
    this.bio,
    this.websiteUrl,
    required this.socialLinks,
    required this.verificationStatus,
    this.createdAt,
  });

  factory ArtistProfile.fromMap(Map<String, dynamic> map) {
    return ArtistProfile(
      artistName: map['artistName'] ?? '',
      bio: map['bio'],
      websiteUrl: map['websiteUrl'],
      socialLinks: List<String>.from(map['socialLinks'] ?? []),
      verificationStatus: map['verificationStatus'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'artistName': artistName,
      'bio': bio,
      'websiteUrl': websiteUrl,
      'socialLinks': socialLinks,
      'verificationStatus': verificationStatus,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  ArtistProfile copyWith({
    String? artistName,
    String? bio,
    String? websiteUrl,
    List<String>? socialLinks,
    String? verificationStatus,
    DateTime? createdAt,
  }) {
    return ArtistProfile(
      artistName: artistName ?? this.artistName,
      bio: bio ?? this.bio,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        artistName,
        bio,
        websiteUrl,
        socialLinks,
        verificationStatus,
        createdAt,
      ];

  bool get isVerified => verificationStatus == 'verified';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';
}