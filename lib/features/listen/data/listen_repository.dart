import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mtm/core/constants/constants.dart';
import 'package:mtm/services/privy_service.dart';
import 'package:mtm/shared/track/track.dart';
import 'package:mtm/shared/transaction/transaction.dart';

class ListenRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PrivyService _privyService = PrivyService();

  // Get tracks with optional filtering
  Future<List<Track>> getTracks({
    String? genre,
    int limit = 20,
    String? artistId,
    bool onlyActive = true,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.tracksCollection);

      if (onlyActive) {
        query = query.where('isActive', isEqualTo: true);
      }

      if (genre != null && genre != 'All') {
        query = query.where('genre', isEqualTo: genre);
      }

      if (artistId != null) {
        query = query.where('artistId', isEqualTo: artistId);
      }

      query = query.orderBy('playCount', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Track.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching tracks: $e');
      return [];
    }
  }

  // Get a single track by ID
  Future<Track?> getTrack(String trackId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.tracksCollection)
          .doc(trackId)
          .get();

      if (!doc.exists) return null;
      return Track.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching track: $e');
      return null;
    }
  }

  // Search tracks
  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // In production, you'd use Algolia, Elasticsearch, or Cloud Functions
      // For now, we'll do a simple prefix search on title and artist
      
      final titleResults = await _firestore
          .collection(AppConstants.tracksCollection)
          .where('isActive', isEqualTo: true)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff')
          .limit(limit ~/ 2)
          .get();

      final artistResults = await _firestore
          .collection(AppConstants.tracksCollection)
          .where('isActive', isEqualTo: true)
          .where('artist', isGreaterThanOrEqualTo: query)
          .where('artist', isLessThan: query + '\uf8ff')
          .limit(limit ~/ 2)
          .get();

      final tracks = <Track>[];
      final seenIds = <String>{};

      for (final doc in [...titleResults.docs, ...artistResults.docs]) {
        if (!seenIds.contains(doc.id)) {
          tracks.add(Track.fromFirestore(doc));
          seenIds.add(doc.id);
        }
      }

      return tracks;
    } catch (e) {
      debugPrint('Error searching tracks: $e');
      return [];
    }
  }

  // Start a listen session
  Future<String?> startListenSession({
    required String trackId,
    required DateTime startTime,
  }) async {
    try {
      if (!_privyService.isAuthenticated()) return null;

      final userId = _privyService.currentUser!.id;
      
      final sessionData = {
        'userId': userId,
        'trackId': trackId,
        'startTime': Timestamp.fromDate(startTime),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection(AppConstants.listenSessionsCollection)
          .add(sessionData);

      return docRef.id;
    } catch (e) {
      debugPrint('Error starting listen session: $e');
      return null;
    }
  }

  // End a listen session and validate for rewards
  Future<bool> endListenSession(Map<String, dynamic> sessionData) async {
    try {
      if (!_privyService.isAuthenticated()) return false;

      final userId = _privyService.currentUser!.id;
      final trackId = sessionData['trackId'] as String;
      final duration = sessionData['duration'] as int;
      final volume = sessionData['volume'] as double;
      
      // Record the completed session
      await _firestore.collection(AppConstants.listenSessionsCollection).add({
        'userId': userId,
        'trackId': trackId,
        'duration': duration,
        'volume': volume,
        'startTime': Timestamp.fromMillisecondsSinceEpoch(sessionData['startTime']),
        'endTime': Timestamp.fromMillisecondsSinceEpoch(sessionData['endTime']),
        'isValidForReward': sessionData['isValidForReward'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update track play count
      await _firestore
          .collection(AppConstants.tracksCollection)
          .doc(trackId)
          .update({
        'playCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error ending listen session: $e');
      return false;
    }
  }

  // Get recent listen sessions for anti-bot validation
  Future<List<Map<String, dynamic>>> getRecentListenSessions({
    int hoursBack = 24,
  }) async {
    try {
      if (!_privyService.isAuthenticated()) return [];

      final userId = _privyService.currentUser!.id;
      final cutoffTime = DateTime.now().subtract(Duration(hours: hoursBack));

      final snapshot = await _firestore
          .collection(AppConstants.listenSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThan: Timestamp.fromDate(cutoffTime))
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'startTime': (data['startTime'] as Timestamp).millisecondsSinceEpoch,
          'endTime': (data['endTime'] as Timestamp?)?.millisecondsSinceEpoch ?? 
                     DateTime.now().millisecondsSinceEpoch,
          'duration': data['duration'] ?? 0,
          'trackId': data['trackId'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching recent sessions: $e');
      return [];
    }
  }

  // Like a track
  Future<bool> likeTrack(String trackId) async {
    try {
      if (!_privyService.isAuthenticated()) return false;

      final userId = _privyService.currentUser!.id;
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'likedTracks': FieldValue.arrayUnion([trackId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error liking track: $e');
      return false;
    }
  }

  // Unlike a track
  Future<bool> unlikeTrack(String trackId) async {
    try {
      if (!_privyService.isAuthenticated()) return false;

      final userId = _privyService.currentUser!.id;
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'likedTracks': FieldValue.arrayRemove([trackId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error unliking track: $e');
      return false;
    }
  }

  // Get user's liked tracks
  Future<Set<String>> getLikedTracks() async {
    try {
      if (!_privyService.isAuthenticated()) return {};

      final userId = _privyService.currentUser!.id;
      
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return {};

      final data = doc.data()!;
      final likedTracks = data['likedTracks'] as List<dynamic>? ?? [];
      return likedTracks.cast<String>().toSet();
    } catch (e) {
      debugPrint('Error fetching liked tracks: $e');
      return {};
    }
  }

  // Create a reward transaction for a valid listen session
  Future<bool> createRewardTransaction({
    required String trackId,
    required int amount,
    required Map<String, dynamic> sessionData,
  }) async {
    try {
      if (!_privyService.isAuthenticated()) return false;

      final userId = _privyService.currentUser!.id;
      final walletAddress = _privyService.walletAddress;
      
      if (walletAddress == null) {
        debugPrint('No wallet address found for reward transaction');
        return false;
      }

      // Get track info for metadata
      final track = await getTrack(trackId);
      
      final transaction = TransactionFactory.createRewardTransaction(
        userId: userId,
        walletAddress: walletAddress,
        amount: amount,
        reason: 'listening',
        trackId: trackId,
        artistId: track?.artistId,
        trackTitle: track?.title,
      );

      // Add to rewards collection
      await _firestore.collection(AppConstants.rewardsCollection).add({
        ...transaction.toFirestore(),
        'sessionData': sessionData,
      });

      debugPrint('Created reward transaction: $amount tokens for listening to ${track?.title}');
      return true;
    } catch (e) {
      debugPrint('Error creating reward transaction: $e');
      return false;
    }
  }

  // Get trending tracks (most played recently)
  Future<List<Track>> getTrendingTracks({int limit = 10}) async {
    try {
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
      
      // Get tracks with high play counts in the last day
      // Note: This is a simplified approach. In production, you'd have
      // a more sophisticated trending algorithm with Cloud Functions
      
      final snapshot = await _firestore
          .collection(AppConstants.tracksCollection)
          .where('isActive', isEqualTo: true)
          .where('updatedAt', isGreaterThan: Timestamp.fromDate(oneDayAgo))
          .orderBy('updatedAt', descending: true)
          .orderBy('playCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Track.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching trending tracks: $e');
      return [];
    }
  }

  // Get new releases
  Future<List<Track>> getNewReleases({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.tracksCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Track.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching new releases: $e');
      return [];
    }
  }

  // Get recommended tracks (simplified recommendation)
  Future<List<Track>> getRecommendedTracks({int limit = 10}) async {
    try {
      if (!_privyService.isAuthenticated()) {
        // Return popular tracks for non-authenticated users
        return getTracks(limit: limit);
      }

      // Get user's liked tracks to understand preferences
      final likedTrackIds = await getLikedTracks();
      
      if (likedTrackIds.isEmpty) {
        return getTracks(limit: limit);
      }

      // Get genres from liked tracks
      final likedTracks = await Future.wait(
        likedTrackIds.take(5).map((id) => getTrack(id)),
      );
      
      final preferredGenres = likedTracks
          .where((track) => track != null)
          .map((track) => track!.genre)
          .toSet()
          .toList();

      if (preferredGenres.isEmpty) {
        return getTracks(limit: limit);
      }

      // Get tracks from preferred genres
      final snapshot = await _firestore
          .collection(AppConstants.tracksCollection)
          .where('isActive', isEqualTo: true)
          .where('genre', whereIn: preferredGenres.take(10).toList()) // Firestore limit
          .orderBy('playCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Track.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching recommended tracks: $e');
      return getTracks(limit: limit);
    }
  }

  // Stream tracks for real-time updates
  Stream<List<Track>> watchTracks({String? genre, int limit = 20}) {
    Query query = _firestore.collection(AppConstants.tracksCollection)
        .where('isActive', isEqualTo: true);

    if (genre != null && genre != 'All') {
      query = query.where('genre', isEqualTo: genre);
    }

    query = query.orderBy('playCount', descending: true).limit(limit);

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Track.fromFirestore(doc)).toList());
  }
}