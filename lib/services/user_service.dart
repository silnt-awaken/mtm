import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mtm/core/constants/constants.dart';
import 'package:mtm/services/privy_service.dart';
import 'package:mtm/shared/user/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PrivyService _privyService = PrivyService();

  // Create or update user profile
  Future<bool> createOrUpdateUser({
    required String userId,
    String? email,
    String? walletAddress,
    String? displayName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userRef = _firestore.collection(AppConstants.usersCollection).doc(userId);
      
      final userData = {
        'id': userId,
        'email': email,
        'walletAddress': walletAddress,
        'displayName': displayName ?? 'Music Lover',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'totalListenTime': 0,
        'totalRewards': 0,
        'dailyStreak': 0,
        'lastActiveDate': FieldValue.serverTimestamp(),
        'isVerified': false,
        'isArtist': false,
        'preferences': {
          'notifications': true,
          'shareListening': false,
          'autoPlay': true,
          'volume': 0.8,
        },
        'stats': {
          'tracksPlayed': 0,
          'artistsDiscovered': 0,
          'rewardsEarned': 0,
          'longestStreak': 0,
        },
        ...?additionalData,
      };

      await userRef.set(userData, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error creating/updating user: $e');
      return false;
    }
  }

  // Get user profile
  Future<MTMUser?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      return MTMUser.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Get current user from Privy and Firebase
  Future<MTMUser?> getCurrentUser() async {
    if (!_privyService.isAuthenticated()) return null;

    final privyUser = _privyService.currentUser;
    if (privyUser == null) return null;

    return await getUser(privyUser.id);
  }

  // Update user stats
  Future<bool> updateUserStats({
    required String userId,
    int? additionalListenTime,
    int? additionalRewards,
    bool? resetStreak,
    bool? incrementStreak,
    Map<String, dynamic>? additionalStats,
  }) async {
    try {
      final userRef = _firestore.collection(AppConstants.usersCollection).doc(userId);
      
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActiveDate': FieldValue.serverTimestamp(),
      };

      if (additionalListenTime != null) {
        updates['totalListenTime'] = FieldValue.increment(additionalListenTime);
        updates['stats.tracksPlayed'] = FieldValue.increment(1);
      }

      if (additionalRewards != null) {
        updates['totalRewards'] = FieldValue.increment(additionalRewards);
        updates['stats.rewardsEarned'] = FieldValue.increment(additionalRewards);
      }

      if (resetStreak == true) {
        updates['dailyStreak'] = 0;
      } else if (incrementStreak == true) {
        updates['dailyStreak'] = FieldValue.increment(1);
      }

      if (additionalStats != null) {
        additionalStats.forEach((key, value) {
          updates['stats.$key'] = value is int ? FieldValue.increment(value) : value;
        });
      }

      await userRef.update(updates);
      return true;
    } catch (e) {
      debugPrint('Error updating user stats: $e');
      return false;
    }
  }

  // Update user preferences
  Future<bool> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating user preferences: $e');
      return false;
    }
  }

  // Check and update daily streak
  Future<bool> checkDailyStreak(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) return false;

      final now = DateTime.now();
      final lastActive = user.lastActiveDate;

      if (lastActive == null) {
        // First time user
        await updateUserStats(userId: userId, incrementStreak: true);
        return true;
      }

      final daysDifference = now.difference(lastActive).inDays;

      if (daysDifference == 1) {
        // Consecutive day - increment streak
        await updateUserStats(userId: userId, incrementStreak: true);
        
        // Update longest streak if current is higher
        if (user.dailyStreak + 1 > (user.stats['longestStreak'] ?? 0)) {
          await updateUserStats(
            userId: userId,
            additionalStats: {'longestStreak': user.dailyStreak + 1},
          );
        }
        return true;
      } else if (daysDifference > 1) {
        // Streak broken - reset to 1
        await updateUserStats(userId: userId, resetStreak: true);
        await updateUserStats(userId: userId, incrementStreak: true);
        return false;
      }

      // Same day - no change needed
      return true;
    } catch (e) {
      debugPrint('Error checking daily streak: $e');
      return false;
    }
  }

  // Get user leaderboard position
  Future<int?> getUserLeaderboardPosition(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('totalRewards', descending: true)
          .limit(AppConstants.leaderboardLimit)
          .get();

      for (int i = 0; i < snapshot.docs.length; i++) {
        if (snapshot.docs[i].id == userId) {
          return i + 1; // Position is 1-indexed
        }
      }

      return null; // User not in top leaderboard
    } catch (e) {
      debugPrint('Error getting user leaderboard position: $e');
      return null;
    }
  }

  // Register user as artist
  Future<bool> registerAsArtist({
    required String userId,
    required String artistName,
    String? bio,
    String? websiteUrl,
    List<String>? socialLinks,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update user profile
      final userRef = _firestore.collection(AppConstants.usersCollection).doc(userId);
      batch.update(userRef, {
        'isArtist': true,
        'artistProfile': {
          'artistName': artistName,
          'bio': bio,
          'websiteUrl': websiteUrl,
          'socialLinks': socialLinks ?? [],
          'verificationStatus': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create artist document
      final artistRef = _firestore.collection(AppConstants.artistsCollection).doc(userId);
      batch.set(artistRef, {
        'userId': userId,
        'artistName': artistName,
        'bio': bio,
        'websiteUrl': websiteUrl,
        'socialLinks': socialLinks ?? [],
        'verificationStatus': 'pending',
        'totalStreams': 0,
        'totalRewardsDistributed': 0,
        'tracks': [],
        'followers': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error registering as artist: $e');
      return false;
    }
  }

  // Delete user account
  Future<bool> deleteUser(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete user document
      final userRef = _firestore.collection(AppConstants.usersCollection).doc(userId);
      batch.delete(userRef);

      // Delete artist document if exists
      final artistRef = _firestore.collection(AppConstants.artistsCollection).doc(userId);
      batch.delete(artistRef);

      // Note: In a real app, you'd also need to clean up:
      // - Listen sessions
      // - Rewards history
      // - Any user-generated content
      // This could be done via Cloud Functions for better performance

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  // Listen to user changes (for real-time updates)
  Stream<MTMUser?> watchUser(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return MTMUser.fromFirestore(doc);
    });
  }

  // Get users for leaderboard
  Stream<List<MTMUser>> getLeaderboard({int limit = 100}) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('totalRewards', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MTMUser.fromFirestore(doc))
            .toList());
  }
}