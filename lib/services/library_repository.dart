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
    return isar.collection<LocalLibraryEntry>().where().watch(fireImmediately: true);
  }

  Future<List<LocalLibraryEntry>> getLibrary({
    bool forceRefresh = false,
    String? token,
    bool? filterDownloaded,
    bool? filterUnread,
    bool? filterStarted,
    bool? filterBookmarked,
    bool? filterCompleted,
    String? sortBy,
    String? order,
    String? search,
  }) async {
    if (forceRefresh && token != null) {
      await refreshLibrary(
        token: token,
        filterDownloaded: filterDownloaded,
        filterUnread: filterUnread,
        filterStarted: filterStarted,
        filterBookmarked: filterBookmarked,
        filterCompleted: filterCompleted,
        sortBy: sortBy,
        order: order,
        search: search,
      );
    }
    
    return await isar.collection<LocalLibraryEntry>().where().findAll();
  }

  Future<void> refreshLibrary({
    required String token,
    bool? filterDownloaded,
    bool? filterUnread,
    bool? filterStarted,
    bool? filterBookmarked,
    bool? filterCompleted,
    String? sortBy,
    String? order,
    String? search,
  }) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      final response = await api.getLibrary(
        token: token,
        filterDownloaded: filterDownloaded,
        filterUnread: filterUnread,
        filterStarted: filterStarted,
        filterBookmarked: filterBookmarked,
        filterCompleted: filterCompleted,
        sortBy: sortBy,
        order: order,
        search: search,
      );

      if (response.statusCode == 200) {
        final List<dynamic> remoteData = json.decode(response.body);
        
        await isar.writeTxn(() async {
          for (var item in remoteData) {
            final mangaId = item['mangaId'];
            final sourceId = item['sourceId'];

            var entry = await isar.collection<LocalLibraryEntry>().filter()
                .mangaIdEqualTo(mangaId)
                .sourceIdEqualTo(sourceId)
                .findFirst() ?? LocalLibraryEntry();

            entry
              ..serverId = item['id']
              ..mangaId = mangaId
              ..sourceId = sourceId
              ..title = item['title']
              ..thumbnailUrl = item['thumbnailUrl']
              ..author = item['author']
              ..language = item['language']
              ..isBookmarked = item['isBookmarked'] ?? true
              ..isUnread = item['isUnread'] ?? true
              ..isStarted = item['isStarted'] ?? false
              ..isCompleted = item['isCompleted'] ?? false
              ..downloadedCount = item['downloadedCount'] ?? 0
              ..unreadCount = item['unreadCount'] ?? 0
              ..totalChapters = item['totalChapters'] ?? 0
              ..lastReadAt = item['lastReadAt'] != null ? DateTime.parse(item['lastReadAt']) : null
              ..lastUpdatedAt = item['lastUpdatedAt'] != null ? DateTime.parse(item['lastUpdatedAt']) : null
              ..dateAddedAt = item['dateAddedAt'] != null ? DateTime.parse(item['dateAddedAt']) : null;
            
            await isar.collection<LocalLibraryEntry>().put(entry);

            if (item['categories'] != null) {
              final List<dynamic> categories = item['categories'];
              await isar.collection<LocalCategoryAssignment>().filter()
                .mangaIdEqualTo(mangaId)
                .sourceIdEqualTo(sourceId)
                .deleteAll();

              for (var catData in categories) {
                final serverCatId = catData['id'];
                var localCat = await isar.collection<LocalCategory>().filter()
                  .serverIdEqualTo(serverCatId)
                  .findFirst();
                
                if (localCat == null) {
                  localCat = LocalCategory()
                    ..serverId = serverCatId
                    ..name = catData['name']
                    ..isSynced = true;
                  await isar.collection<LocalCategory>().put(localCat);
                }

                final assignment = LocalCategoryAssignment()
                  ..mangaId = mangaId
                  ..sourceId = sourceId
                  ..localCategoryId = localCat.id;
                await isar.collection<LocalCategoryAssignment>().put(assignment);
              }
            }
          }
        });
      }
    } catch (e) {
      print('Failed to refresh library: $e');
    }
  }

  Future<void> addToLibrary(String token, Manga manga, {List<String>? categories}) async {
    final entry = LocalLibraryEntry()
      ..mangaId = manga.id
      ..sourceId = manga.sourceId
      ..title = manga.title
      ..thumbnailUrl = manga.thumbnailUrl
      ..author = manga.author
      ..language = manga.lang
      ..isBookmarked = true
      ..dateAddedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.collection<LocalLibraryEntry>().put(entry);
      
      if (categories != null) {
        for (var catName in categories) {
           final cat = await isar.collection<LocalCategory>().filter().nameEqualTo(catName).findFirst();
           if (cat != null) {
             final assignment = LocalCategoryAssignment()
              ..mangaId = manga.id
              ..sourceId = manga.sourceId
              ..localCategoryId = cat.id;
             await isar.collection<LocalCategoryAssignment>().put(assignment);
           }
        }
      }
    });

    await syncManager.addToQueue('ADD_LIBRARY', {
      'mangaId': manga.id,
      'sourceId': manga.sourceId,
      'title': manga.title,
      'thumbnailUrl': manga.thumbnailUrl,
      'author': manga.author,
    });
  }

  Future<void> updateLibraryEntry(String token, String mangaId, Map<String, dynamic> updates) async {
    final entry = await isar.collection<LocalLibraryEntry>().filter().mangaIdEqualTo(mangaId).findFirst();
    if (entry != null) {
      if (updates.containsKey('isBookmarked')) entry.isBookmarked = updates['isBookmarked'];
      if (updates.containsKey('isUnread')) entry.isUnread = updates['isUnread'];
      if (updates.containsKey('isStarted')) entry.isStarted = updates['isStarted'];
      if (updates.containsKey('isCompleted')) entry.isCompleted = updates['isCompleted'];
      
      await isar.writeTxn(() => isar.collection<LocalLibraryEntry>().put(entry));

      if (entry.serverId != null) {
        await syncManager.addToQueue('UPDATE_LIBRARY', {
          'id': entry.serverId,
          'updates': updates,
        });
      }
    }
  }

  Future<void> removeFromLibrary(String token, String mangaId, String sourceId) async {
    final entry = await isar.collection<LocalLibraryEntry>().filter()
        .mangaIdEqualTo(mangaId)
        .sourceIdEqualTo(sourceId)
        .findFirst();

    final serverId = entry?.serverId;

    await isar.writeTxn(() async {
      await isar.collection<LocalLibraryEntry>().filter()
          .mangaIdEqualTo(mangaId)
          .sourceIdEqualTo(sourceId)
          .deleteAll();
      
      await isar.collection<LocalCategoryAssignment>().filter()
          .mangaIdEqualTo(mangaId)
          .sourceIdEqualTo(sourceId)
          .deleteAll();
    });

    if (serverId != null) {
      await syncManager.addToQueue('REMOVE_LIBRARY', {
        'id': serverId,
      });
    }
  }

  // --- Category methods for backward compatibility ---

  Future<List<LocalCategory>> getCategories() async {
    return await isar.collection<LocalCategory>().where().findAll();
  }

  Future<void> createCategory(String name) async {
    final category = LocalCategory()..name = name..isSynced = false;
    await isar.writeTxn(() async {
      await isar.collection<LocalCategory>().put(category);
    });
    await syncManager.addToQueue('CREATE_CATEGORY', {'name': name, 'localId': category.id});
  }

  Future<void> updateCategory(String id, String name) async {
    final category = await isar.collection<LocalCategory>().filter().serverIdEqualTo(id).findFirst();
    if (category != null) {
       category.name = name;
       category.isSynced = false;
       await isar.writeTxn(() => isar.collection<LocalCategory>().put(category));
    }
    await syncManager.addToQueue('UPDATE_CATEGORY', {'id': id, 'name': name});
  }

  Future<void> deleteCategory(String id) async {
    await isar.writeTxn(() async {
      await isar.collection<LocalCategory>().filter().serverIdEqualTo(id).deleteAll();
    });
    await syncManager.addToQueue('DELETE_CATEGORY', {'id': id});
  }
}
