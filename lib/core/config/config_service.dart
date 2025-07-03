import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ConfigService {
  final _doc =
      FirebaseFirestore.instance.collection('app_config').doc('global');

  Future<bool> isKillSwitchEnabled() async {
    try {
      final docSnap = await _doc.get();
      final killSwitch = docSnap.data()?['kill_switch'] == true;

      final info = await PackageInfo.fromPlatform();
      final current = info.version;
      final killBelow = docSnap.data()?['kill_below_version'];

      if (killBelow != null && _compareVersions(current, killBelow) < 0) {
        return true;
      }

      return killSwitch;
    } catch (e) {
      print('❌ Error checking kill switch: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getRewardConfig() async {
    try {
      final docSnap = await _doc.get();
      return docSnap.data()?['rewards'] as Map<String, dynamic>?;
    } catch (e) {
      print('❌ Error fetching reward config: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getListeningConfig() async {
    try {
      final docSnap = await _doc.get();
      return docSnap.data()?['listening'] as Map<String, dynamic>?;
    } catch (e) {
      print('❌ Error fetching listening config: $e');
      return null;
    }
  }

  Future<List<String>?> getBannedDomains() async {
    try {
      final docSnap = await _doc.get();
      final domains = docSnap.data()?['banned_domains'] as List<dynamic>?;
      return domains?.cast<String>();
    } catch (e) {
      print('❌ Error fetching banned domains: $e');
      return null;
    }
  }

  int _compareVersions(String a, String b) {
    try {
      final aParts = _safeSplitVersion(a);
      final bParts = _safeSplitVersion(b);

      for (int i = 0; i < 3; i++) {
        final diff = aParts[i] - bParts[i];
        if (diff != 0) return diff;
      }
      return 0;
    } catch (e) {
      print('⚠️ Version comparison failed: $e');
      return -1;
    }
  }

  List<int> _safeSplitVersion(String version) {
    final parts = version.split('.');
    while (parts.length < 3) {
      parts.add('0');
    }
    return parts.take(3).map((e) => int.tryParse(e) ?? 0).toList();
  }

  Future<bool> isAppOutdated() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      final docSnap = await _doc.get();
      final data = docSnap.data();
      if (data == null) {
        print('⚠️ Config doc missing or null');
        return false;
      }

      final minVersion = data['min_supported_version'];
      if (minVersion == null) {
        print('⚠️ No min_supported_version set');
        return false;
      }

      final result = _compareVersions(current, minVersion);
      print(
          '🔍 Version check: current=$current vs required=$minVersion → result=$result');
      return result < 0;
    } catch (e) {
      print('❌ Error checking version: $e');
      return false;
    }
  }
}