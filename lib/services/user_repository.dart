import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/local_models.dart';
import '../models/user_preferences.dart';
import 'auth_api.dart';
import 'file_service.dart';

class UserRepository {
  final Isar isar;
  final AuthApi api;
  final FileService fileService;

  UserRepository({
    required this.isar,
    required this.api,
    required this.fileService,
  });

  Future<LocalUserPreferences?> getPreferences() async {
    return await isar.localUserPreferences.where().findFirst();
  }

  Future<void> refreshPreferences(String token) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    try {
      final response = await api.getPreferences(token);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await getPreferences() ?? LocalUserPreferences();
        
        prefs.libraryDisplayStyle = data['library_display_style'];
        prefs.sourcePreferencesJson = json.encode(data['source_preferences']);
        
        await isar.writeTxn(() => isar.localUserPreferences.put(prefs));
      }
    } catch (e) {
      print('Error refreshing preferences: $e');
    }
  }

  Future<void> updateSourcePreference(String token, String sourceId, {bool? enabled, bool? pinned}) async {
    final prefs = await getPreferences();
    if (prefs == null) return;

    Map<String, dynamic> sourcePrefs = json.decode(prefs.sourcePreferencesJson);
    final current = sourcePrefs[sourceId] ?? {'enabled': true, 'pinned': false};
    
    sourcePrefs[sourceId] = {
      'enabled': enabled ?? current['enabled'],
      'pinned': pinned ?? current['pinned'],
    };

    prefs.sourcePreferencesJson = json.encode(sourcePrefs);
    await isar.writeTxn(() => isar.localUserPreferences.put(prefs));

    // In a real app, queue a SyncOperation for PUT /user/preferences
  }

  Future<String?> getCachedAvatar(String? remoteUrl) async {
    if (remoteUrl == null) return null;
    final appDir = await fileService.getAppDirectory();
    final fileName = remoteUrl.split('/').last;
    final localPath = '${appDir}/profile/avatar_$fileName';

    // Basic caching logic: check if exists, otherwise download
    final file = await fileService.downloadFile(remoteUrl, 'profile/avatar_$fileName');
    return file;
  }
}
