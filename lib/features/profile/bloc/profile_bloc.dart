import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mtm/features/profile/data/profile_repository.dart';
import 'package:mtm/shared/user/user.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({
    required this.profileRepository,
  }) : super(ProfileInitial()) {
    on<ProfileLoadEvent>(_onProfileLoad);
    on<ProfileUpdateEvent>(_onProfileUpdate);
  }

  Future<void> _onProfileLoad(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      final user = await profileRepository.getCurrentUser();
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(const ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onProfileUpdate(
    ProfileUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(ProfileLoading());
      
      try {
        final success = await profileRepository.updateProfile(event.updates);
        if (success) {
          final updatedUser = currentState.user.copyWith(
            displayName: event.updates['displayName'] ?? currentState.user.displayName,
            preferences: event.updates['preferences'] ?? currentState.user.preferences,
          );
          emit(ProfileLoaded(updatedUser));
        } else {
          emit(const ProfileError('Failed to update profile'));
        }
      } catch (e) {
        emit(ProfileError('Update failed: $e'));
      }
    }
  }
}