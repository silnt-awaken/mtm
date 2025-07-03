part of 'listen_bloc.dart';

abstract class ListenEvent extends Equatable {
  const ListenEvent();

  @override
  List<Object?> get props => [];
}

class ListenInitializeEvent extends ListenEvent {}

class ListenLoadTracksEvent extends ListenEvent {
  final String? genre;
  final int limit;
  
  const ListenLoadTracksEvent({
    this.genre,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [genre, limit];
}

class ListenPlayTrackEvent extends ListenEvent {
  final Track track;
  
  const ListenPlayTrackEvent(this.track);

  @override
  List<Object?> get props => [track];
}

class ListenPauseEvent extends ListenEvent {}

class ListenResumeEvent extends ListenEvent {}

class ListenStopEvent extends ListenEvent {}

class ListenSeekEvent extends ListenEvent {
  final Duration position;
  
  const ListenSeekEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class ListenVolumeChangeEvent extends ListenEvent {
  final double volume;
  
  const ListenVolumeChangeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ListenSessionStartedEvent extends ListenEvent {
  final Track track;
  final DateTime startTime;
  
  const ListenSessionStartedEvent({
    required this.track,
    required this.startTime,
  });

  @override
  List<Object?> get props => [track, startTime];
}

class ListenSessionEndedEvent extends ListenEvent {
  final Map<String, dynamic> sessionData;
  
  const ListenSessionEndedEvent(this.sessionData);

  @override
  List<Object?> get props => [sessionData];
}

class ListenValidateSessionEvent extends ListenEvent {
  final Map<String, dynamic> sessionData;
  
  const ListenValidateSessionEvent(this.sessionData);

  @override
  List<Object?> get props => [sessionData];
}

class ListenSearchTracksEvent extends ListenEvent {
  final String query;
  
  const ListenSearchTracksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ListenFilterByGenreEvent extends ListenEvent {
  final String genre;
  
  const ListenFilterByGenreEvent(this.genre);

  @override
  List<Object?> get props => [genre];
}

class ListenLikeTrackEvent extends ListenEvent {
  final String trackId;
  
  const ListenLikeTrackEvent(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

class ListenUnlikeTrackEvent extends ListenEvent {
  final String trackId;
  
  const ListenUnlikeTrackEvent(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

class ListenNextTrackEvent extends ListenEvent {}

class ListenPreviousTrackEvent extends ListenEvent {}

class ListenShuffleToggleEvent extends ListenEvent {}

class ListenRepeatToggleEvent extends ListenEvent {
  final RepeatMode mode;
  
  const ListenRepeatToggleEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

enum RepeatMode { none, one, all }