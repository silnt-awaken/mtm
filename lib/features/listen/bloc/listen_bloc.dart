import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mtm/core/constants/constants.dart';
import 'package:mtm/core/utils/utils.dart';
import 'package:mtm/features/listen/data/listen_repository.dart';
import 'package:mtm/services/audio_service.dart';
import 'package:mtm/shared/track/track.dart';

part 'listen_event.dart';
part 'listen_state.dart';

class ListenBloc extends Bloc<ListenEvent, ListenState> {
  final ListenRepository listenRepository;
  final AudioService audioService;
  
  StreamSubscription? _audioStateSubscription;
  StreamSubscription? _audioPositionSubscription;
  StreamSubscription? _audioStatsSubscription;

  ListenBloc({
    required this.listenRepository,
    required this.audioService,
  }) : super(ListenInitial()) {
    on<ListenInitializeEvent>(_onInitialize);
    on<ListenLoadTracksEvent>(_onLoadTracks);
    on<ListenPlayTrackEvent>(_onPlayTrack);
    on<ListenPauseEvent>(_onPause);
    on<ListenResumeEvent>(_onResume);
    on<ListenStopEvent>(_onStop);
    on<ListenSeekEvent>(_onSeek);
    on<ListenVolumeChangeEvent>(_onVolumeChange);
    on<ListenSessionStartedEvent>(_onSessionStarted);
    on<ListenSessionEndedEvent>(_onSessionEnded);
    on<ListenValidateSessionEvent>(_onValidateSession);
    on<ListenSearchTracksEvent>(_onSearchTracks);
    on<ListenFilterByGenreEvent>(_onFilterByGenre);
    on<ListenLikeTrackEvent>(_onLikeTrack);
    on<ListenUnlikeTrackEvent>(_onUnlikeTrack);
    on<ListenNextTrackEvent>(_onNextTrack);
    on<ListenPreviousTrackEvent>(_onPreviousTrack);
    on<ListenShuffleToggleEvent>(_onShuffleToggle);
    on<ListenRepeatToggleEvent>(_onRepeatToggle);

    _initializeAudioListeners();
  }

  void _initializeAudioListeners() {
    // Listen to audio service state changes
    _audioStateSubscription = audioService.stateStream.listen((playbackState) {
      if (state is ListenLoaded) {
        final currentState = state as ListenLoaded;
        emit(currentState.copyWith(playbackState: playbackState));
      }
    });

    // Listen to position changes
    _audioPositionSubscription = audioService.positionStream.listen((position) {
      if (state is ListenLoaded) {
        final currentState = state as ListenLoaded;
        emit(currentState.copyWith(position: position));
      }
    });

    // Listen to listen stats for session tracking
    _audioStatsSubscription = audioService.listenStatsStream.listen((stats) {
      if (state is ListenLoaded) {
        final currentState = state as ListenLoaded;
        emit(currentState.copyWith(currentSessionData: stats));
        
        // Check if session ended (indicated by 'isValidForReward' field)
        if (stats.containsKey('isValidForReward')) {
          add(ListenSessionEndedEvent(stats));
        }
      }
    });
  }

  Future<void> _onInitialize(
    ListenInitializeEvent event,
    Emitter<ListenState> emit,
  ) async {
    try {
      emit(ListenLoading());
      
      // Initialize audio service
      await audioService.initialize();
      
      // Load initial tracks
      add(const ListenLoadTracksEvent());
    } catch (e) {
      emit(ListenError(message: 'Failed to initialize audio service', exception: e as Exception?));
    }
  }

  Future<void> _onLoadTracks(
    ListenLoadTracksEvent event,
    Emitter<ListenState> emit,
  ) async {
    try {
      if (state is! ListenLoaded) {
        emit(ListenLoading());
      }

      final tracks = await listenRepository.getTracks(
        genre: event.genre,
        limit: event.limit,
      );

      final currentState = state is ListenLoaded ? state as ListenLoaded : null;
      
      emit(ListenLoaded(
        tracks: tracks,
        filteredTracks: tracks,
        currentTrack: currentState?.currentTrack,
        playbackState: currentState?.playbackState ?? PlaybackState.stopped,
        position: currentState?.position ?? Duration.zero,
        duration: currentState?.duration,
        volume: currentState?.volume ?? 0.8,
        isShuffled: currentState?.isShuffled ?? false,
        repeatMode: currentState?.repeatMode ?? RepeatMode.none,
        likedTrackIds: currentState?.likedTrackIds ?? {},
      ));
    } catch (e) {
      emit(ListenError(message: 'Failed to load tracks', exception: e as Exception?));
    }
  }

