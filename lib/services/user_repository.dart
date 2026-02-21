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
    return await isar.collection<LocalUserPreferences>().where().findFirst();
  }

  Future<void> refreshPreferences(String token) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    try {
      final prefsData = await api.getPreferences(token);
      await _savePreferencesLocally(prefsData);
    } catch (e) {
      print('Error refreshing preferences: $e');
    }
  }

  Future<void> _savePreferencesLocally(UserPreferences prefsData) async {
    final localPrefs = await getPreferences() ?? LocalUserPreferences();
    
    localPrefs.categoriesDisplayMode = prefsData.categoriesDisplayMode;
    localPrefs.libraryItemsPerRow = prefsData.libraryItemsPerRow;
    localPrefs.overlayShowDownloaded = prefsData.overlayShowDownloaded;
    localPrefs.overlayShowUnread = prefsData.overlayShowUnread;
    localPrefs.overlayShowLanguage = prefsData.overlayShowLanguage;
    localPrefs.tabsShowCategories = prefsData.tabsShowCategories;
    localPrefs.tabsShowItemCount = prefsData.tabsShowItemCount;
    localPrefs.sourcePreferencesJson = json.encode(
      prefsData.sourcePreferences.map((k, v) => MapEntry(k, v.toJson()))
    );
    
    await isar.writeTxn(() => isar.collection<LocalUserPreferences>().put(localPrefs));
  }

  Future<void> updatePreferences(String token, Map<String, dynamic> updates) async {
    try {
      final updatedPrefs = await api.updatePreferences(token, updates);
      await _savePreferencesLocally(updatedPrefs);
    } catch (e) {
      print('Error updating preferences: $e');
    }
  }

  Future<void> updateSourcePreference(String token, String sourceId, {bool? enabled, bool? pinned}) async {
    final prefs = await getPreferences();
    if (prefs == null) return;

    Map<String, dynamic> sourcePrefs = json.decode(prefs.sourcePreferencesJson);
    final current = sourcePrefs[sourceId] ?? {'enabled': true, 'pinned': false};
    
    final newSourcePref = {
      'enabled': enabled ?? current['enabled'],
      'pinned': pinned ?? current['pinned'],
    };

    await updatePreferences(token, {
      'source_preferences': {
        sourceId: newSourcePref
      }
    });
  }

  Future<String?> getCachedAvatar(String? remoteUrl) async {
    if (remoteUrl == null) return null;
    final fileName = remoteUrl.split('/').last;
    final localPath = 'profile/avatar_$fileName';

    final file = await fileService.downloadFile(remoteUrl, localPath);
    return file;
  }
}
