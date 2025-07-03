part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadEvent extends ProfileEvent {}

class ProfileUpdateEvent extends ProfileEvent {
  final Map<String, dynamic> updates;

  const ProfileUpdateEvent(this.updates);

  @override
  List<Object?> get props => [updates];
}