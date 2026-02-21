import 'package:isar/isar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/local_models.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import 'sources_api.dart';
import 'file_service.dart';
import 'library_api.dart';

class MangaRepository {
  final Isar isar;
  final SourcesApi api;
  final FileService fileService;
  final LibraryApi libraryApi;

  MangaRepository({
    required this.isar,
    required this.api,
    required this.fileService,
    required this.libraryApi,
  });

  Future<LocalManga?> getMangaDetails(String sourceId, String mangaId) async {
    final connectivity = await Connectivity().checkConnectivity();
    final bool isOnline = connectivity != ConnectivityResult.none;

    if (isOnline) {
      try {
        final remote = await api.getMangaDetails(sourceId, mangaId);
        return await _cacheManga(remote);
      } catch (e) {
        print('Error fetching remote manga details: $e');
      }
    }

    return await isar.localMangas.filter()
        .sourceIdEqualTo(sourceId)
        .mangaIdEqualTo(mangaId)
        .findFirst();
  }

  Future<LocalManga> _cacheManga(Manga manga) async {
    final existing = await isar.localMangas.filter()
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
      await isar.localMangas.put(local);
    });

    if (manga.thumbnailUrl != null && (existing?.thumbnailUrl != manga.thumbnailUrl || existing?.thumbnailLocalPath == null)) {
      final localPath = await fileService.downloadFile(
        manga.thumbnailUrl,
        'thumbnails/${manga.sourceId}/${manga.id}.jpg'
      );
      if (localPath != null) {
        local.thumbnailLocalPath = localPath;
        await isar.writeTxn(() => isar.localMangas.put(local));
      }
    }
    return local;
  }

  Future<List<LocalChapter>> getChapters(String sourceId, String mangaId) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      try {
        final remoteChapters = await api.getChapters(sourceId, mangaId);
        await isar.writeTxn(() async {
          for (var remote in remoteChapters) {
            final existing = await isar.localChapters.filter()
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

            await isar.localChapters.put(local);
          }
        });
      } catch (e) {
        print('Error fetching chapters: $e');
      }
    }

    return await isar.localChapters.filter()
        .sourceIdEqualTo(sourceId)
        .mangaIdEqualTo(mangaId)
        .sortByChapterNumberDesc()
        .findAll();
  }

  Future<void> downloadChapter(String token, String sourceId, String mangaId, String chapterId) async {
    final pages = await api.getPages(sourceId, chapterId);

    // 1. Save page records
    await isar.writeTxn(() async {
      for (var page in pages) {
        final localPage = LocalPage()
          ..chapterId = chapterId
          ..index = page.index
          ..imageRemoteUrl = page.imageUrl;
        await isar.localPages.put(localPage);
      }
    });

    // 2. Download images
    for (var page in pages) {
      final localPath = await fileService.downloadFile(
        page.imageUrl,
        'downloads/$sourceId/$mangaId/$chapterId/page${page.index.toString().padLeft(3, '0')}.jpg'
      );
      if (localPath != null) {
        final lp = await isar.localPages.filter().chapterIdEqualTo(chapterId).indexEqualTo(page.index).findFirst();
        if (lp != null) {
          lp.imageLocalPath = localPath;
          await isar.writeTxn(() => isar.localPages.put(lp));
        }
      }
    }

    // 3. Mark as downloaded
    final chapter = await isar.localChapters.filter()
        .sourceIdEqualTo(sourceId)
        .mangaIdEqualTo(mangaId)
        .chapterIdEqualTo(chapterId)
        .findFirst();
    if (chapter != null) {
      chapter.downloaded = true;
      await isar.writeTxn(() => isar.localChapters.put(chapter));
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
    return await isar.localPages.filter().chapterIdEqualTo(chapterId).sortByIndex().findAll();
  }
}