  Future<void> _onPlayTrack(
    ListenPlayTrackEvent event,
    Emitter<ListenState> emit,
  ) async {
    try {
      final success = await audioService.playTrack(event.track);
      
      if (!success) {
        emit(ListenPlaybackError(
          message: 'Failed to play track: ${event.track.title}',
          track: event.track,
        ));
        return;
      }

      if (state is ListenLoaded) {
        final currentState = state as ListenLoaded;
        emit(currentState.copyWith(
          currentTrack: event.track,
          playbackState: PlaybackState.playing,
          position: Duration.zero,
          duration: Duration(seconds: event.track.duration),
        ));

        // Track session start
        add(ListenSessionStartedEvent(
          track: event.track,
          startTime: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(ListenPlaybackError(
        message: 'Error playing track: $e',
        track: event.track,
      ));
    }
  }

  Future<void> _onPause(
    ListenPauseEvent event,
    Emitter<ListenState> emit,
  ) async {
    await audioService.pause();
  }

  Future<void> _onResume(
    ListenResumeEvent event,
    Emitter<ListenState> emit,
  ) async {
    await audioService.resume();
  }

  Future<void> _onStop(
    ListenStopEvent event,
    Emitter<ListenState> emit,
  ) async {
    await audioService.stop();
    
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      emit(currentState.copyWith(
        currentTrack: null,
        playbackState: PlaybackState.stopped,
        position: Duration.zero,
        duration: null,
        currentSessionData: null,
      ));
    }
  }

  Future<void> _onSeek(
    ListenSeekEvent event,
    Emitter<ListenState> emit,
  ) async {
    await audioService.seek(event.position);
  }

  Future<void> _onVolumeChange(
    ListenVolumeChangeEvent event,
    Emitter<ListenState> emit,
  ) async {
    await audioService.setVolume(event.volume);
    
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      emit(currentState.copyWith(volume: event.volume));
    }
  }

  Future<void> _onSessionStarted(
    ListenSessionStartedEvent event,
    Emitter<ListenState> emit,
  ) async {
    try {
      await listenRepository.startListenSession(
        trackId: event.track.id,
        startTime: event.startTime,
      );
    } catch (e) {
      debugPrint('Error starting listen session: $e');
    }
  }

  Future<void> _onSessionEnded(
    ListenSessionEndedEvent event,
    Emitter<ListenState> emit,
  ) async {
    try {
      // Validate session for rewards
      add(ListenValidateSessionEvent(event.sessionData));
      
      // Record session in repository
      await listenRepository.endListenSession(event.sessionData);
    } catch (e) {
      debugPrint('Error ending listen session: $e');
    }
  }

  Future<void> _onValidateSession(
    ListenValidateSessionEvent event,
    Emitter<ListenState> emit,
  ) async {
    try {
      final sessionData = event.sessionData;
      final trackId = sessionData['trackId'] as String;
      final duration = sessionData['duration'] as int;
      final volume = sessionData['volume'] as double;
      final startTime = sessionData['startTime'] as int;
      final endTime = sessionData['endTime'] as int;

      // Basic validation
      final isValid = AppUtils.isValidListenSession(
        userId: 'current_user_id', // Would get from auth service
        trackId: trackId,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        hash: AppUtils.generateListenHash('current_user_id', trackId, startTime),
      );

      if (!isValid) {
        emit(const ListenSessionValidated(
          isValid: false,
          invalidReason: 'Session validation failed',
        ));
        return;
      }

      // Check for suspicious activity
      final recentSessions = await listenRepository.getRecentListenSessions();
      final isSuspicious = AppUtils.isSuspiciousActivity(
        recentSessions: recentSessions,
        maxListensPerHour: AppConstants.maxListensPerHour,
        minimumBreakBetweenTracks: AppConstants.minimumBreakBetweenTracks,
      );

      if (isSuspicious) {
        emit(const ListenSessionValidated(
          isValid: false,
          invalidReason: 'Suspicious listening pattern detected',
        ));
        return;
      }

      // Calculate reward amount
      final track = await listenRepository.getTrack(trackId);
      if (track == null) {
        emit(const ListenSessionValidated(
          isValid: false,
          invalidReason: 'Track not found',
        ));
        return;
      }

      final rewardAmount = AppUtils.calculateRewardAmount(
        listenDuration: duration,
        trackDuration: track.duration,
        isNewTrack: true, // Would check user's history
        dailyListenCount: 10, // Would get from user stats
        hasStreakBonus: true, // Would check user's streak
      );

      emit(ListenSessionValidated(
        isValid: true,
        rewardAmount: rewardAmount,
      ));

      // Create reward transaction
      await listenRepository.createRewardTransaction(
        trackId: trackId,
        amount: rewardAmount,
        sessionData: sessionData,
      );

    } catch (e) {
      emit(ListenSessionValidated(
        isValid: false,
        invalidReason: 'Validation error: $e',
      ));
    }
  }

  Future<void> _onSearchTracks(
    ListenSearchTracksEvent event,
    Emitter<ListenState> emit,
  ) async {
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      
      List<Track> filteredTracks;
      if (event.query.isEmpty) {
        filteredTracks = currentState.tracks;
      } else {
        filteredTracks = currentState.tracks.where((track) {
          return track.title.toLowerCase().contains(event.query.toLowerCase()) ||
                 track.artist.toLowerCase().contains(event.query.toLowerCase()) ||
                 track.genre.toLowerCase().contains(event.query.toLowerCase());
        }).toList();
      }

      emit(currentState.copyWith(
        filteredTracks: filteredTracks,
        searchQuery: event.query.isEmpty ? null : event.query,
      ));
    }
  }

