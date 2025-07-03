part of 'listen_bloc.dart';

abstract class ListenState extends Equatable {
  const ListenState();

  @override
  List<Object?> get props => [];
}

class ListenInitial extends ListenState {}

class ListenLoading extends ListenState {}

class ListenLoaded extends ListenState {
  final List<Track> tracks;
  final List<Track> filteredTracks;
  final Track? currentTrack;
  final PlaybackState playbackState;
  final Duration position;
  final Duration? duration;
  final double volume;
  final bool isShuffled;
  final RepeatMode repeatMode;
  final String? currentGenreFilter;
  final String? searchQuery;
  final Set<String> likedTrackIds;
  final Map<String, dynamic>? currentSessionData;

  const ListenLoaded({
    this.tracks = const [],
    this.filteredTracks = const [],
    this.currentTrack,
    this.playbackState = PlaybackState.stopped,
    this.position = Duration.zero,
    this.duration,
    this.volume = 0.8,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.none,
    this.currentGenreFilter,
    this.searchQuery,
    this.likedTrackIds = const {},
    this.currentSessionData,
  });

  ListenLoaded copyWith({
    List<Track>? tracks,
    List<Track>? filteredTracks,
    Track? currentTrack,
    PlaybackState? playbackState,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffled,
    RepeatMode? repeatMode,
    String? currentGenreFilter,
    String? searchQuery,
    Set<String>? likedTrackIds,
    Map<String, dynamic>? currentSessionData,
  }) {
    return ListenLoaded(
      tracks: tracks ?? this.tracks,
      filteredTracks: filteredTracks ?? this.filteredTracks,
      currentTrack: currentTrack ?? this.currentTrack,
      playbackState: playbackState ?? this.playbackState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      currentGenreFilter: currentGenreFilter ?? this.currentGenreFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      likedTrackIds: likedTrackIds ?? this.likedTrackIds,
      currentSessionData: currentSessionData ?? this.currentSessionData,
    );
  }

  @override
  List<Object?> get props => [
        tracks,
        filteredTracks,
        currentTrack,
        playbackState,
        position,
        duration,
        volume,
        isShuffled,
        repeatMode,
        currentGenreFilter,
        searchQuery,
        likedTrackIds,
        currentSessionData,
      ];

  // Helper getters
  bool get isPlaying => playbackState == PlaybackState.playing;
  bool get isPaused => playbackState == PlaybackState.paused;
  bool get isBuffering => playbackState == PlaybackState.buffering;
  bool get hasCurrentTrack => currentTrack != null;
  
  double get progressPercentage {
    if (duration == null || duration!.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration!.inMilliseconds;
  }

  bool isTrackLiked(String trackId) => likedTrackIds.contains(trackId);

  int? get currentTrackIndex {
    if (currentTrack == null) return null;
    return filteredTracks.indexWhere((track) => track.id == currentTrack!.id);
  }

  Track? get nextTrack {
    final index = currentTrackIndex;
    if (index == null || index >= filteredTracks.length - 1) return null;
    return filteredTracks[index + 1];
  }

  Track? get previousTrack {
    final index = currentTrackIndex;
    if (index == null || index <= 0) return null;
    return filteredTracks[index - 1];
  }

  bool get canGoNext => nextTrack != null || repeatMode == RepeatMode.all;
  bool get canGoPrevious => previousTrack != null || repeatMode == RepeatMode.all;

  List<String> get availableGenres {
    final genres = tracks.map((track) => track.genre).toSet().toList();
    genres.sort();
    return genres;
  }

  // Session validation helpers
  bool get isSessionEligibleForRewards {
    if (currentSessionData == null) return false;
    
    final duration = currentSessionData!['currentDuration'] as int? ?? 0;
    final volume = currentSessionData!['volume'] as double? ?? 0.0;
    
    return duration >= AppConstants.minimumListenDuration && 
           volume >= AppConstants.minimumVolume;
  }

  String get sessionStatusText {
    if (currentSessionData == null) return 'No active session';
    
    final duration = currentSessionData!['currentDuration'] as int? ?? 0;
    final volume = currentSessionData!['volume'] as double? ?? 0.0;
    
    if (duration < AppConstants.minimumListenDuration) {
      final remaining = AppConstants.minimumListenDuration - duration;
      return 'Listen for ${remaining}s more to earn rewards';
    }
    
    if (volume < AppConstants.minimumVolume) {
      return 'Volume too low for rewards';
    }
    
    return 'Earning rewards! Keep listening...';
  }
}

class ListenError extends ListenState {
  final String message;
  final Exception? exception;

  const ListenError({
    required this.message,
    this.exception,
  });

  @override
  List<Object?> get props => [message, exception];
}

class ListenPlaybackError extends ListenState {
  final String message;
  final Track? track;

  const ListenPlaybackError({
    required this.message,
    this.track,
  });

  @override
  List<Object?> get props => [message, track];
}

class ListenSessionValidated extends ListenState {
  final bool isValid;
  final String? invalidReason;
  final int? rewardAmount;

  const ListenSessionValidated({
    required this.isValid,
    this.invalidReason,
    this.rewardAmount,
  });

  @override
  List<Object?> get props => [isValid, invalidReason, rewardAmount];
}