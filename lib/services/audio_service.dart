import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:mtm/core/constants/constants.dart';
import 'package:mtm/shared/track/track.dart';

enum PlaybackState { stopped, playing, paused, buffering, error }

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  AudioSession? _session;
  
  // Current track and state
  Track? _currentTrack;
  PlaybackState _playbackState = PlaybackState.stopped;
  
  // Listen session tracking
  DateTime? _sessionStartTime;
  Timer? _progressTimer;
  int _totalListenTime = 0;
  double _lastValidVolume = 0.8;
  
  // Stream controllers
  final StreamController<Track?> _trackController = StreamController.broadcast();
  final StreamController<PlaybackState> _stateController = StreamController.broadcast();
  final StreamController<Duration> _positionController = StreamController.broadcast();
  final StreamController<Duration?> _durationController = StreamController.broadcast();
  final StreamController<double> _volumeController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _listenStatsController = StreamController.broadcast();

  // Getters
  Track? get currentTrack => _currentTrack;
  PlaybackState get playbackState => _playbackState;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  double get volume => _player.volume;
  bool get isPlaying => _playbackState == PlaybackState.playing;
  bool get isPaused => _playbackState == PlaybackState.paused;

  // Streams
  Stream<Track?> get trackStream => _trackController.stream;
  Stream<PlaybackState> get stateStream => _stateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<double> get volumeStream => _volumeController.stream;
  Stream<Map<String, dynamic>> get listenStatsStream => _listenStatsController.stream;

  Future<void> initialize() async {
    try {
      // Configure audio session
      _session = await AudioSession.instance;
      await _session!.configure(const AudioSessionConfiguration.music());

      // Set up player listeners
      _player.playbackEventStream.listen(_handlePlaybackEvent);
      _player.positionStream.listen(_positionController.add);
      _player.durationStream.listen(_durationController.add);
      
      // Set initial volume
      await _player.setVolume(_lastValidVolume);
      _volumeController.add(_lastValidVolume);

    } catch (e) {
      debugPrint('Error initializing audio service: $e');
    }
  }

  void _handlePlaybackEvent(PlaybackEvent event) {
    final state = _player.playerState;
    
    PlaybackState newState;
    if (state.playing) {
      if (state.processingState == ProcessingState.buffering) {
        newState = PlaybackState.buffering;
      } else {
        newState = PlaybackState.playing;
      }
    } else if (state.processingState == ProcessingState.completed) {
      newState = PlaybackState.stopped;
      _handleTrackCompleted();
    } else {
      newState = PlaybackState.paused;
    }

    if (newState != _playbackState) {
      _playbackState = newState;
      _stateController.add(_playbackState);
      
      // Handle session tracking
      if (newState == PlaybackState.playing) {
        _startListenSession();
      } else {
        _pauseListenSession();
      }
    }
  }

  Future<bool> playTrack(Track track) async {
    try {
      // End current session if any
      if (_currentTrack != null) {
        await _endListenSession();
      }

      _currentTrack = track;
      _trackController.add(_currentTrack);

      // Load and play the track
      await _player.setUrl(track.audioUrl);
      await _player.play();

      debugPrint('Started playing: ${track.title} by ${track.artist}');
      return true;
    } catch (e) {
      debugPrint('Error playing track: $e');
      _playbackState = PlaybackState.error;
      _stateController.add(_playbackState);
      return false;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing track: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('Error resuming track: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      await _endListenSession();
    } catch (e) {
      debugPrint('Error stopping track: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      // Validate volume for anti-bot measures
      if (volume < AppConstants.minimumVolume) {
        debugPrint('Volume too low for reward eligibility: $volume');
      }
      
      await _player.setVolume(volume);
      _lastValidVolume = volume;
      _volumeController.add(volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  void _startListenSession() {
    if (_sessionStartTime == null && _currentTrack != null) {
      _sessionStartTime = DateTime.now();
      _totalListenTime = 0;
      
      // Start progress tracking timer
      _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _totalListenTime++;
        _emitListenStats();
      });
      
      debugPrint('Started listen session for: ${_currentTrack!.title}');
    }
  }

  void _pauseListenSession() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  Future<void> _endListenSession() async {
    if (_sessionStartTime != null && _currentTrack != null) {
      _progressTimer?.cancel();
      _progressTimer = null;

      final endTime = DateTime.now();
      final sessionDuration = endTime.difference(_sessionStartTime!).inSeconds;
      
      // Validate minimum listen time for rewards
      if (sessionDuration >= AppConstants.minimumListenDuration) {
        await _recordListenSession(
          track: _currentTrack!,
          startTime: _sessionStartTime!,
          endTime: endTime,
          duration: sessionDuration,
          volume: _lastValidVolume,
        );
      }

      _sessionStartTime = null;
      _totalListenTime = 0;
      debugPrint('Ended listen session for: ${_currentTrack!.title}');
    }
  }

  Future<void> _recordListenSession({
    required Track track,
    required DateTime startTime,
    required DateTime endTime,
    required int duration,
    required double volume,
  }) async {
    try {
      // This would normally emit an event to be handled by the ListenBloc
      // For now, we'll emit stats that can be picked up by listeners
      final sessionData = {
        'trackId': track.id,
        'artistId': track.artistId,
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
        'duration': duration,
        'volume': volume,
        'isValidForReward': duration >= AppConstants.minimumListenDuration && volume >= AppConstants.minimumVolume,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _listenStatsController.add(sessionData);
      debugPrint('Recorded listen session: $sessionData');
    } catch (e) {
      debugPrint('Error recording listen session: $e');
    }
  }

  void _handleTrackCompleted() {
    debugPrint('Track completed: ${_currentTrack?.title}');
    _endListenSession();
  }

  void _emitListenStats() {
    if (_currentTrack != null && _sessionStartTime != null) {
      final stats = {
        'trackId': _currentTrack!.id,
        'currentPosition': _player.position.inSeconds,
        'totalDuration': _player.duration?.inSeconds ?? 0,
        'listenTime': _totalListenTime,
        'volume': _lastValidVolume,
        'isPlaying': isPlaying,
      };
      _listenStatsController.add(stats);
    }
  }

  // Get current listen session data
  Map<String, dynamic>? getCurrentSessionData() {
    if (_currentTrack == null || _sessionStartTime == null) return null;
    
    return {
      'trackId': _currentTrack!.id,
      'startTime': _sessionStartTime!.millisecondsSinceEpoch,
      'currentDuration': _totalListenTime,
      'volume': _lastValidVolume,
      'position': _player.position.inSeconds,
      'totalDuration': _player.duration?.inSeconds ?? 0,
    };
  }

  // Validate if current session is eligible for rewards
  bool isCurrentSessionEligible() {
    final sessionData = getCurrentSessionData();
    if (sessionData == null) return false;
    
    final duration = sessionData['currentDuration'] as int;
    final volume = sessionData['volume'] as double;
    
    return duration >= AppConstants.minimumListenDuration && 
           volume >= AppConstants.minimumVolume;
  }

  Future<void> dispose() async {
    try {
      await _endListenSession();
      _progressTimer?.cancel();
      await _player.dispose();
      await _trackController.close();
      await _stateController.close();
      await _positionController.close();
      await _durationController.close();
      await _volumeController.close();
      await _listenStatsController.close();
    } catch (e) {
      debugPrint('Error disposing audio service: $e');
    }
  }
}