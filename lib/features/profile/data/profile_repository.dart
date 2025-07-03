import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mtm/services/user_service.dart';
import 'package:mtm/shared/user/user.dart';

class ProfileRepository {
  final FlutterSecureStorage secureStorage;
  final UserService _userService = UserService();

  ProfileRepository({required this.secureStorage});

  Future<MTMUser?> getCurrentUser() async {
    return await _userService.getCurrentUser();
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;

      return await _userService.updateUserPreferences(
        userId: currentUser.id,
        preferences: updates['preferences'] ?? currentUser.preferences,
      );
    } catch (e) {
      return false;
    }
  }
}