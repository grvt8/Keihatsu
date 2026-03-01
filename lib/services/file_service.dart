import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class FileService {
  final Dio _dio = Dio();
  static const String _publicDirName = 'Keihatsu';

  /// Returns the base directory based on the subPath.
  /// If the path starts with 'downloads/', it targets external storage (visible).
  /// Otherwise, it defaults to the app's internal documents directory.
  Future<Directory> _getBaseDirectory(String subPath) async {
    if (subPath.startsWith('downloads/')) {
      if (Platform.isAndroid) {
        // Target /storage/emulated/0/Keihatsu
        try {
          final directory = Directory('/storage/emulated/0/$_publicDirName');
          // Check if we can actually access it
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          return directory;
        } catch (e) {
          print('Error accessing/creating public directory: $e');
          // Fallback to internal documents directory if external access fails
          // This ensures the app doesn't crash even if permissions are wonky
          return getApplicationDocumentsDirectory();
        }
      }
    }
    return getApplicationDocumentsDirectory();
  }

  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // 1. Android 11+ (API 30+): Manage External Storage
    // First, check if it's already granted.
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    // If denied or restricted, request it.
    if (await Permission.manageExternalStorage.status.isDenied ||
        await Permission.manageExternalStorage.status.isRestricted ||
        await Permission.manageExternalStorage.status.isPermanentlyDenied) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;
    }

    // 2. Android 10 and below: Legacy Storage Permissions
    // Only check this if manageExternalStorage didn't work (or on older OS).
    // Note: On Android 13+, this will likely return denied if not using scoped storage properly,
    // but manageExternalStorage covers the "All files access" case.
    if (await Permission.storage.isGranted) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String?> downloadFile(String url, String subPath) async {
    try {
      // Ensure permissions are granted if writing to external storage
      if (subPath.startsWith('downloads/') && Platform.isAndroid) {
        final hasPermission = await requestStoragePermission();
        if (!hasPermission) {
          print('Storage permission denied for download: $subPath');
          return null;
        }
      }

      final baseDir = await _getBaseDirectory(subPath);

      // If the path starts with 'downloads/', we remove that prefix to avoid double nesting
      // inside the Keihatsu folder if we want Keihatsu/sourceId/...
      // BUT current logic is: subPath = downloads/sourceId/...
      // So if baseDir is .../Keihatsu, we probably want .../Keihatsu/downloads/sourceId/...
      // OR .../Keihatsu/sourceId/...
      // The user said "land under a Keihatsu folder".
      // Let's keep the 'downloads' folder inside Keihatsu for structure: Keihatsu/downloads/...
      // So fullPath = baseDir.path + subPath.

      // However, if _getBaseDirectory returns /storage/emulated/0/Keihatsu
      // and subPath is downloads/..., then result is /storage/emulated/0/Keihatsu/downloads/...
      // This is fine.

      // If _getBaseDirectory returns internal AppDocs, result is AppDocs/downloads/...
      // This is also consistent.

      final fullPath = p.join(baseDir.path, subPath);
      final file = File(fullPath);

      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      await _dio.download(url, fullPath);
      print('DEBUG: File downloaded to: $fullPath');
      return fullPath;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  Future<String> getSourceIconPath(String sourceId) async {
    final appDir = await getAppDirectory();
    return p.join(appDir, 'icons', '$sourceId.png');
  }

  Future<String> getMangaThumbnailPath(String sourceId, String mangaId) async {
    final appDir = await getAppDirectory();
    return p.join(appDir, 'thumbnails', sourceId, '$mangaId.jpg');
  }

  Future<String> getChapterPagePath(
      String sourceId,
      String mangaId,
      String chapterId,
      int index,
      ) async {
    // Sanitize mangaId to prevent nested directories from slashes (e.g., "manhua/ordeal")
    final safeMangaId = mangaId.replaceAll('/', '_');

    // This must match the logic in downloadFile for retrieval
    final subPath =
        'downloads/$sourceId/$safeMangaId/$chapterId/page${index.toString().padLeft(3, '0')}.jpg';
    final baseDir = await _getBaseDirectory(subPath);
    return p.join(baseDir.path, subPath);
  }

  Future<void> deleteChapter(
      String sourceId,
      String mangaId,
      String chapterId,
      ) async {
    // Sanitize mangaId to match creation logic
    final safeMangaId = mangaId.replaceAll('/', '_');

    final chapterSubPath = 'downloads/$sourceId/$safeMangaId/$chapterId';
    final baseDir = await _getBaseDirectory(chapterSubPath);
    final chapterDir = Directory(p.join(baseDir.path, chapterSubPath));

    if (await chapterDir.exists()) {
      await chapterDir.delete(recursive: true);
    }

    // Check if manga folder is empty and delete if so
    final mangaSubPath = 'downloads/$sourceId/$safeMangaId';
    final mangaDir = Directory(p.join(baseDir.path, mangaSubPath));
    if (await mangaDir.exists()) {
      final entities = await mangaDir.list().toList();
      if (entities.isEmpty) {
        await mangaDir.delete();
      }
    }
  }
}
