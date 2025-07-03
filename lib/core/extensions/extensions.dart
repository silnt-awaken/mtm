import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ContextExtensions on BuildContext {
  // Navigation helpers
  void push(String route) => Navigator.pushNamed(this, route);
  void pop() => Navigator.pop(this);
  void pushReplacement(String route) => Navigator.pushReplacementNamed(this, route);
  
  // Theme helpers
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Size helpers
  Size get size => MediaQuery.of(this).size;
  double get width => size.width;
  double get height => size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  
  // Responsive helpers
  bool get isMobile => width < 768;
  bool get isTablet => width >= 768 && width < 1024;
  bool get isDesktop => width >= 1024;
}

extension StringExtensions on String {
  // Validation helpers
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  bool get isValidWalletAddress {
    return RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$').hasMatch(this);
  }
  
  // Formatting helpers
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  String get truncateMiddle {
    if (length <= 16) return this;
    return '${substring(0, 6)}...${substring(length - 4)}';
  }
  
  // Music-specific helpers
  String get formatTrackDuration {
    final parts = split(':');
    if (parts.length == 2) {
      return this; // Already formatted as mm:ss
    }
    
    final seconds = int.tryParse(this) ?? 0;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

extension IntExtensions on int {
  // Duration helpers
  String get formatDuration {
    final duration = Duration(seconds: this);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  // Token amount helpers (assuming 6 decimals)
  String get formatTokenAmount {
    final amount = this / 1000000;
    return NumberFormat('#,##0.##').format(amount);
  }
  
  // File size helpers
  String get formatFileSize {
    if (this < 1024) return '${this} B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

extension DoubleExtensions on double {
  // Percentage helpers
  String get formatPercentage {
    return '${(this * 100).toStringAsFixed(1)}%';
  }
  
  // Currency helpers
  String get formatCurrency {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(this);
  }
  
  // Audio level helpers
  String get formatAudioLevel {
    return '${(this * 100).toInt()}%';
  }
}

extension DateTimeExtensions on DateTime {
  // Relative time helpers
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365}y ago';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  // Formatting helpers
  String get formatDate {
    return DateFormat('MMM dd, yyyy').format(this);
  }
  
  String get formatTime {
    return DateFormat('HH:mm').format(this);
  }
  
  String get formatDateTime {
    return DateFormat('MMM dd, yyyy HH:mm').format(this);
  }
  
  // Music-specific helpers
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return isAfter(startOfWeek);
  }
}

extension ListExtensions<T> on List<T> {
  // Safe access helpers
  T? elementAtOrNull(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
  
  // Chunking helper
  List<List<T>> chunk(int size) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}