  Future<void> _onFilterByGenre(
    ListenFilterByGenreEvent event,
    Emitter<ListenState> emit,
  ) async {
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      
      List<Track> filteredTracks;
      if (event.genre == 'All') {
        filteredTracks = currentState.tracks;
      } else {
        filteredTracks = currentState.tracks
            .where((track) => track.genre == event.genre)
            .toList();
      }

      emit(currentState.copyWith(
        filteredTracks: filteredTracks,
        currentGenreFilter: event.genre == 'All' ? null : event.genre,
      ));
    }
  }

  Future<void> _onLikeTrack(
    ListenLikeTrackEvent event,
    Emitter<ListenState> emit,
  ) async {
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      final newLikedTracks = Set<String>.from(currentState.likedTrackIds)
        ..add(event.trackId);

      emit(currentState.copyWith(likedTrackIds: newLikedTracks));
      
      try {
        await listenRepository.likeTrack(event.trackId);
      } catch (e) {
        // Revert on error
        final revertedLikedTracks = Set<String>.from(newLikedTracks)
          ..remove(event.trackId);
        emit(currentState.copyWith(likedTrackIds: revertedLikedTracks));
      }
    }
  }

  Future<void> _onUnlikeTrack(
    ListenUnlikeTrackEvent event,
    Emitter<ListenState> emit,
  ) async {
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      final newLikedTracks = Set<String>.from(currentState.likedTrackIds)
        ..remove(event.trackId);

      emit(currentState.copyWith(likedTrackIds: newLikedTracks));
      
      try {
        await listenRepository.unlikeTrack(event.trackId);
      } catch (e) {
        // Revert on error
        final revertedLikedTracks = Set<String>.from(newLikedTracks)
          ..add(event.trackId);
        emit(currentState.copyWith(likedTrackIds: revertedLikedTracks));
      }
    }
  }

  Future<void> _onNextTrack(
    ListenNextTrackEvent event,
    Emitter<ListenState> emit,
  ) async {
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      final nextTrack = currentState.nextTrack;
      
      if (nextTrack != null) {
        add(ListenPlayTrackEvent(nextTrack));
      } else if (currentState.repeatMode == RepeatMode.all && 
                 currentState.filteredTracks.isNotEmpty) {
        add(ListenPlayTrackEvent(currentState.filteredTracks.first));
      }
    }
  }

  Future<void> _onPreviousTrack(
    ListenPreviousTrackEvent event,
    Emitter<ListenState> emit,
  ) async {
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      final previousTrack = currentState.previousTrack;
      
      if (previousTrack != null) {
        add(ListenPlayTrackEvent(previousTrack));
      } else if (currentState.repeatMode == RepeatMode.all && 
                 currentState.filteredTracks.isNotEmpty) {
        add(ListenPlayTrackEvent(currentState.filteredTracks.last));
      }
    }
  }

  Future<void> _onShuffleToggle(
    ListenShuffleToggleEvent event,
    Emitter<ListenState> emit,
  ) async {
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      final newShuffled = !currentState.isShuffled;
      
      List<Track> newFilteredTracks = List.from(currentState.filteredTracks);
      if (newShuffled) {
        newFilteredTracks.shuffle();
      } else {
        // Restore original order based on current filter
        if (currentState.currentGenreFilter != null) {
          newFilteredTracks = currentState.tracks
              .where((track) => track.genre == currentState.currentGenreFilter)
              .toList();
        } else {
          newFilteredTracks = List.from(currentState.tracks);
        }
      }

      emit(currentState.copyWith(
        isShuffled: newShuffled,
        filteredTracks: newFilteredTracks,
      ));
    }
  }

  Future<void> _onRepeatToggle(
    ListenRepeatToggleEvent event,
    Emitter<ListenState> emit,
  ) async {
    if (state is ListenLoaded) {
      final currentState = state as ListenLoaded;
      emit(currentState.copyWith(repeatMode: event.mode));
    }
  }

  @override
  Future<void> close() {
    _audioStateSubscription?.cancel();
    _audioPositionSubscription?.cancel();
    _audioStatsSubscription?.cancel();
    return super.close();
  }
}