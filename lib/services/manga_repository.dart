import 'package:isar/isar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/local_models.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import 'sources_api.dart';
import 'file_service.dart';
import 'library_api.dart';
import 'sync_manager.dart';

class MangaRepository {
  final Isar isar;
  final SourcesApi api;
  final FileService fileService;
  final LibraryApi libraryApi;
  final SyncManager? syncManager; // Optional, can be injected

  MangaRepository({
    required this.isar,
    required this.api,
    required this.fileService,
    required this.libraryApi,
    this.syncManager,
  });

  Future<void> updateReadingProgress({
    required LocalManga manga,
    required String chapterId,
    required int pageIndex,
    String? token, // Auth token for syncing
    bool? isRead,
  }) async {
    final now = DateTime.now();

    // 1. Update LocalManga
    manga.lastReadAt = now;
    await isar.writeTxn(() async {
      await isar.collection<LocalManga>().put(manga);
    });

    // 2. Update LocalChapter
    final chapter = await isar
        .collection<LocalChapter>()
        .filter()
        .sourceIdEqualTo(manga.sourceId)
        .mangaIdEqualTo(manga.mangaId)
        .chapterIdEqualTo(chapterId)
        .findFirst();

    if (chapter != null) {
      chapter.lastReadAt = now;
      chapter.lastPageRead = pageIndex;
      if (isRead != null) chapter.isRead = isRead;
      await isar.writeTxn(() async {
        await isar.collection<LocalChapter>().put(chapter);
      });
    } else {
      // If chapter doesn't exist locally (streaming), create a skeleton
      final newChapter = LocalChapter()
        ..chapterId = chapterId
        ..mangaId = manga.mangaId
        ..sourceId = manga.sourceId
        ..name =
            "Chapter" // Placeholder, should be updated when chapter details are fetched
        ..chapterNumber =
        0 // Placeholder
        ..dateUpload = now.millisecondsSinceEpoch
        ..lastReadAt = now
        ..lastPageRead = pageIndex
        ..isRead = isRead ?? false;

      await isar.writeTxn(() async {
        await isar.collection<LocalChapter>().put(newChapter);
      });
    }

    // 3. Update LocalLibraryEntry (if exists)
    final libraryEntry = await isar
        .collection<LocalLibraryEntry>()
        .filter()
        .mangaIdEqualTo(manga.mangaId)
        .sourceIdEqualTo(manga.sourceId)
        .findFirst();

    if (libraryEntry != null) {
      libraryEntry.lastReadAt = now;
      await isar.writeTxn(() async {
        await isar.collection<LocalLibraryEntry>().put(libraryEntry);
      });
    }

    // 4. Sync with Backend
    if (syncManager != null) {
      final payload = {
        'mangaId': manga.mangaId,
        'sourceId': manga.sourceId,
        'chapterId': chapterId,
        'pageNumber': pageIndex,
        'lastReadAt': now.toIso8601String(),
        if (isRead != null) 'isRead': isRead,
      };

      final connectivity = await Connectivity().checkConnectivity();
      if (token != null && !connectivity.contains(ConnectivityResult.none)) {
        try {
          await libraryApi.syncHistory(
            token: token,
            mangaId: manga.mangaId,
            sourceId: manga.sourceId,
            chapterId: chapterId,
            pageNumber: pageIndex,
            lastReadAt: now,
            isRead: isRead,
          );
        } catch (e) {
          // If direct sync fails, queue it
          await syncManager!.addToQueue('UPDATE_HISTORY', payload);
        }
      } else {
        await syncManager!.addToQueue('UPDATE_HISTORY', payload);
      }
    }
  }

  Future<LocalManga?> getMangaDetails(String sourceId, String mangaId) async {
    final connectivity = await Connectivity().checkConnectivity();
    final bool isOnline = !connectivity.contains(ConnectivityResult.none);

    if (isOnline) {
      try {
        final remote = await api.getMangaDetails(sourceId, mangaId);
        return await _cacheManga(remote);
      } catch (e) {
        print('Error fetching remote manga details: $e');
      }
    }

    return await isar
        .collection<LocalManga>()
        .filter()
        .sourceIdEqualTo(sourceId)
        .mangaIdEqualTo(mangaId)
        .findFirst();
  }

  Future<LocalManga> _cacheManga(Manga manga) async {
    final existing = await isar
        .collection<LocalManga>()
        .filter()
        .sourceIdEqualTo(manga.sourceId)
        .mangaIdEqualTo(manga.id)
        .findFirst();

    final local = (existing ?? LocalManga())
      ..mangaId = manga.id
      ..sourceId = manga.sourceId
      ..title = manga.title
      ..description = manga.description
      ..thumbnailUrl = manga.thumbnailUrl
      ..author = manga.author
      ..artist = manga.artist
      ..status = manga.status
      ..genres = manga.genres;

    await isar.writeTxn(() async {
      await isar.collection<LocalManga>().put(local);
    });

    if (manga.thumbnailUrl != null &&
        (existing?.thumbnailUrl != manga.thumbnailUrl ||
            existing?.thumbnailLocalPath == null)) {
      final localPath = await fileService.downloadFile(
        manga.thumbnailUrl,
        'thumbnails/${manga.sourceId}/${manga.id}.jpg',
      );
      if (localPath != null) {
        local.thumbnailLocalPath = localPath;
        await isar.writeTxn(() => isar.collection<LocalManga>().put(local));
      }
    }
    return local;
  }

