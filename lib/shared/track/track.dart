import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String audioUrl;
  final String? imageUrl;
  final int duration; // in seconds
  final String genre;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int playCount;
  final int rewardsDistributed;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final TrackQuality quality;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.audioUrl,
    this.imageUrl,
    required this.duration,
    required this.genre,
    required this.tags,
    this.createdAt,
    this.updatedAt,
    required this.playCount,
    required this.rewardsDistributed,
    required this.isActive,
    required this.metadata,
    required this.quality,
  });

  factory Track.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Track(
      id: doc.id,
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      artistId: data['artistId'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      imageUrl: data['imageUrl'],
      duration: data['duration'] ?? 0,
      genre: data['genre'] ?? 'Unknown',
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      playCount: data['playCount'] ?? 0,
      rewardsDistributed: data['rewardsDistributed'] ?? 0,
      isActive: data['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      quality: data['quality'] != null 
          ? TrackQuality.fromMap(data['quality'])
          : const TrackQuality(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artistId': artistId,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'duration': duration,
      'genre': genre,
      'tags': tags,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'playCount': playCount,
      'rewardsDistributed': rewardsDistributed,
      'isActive': isActive,
      'metadata': metadata,
      'quality': quality.toMap(),
    };
  }

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? audioUrl,
    String? imageUrl,
    int? duration,
    String? genre,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? playCount,
    int? rewardsDistributed,
    bool? isActive,
    Map<String, dynamic>? metadata,
    TrackQuality? quality,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      genre: genre ?? this.genre,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      playCount: playCount ?? this.playCount,
      rewardsDistributed: rewardsDistributed ?? this.rewardsDistributed,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      quality: quality ?? this.quality,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        artistId,
        audioUrl,
        imageUrl,
        duration,
        genre,
        tags,
        createdAt,
        updatedAt,
        playCount,
        rewardsDistributed,
        isActive,
        metadata,
        quality,
      ];

  // Helper getters
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedRewards {
    return (rewardsDistributed / 1000000).toStringAsFixed(2); // Assuming 6 decimals
  }

  bool get isEligibleForRewards {
    return isActive && 
           duration >= 30 && // Minimum 30 seconds
           quality.bitrate >= 128 && // Minimum quality
           audioUrl.isNotEmpty;
  }

  double get popularityScore {
    // Simple popularity calculation based on play count and recency
    final daysSinceCreated = createdAt != null 
        ? DateTime.now().difference(createdAt!).inDays 
        : 0;
    
    // Newer tracks get a boost, but play count is primary factor
    final recencyBoost = daysSinceCreated < 30 ? 1.2 : 1.0;
    return playCount * recencyBoost;
  }
}

class TrackQuality extends Equatable {
  final int bitrate; // kbps
  final int sampleRate; // Hz
  final String format; // mp3, flac, etc.
  final int fileSize; // bytes
  final bool isLossless;

  const TrackQuality({
    this.bitrate = 320,
    this.sampleRate = 44100,
    this.format = 'mp3',
    this.fileSize = 0,
    this.isLossless = false,
  });

  factory TrackQuality.fromMap(Map<String, dynamic> map) {
    return TrackQuality(
      bitrate: map['bitrate'] ?? 320,
      sampleRate: map['sampleRate'] ?? 44100,
      format: map['format'] ?? 'mp3',
      fileSize: map['fileSize'] ?? 0,
      isLossless: map['isLossless'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bitrate': bitrate,
      'sampleRate': sampleRate,
      'format': format,
      'fileSize': fileSize,
      'isLossless': isLossless,
    };
  }

  TrackQuality copyWith({
    int? bitrate,
    int? sampleRate,
    String? format,
    int? fileSize,
    bool? isLossless,
  }) {
    return TrackQuality(
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      format: format ?? this.format,
      fileSize: fileSize ?? this.fileSize,
      isLossless: isLossless ?? this.isLossless,
    );
  }

  @override
  List<Object?> get props => [
        bitrate,
        sampleRate,
        format,
        fileSize,
        isLossless,
      ];

  String get qualityLabel {
    if (isLossless) return 'Lossless';
    if (bitrate >= 320) return 'High';
    if (bitrate >= 192) return 'Medium';
    return 'Standard';
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize} B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get meetsMinimumQuality {
    return bitrate >= 128 && sampleRate >= 44100;
  }
}