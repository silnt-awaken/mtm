import 'dart:async';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class AppUtils {
  // Generate random ID
  static String generateId() {
    final random = Random();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  // Generate hash for anti-bot verification
  static String generateListenHash(
    String userId,
    String trackId,
    int timestamp,
  ) {
    final input = '$userId:$trackId:$timestamp';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Validate listen session authenticity
  static bool isValidListenSession({
    required String userId,
    required String trackId,
    required int startTime,
    required int endTime,
    required int duration,
    required String hash,
  }) {
    // Basic validation
    if (endTime <= startTime) return false;
    if (duration != (endTime - startTime)) return false;

    // Hash validation
    final expectedHash = generateListenHash(userId, trackId, startTime);
    if (hash != expectedHash) return false;

    // Duration validation (reasonable listening session)
    if (duration < 5 || duration > 3600) return false; // 5 seconds to 1 hour

    return true;
  }

  // Calculate reward amount based on listening behavior
  static int calculateRewardAmount({
    required int listenDuration,
    required int trackDuration,
    required bool isNewTrack,
    required int dailyListenCount,
    required bool hasStreakBonus,
  }) {
    int baseReward = 1000000; // 1 token

    // Duration-based multiplier
    double durationMultiplier = 1.0;
    if (listenDuration >= trackDuration * 0.8) {
      durationMultiplier = 1.5; // Full track bonus
    } else if (listenDuration >= trackDuration * 0.5) {
      durationMultiplier = 1.2; // Partial track bonus
    }

    // New track discovery bonus
    double discoveryMultiplier = isNewTrack ? 1.1 : 1.0;

    // Daily activity multiplier (decreasing returns)
    double activityMultiplier = 1.0;
    if (dailyListenCount < 10) {
      activityMultiplier = 1.0;
    } else if (dailyListenCount < 50) {
      activityMultiplier = 0.8;
    } else {
      activityMultiplier = 0.5;
    }

    // Streak bonus
    double streakMultiplier = hasStreakBonus ? 1.25 : 1.0;

    final totalReward =
        (baseReward *
                durationMultiplier *
                discoveryMultiplier *
                activityMultiplier *
                streakMultiplier)
            .round();

    return totalReward;
  }

  // Detect suspicious listening patterns
  static bool isSuspiciousActivity({
    required List<Map<String, dynamic>> recentSessions,
    required int maxListensPerHour,
    required int minimumBreakBetweenTracks,
  }) {
    if (recentSessions.isEmpty) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final oneHourAgo = now - (60 * 60 * 1000);

    // Count sessions in the last hour
    final recentCount =
        recentSessions.where((session) {
          final startTime = session['startTime'] as int;
          return startTime > oneHourAgo;
        }).length;

    if (recentCount > maxListensPerHour) return true;

    // Check for rapid successive plays
    for (int i = 1; i < recentSessions.length; i++) {
      final currentEnd = recentSessions[i]['endTime'] as int;
      final previousStart = recentSessions[i - 1]['startTime'] as int;
      final gap = (previousStart - currentEnd) / 1000; // Convert to seconds

      if (gap < minimumBreakBetweenTracks) return true;
    }

    return false;
  }

  // Format wallet address for display
  static String formatWalletAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  // Validate audio quality parameters
  static bool isValidAudioQuality({
    required int bitrate,
    required double volume,
    required int sampleRate,
  }) {
    // Minimum quality thresholds
    if (bitrate < 128) return false; // Minimum 128 kbps
    if (volume < 0.1) return false; // Minimum 10% volume
    if (sampleRate < 44100) return false; // Minimum CD quality

    return true;
  }

  // Generate color from string (for user avatars, etc.)
  static Color colorFromString(String input) {
    final hash = input.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = hash & 0x0000FF;

    return Color.fromRGBO(r, g, b, 1.0);
  }

  // Debounce function for search and other inputs
  static Function debounce(Function func, Duration delay) {
    Timer? timer;
    return ([args]) {
      timer?.cancel();
      timer = Timer(delay, () => func(args));
    };
  }

  // Format track title for display
  static String formatTrackTitle(String title, {int maxLength = 50}) {
    if (title.length <= maxLength) return title;
    return '${title.substring(0, maxLength - 3)}...';
  }

  // Calculate listening streak
  static int calculateStreak(List<DateTime> listeningDates) {
    if (listeningDates.isEmpty) return 0;

    listeningDates.sort((a, b) => b.compareTo(a)); // Sort descending

    int streak = 1;
    DateTime currentDate = listeningDates.first;

    for (int i = 1; i < listeningDates.length; i++) {
      final previousDate = listeningDates[i];
      final dayDifference = currentDate.difference(previousDate).inDays;

      if (dayDifference == 1) {
        streak++;
        currentDate = previousDate;
      } else {
        break;
      }
    }

    return streak;
  }
}