  Future<List<LocalChapter>> getChapters(
      String sourceId,
      String mangaId,
      ) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (!connectivity.contains(ConnectivityResult.none)) {
      try {
        final remoteChapters = await api.getChapters(sourceId, mangaId);
        await isar.writeTxn(() async {
          for (var remote in remoteChapters) {
            final existing = await isar
                .collection<LocalChapter>()
                .filter()
                .sourceIdEqualTo(sourceId)
                .mangaIdEqualTo(mangaId)
                .chapterIdEqualTo(remote.id)
                .findFirst();

            final local = (existing ?? LocalChapter())
              ..chapterId = remote.id
              ..mangaId = mangaId
              ..sourceId = sourceId
              ..name = remote.name
              ..chapterNumber = remote.chapterNumber
              ..dateUpload = remote.dateUpload
              ..scanlator = remote.scanlator;

            await isar.collection<LocalChapter>().put(local);
          }
        });
      } catch (e) {
        print('Error fetching chapters: $e');
      }
    }

    return await isar
        .collection<LocalChapter>()
        .filter()
        .sourceIdEqualTo(sourceId)
        .mangaIdEqualTo(mangaId)
        .sortByChapterNumberDesc()
        .findAll();
  }

  Future<void> downloadChapter(
      String token,
      String sourceId,
      String mangaId,
      String chapterId,
      ) async {
    final pages = await api.getPages(sourceId, chapterId);

    // 1. Save page records
    await isar.writeTxn(() async {
      for (var page in pages) {
        final localPage = LocalPage()
          ..chapterId = chapterId
          ..index = page.index
          ..imageRemoteUrl = page.imageUrl;
        await isar.collection<LocalPage>().put(localPage);
      }
    });

    // 2. Download images
    for (var page in pages) {
      final localPath = await fileService.downloadFile(
        page.imageUrl,
        'downloads/$sourceId/$mangaId/$chapterId/page${page.index.toString().padLeft(3, '0')}.jpg',
      );
      if (localPath != null) {
        final lp = await isar
            .collection<LocalPage>()
            .filter()
            .chapterIdEqualTo(chapterId)
            .indexEqualTo(page.index)
            .findFirst();
        if (lp != null) {
          lp.imageLocalPath = localPath;
          await isar.writeTxn(() => isar.collection<LocalPage>().put(lp));
        }
      }
    }

    // 3. Mark as downloaded
    final chapter = await isar
        .collection<LocalChapter>()
        .filter()
        .sourceIdEqualTo(sourceId)
        .mangaIdEqualTo(mangaId)
        .chapterIdEqualTo(chapterId)
        .findFirst();
    if (chapter != null) {
      chapter.downloaded = true;
      await isar.writeTxn(() => isar.collection<LocalChapter>().put(chapter));
    }

    // 4. Notify server (optional but requested)
    try {
      await libraryApi.downloadChapter(
        token: token,
        sourceId: sourceId,
        mangaId: mangaId,
        chapterId: chapterId,
      );
    } catch (e) {
      print('Failed to notify server of download: $e');
    }
  }

  Future<List<LocalPage>> getChapterPages(String chapterId) async {
    return await isar
        .collection<LocalPage>()
        .filter()
        .chapterIdEqualTo(chapterId)
        .sortByIndex()
        .findAll();
  }

  Future<void> toggleChapterBookmark(
      LocalChapter chapter,
      bool value, {
        String? token,
      }) async {
    chapter.isBookmarked = value;
    await isar.writeTxn(() async {
      await isar.collection<LocalChapter>().put(chapter);
    });

    if (syncManager != null) {
      final payload = {
        'mangaId': chapter.mangaId,
        'sourceId': chapter.sourceId,
        'chapterId': chapter.chapterId,
        'pageNumber': chapter.lastPageRead ?? 0,
        'lastReadAt': DateTime.now().toIso8601String(),
        'isBookmarked': value,
      };

      final connectivity = await Connectivity().checkConnectivity();
      if (token != null && !connectivity.contains(ConnectivityResult.none)) {
        try {
          await libraryApi.syncHistory(
            token: token,
            mangaId: chapter.mangaId,
            sourceId: chapter.sourceId,
            chapterId: chapter.chapterId,
            pageNumber: chapter.lastPageRead ?? 0,
            lastReadAt: DateTime.now(),
            isBookmarked: value,
          );
        } catch (e) {
          await syncManager!.addToQueue('UPDATE_HISTORY', payload);
        }
      } else {
        await syncManager!.addToQueue('UPDATE_HISTORY', payload);
      }
    }
  }

  Future<void> toggleChapterRead(
      LocalChapter chapter,
      bool value, {
        String? token,
      }) async {
    chapter.isRead = value;
    await isar.writeTxn(() async {
      await isar.collection<LocalChapter>().put(chapter);
    });

    if (syncManager != null) {
      final payload = {
        'mangaId': chapter.mangaId,
        'sourceId': chapter.sourceId,
        'chapterId': chapter.chapterId,
        'pageNumber': chapter.lastPageRead ?? 0,
        'lastReadAt': DateTime.now().toIso8601String(),
        'isRead': value,
      };

      final connectivity = await Connectivity().checkConnectivity();
      if (token != null && !connectivity.contains(ConnectivityResult.none)) {
        try {
          await libraryApi.syncHistory(
            token: token,
            mangaId: chapter.mangaId,
            sourceId: chapter.sourceId,
            chapterId: chapter.chapterId,
            pageNumber: chapter.lastPageRead ?? 0,
            lastReadAt: DateTime.now(),
            isRead: value,
          );
        } catch (e) {
          await syncManager!.addToQueue('UPDATE_HISTORY', payload);
        }
      } else {
        await syncManager!.addToQueue('UPDATE_HISTORY', payload);
      }
    }
  }
}
