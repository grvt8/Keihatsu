import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/local_models.dart';
import '../models/manga.dart';
import 'library_api.dart';
import 'sync_manager.dart';

class LibraryRepository {
  final Isar isar;
  final LibraryApi api;
  final SyncManager syncManager;

  LibraryRepository({
    required this.isar,
    required this.api,
    required this.syncManager,
  });

  Stream<List<LocalLibraryEntry>> watchLibrary() {
    return isar.localLibraryEntrys.where().watch(fireImmediately: true);
  }

  Future<List<LocalLibraryEntry>> getLibrary({bool forceRefresh = false, String? token}) async {
    if (forceRefresh && token != null) {
      await refreshLibrary(token);
    }
    return await isar.localLibraryEntrys.where().findAll();
  }

  Future<void> refreshLibrary(String token) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) return;

      final response = await api.getLibrary(token: token);
      if (response.statusCode == 200) {
        final List<dynamic> remoteData = json.decode(response.body);
        
        await isar.writeTxn(() async {
          // Simplistic sync: clear and refill or merge. 
          // For a robust app, you'd compare timestamps or IDs.
          await isar.localLibraryEntrys.clear();
          for (var item in remoteData) {
            final entry = LocalLibraryEntry()
              ..mangaId = item['mangaId']
              ..sourceId = item['sourceId']
              ..title = item['title']
              ..thumbnailUrl = item['thumbnailUrl']
              ..author = item['author']
              ..bookmarked = item['bookmarked'] ?? false;
            await isar.localLibraryEntrys.put(entry);
          }
        });
      }
    } catch (e) {
      print('Failed to refresh library: $e');
    }
  }

  Future<void> addToLibrary(String token, Manga manga) async {
    // 1. Update local DB immediately
    final entry = LocalLibraryEntry()
      ..mangaId = manga.id
      ..sourceId = manga.sourceId
      ..title = manga.title
      ..thumbnailUrl = manga.thumbnailUrl
      ..author = manga.author
      ..bookmarked = true;

    await isar.writeTxn(() => isar.localLibraryEntrys.put(entry));

    // 2. Queue sync operation
    await syncManager.addToQueue('ADD_LIBRARY', {
      'id': manga.id,
      'sourceId': manga.sourceId,
      ...manga.toJson(),
    });
  }

  Future<void> removeFromLibrary(String token, String mangaId, String sourceId) async {
    await isar.writeTxn(() async {
      await isar.localLibraryEntrys.filter()
          .mangaIdEqualTo(mangaId)
          .sourceIdEqualTo(sourceId)
          .deleteAll();
    });

    await syncManager.addToQueue('REMOVE_LIBRARY', {
      'id': mangaId,
      'sourceId': sourceId,
    });
  }

  // Categories
  Future<List<LocalCategory>> getCategories() async {
    return await isar.localCategorys.where().findAll();
  }

  Future<void> createCategory(String name) async {
    final category = LocalCategory()..name = name..isSynced = false;
    int localId;
    await isar.writeTxn(() async {
      localId = await isar.localCategorys.put(category);
    });

    await syncManager.addToQueue('CREATE_CATEGORY', {
      'name': name,
      'localId': category.id,
    });
  }
}
