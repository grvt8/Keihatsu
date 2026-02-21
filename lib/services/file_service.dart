import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileService {
  final Dio _dio = Dio();

  Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String?> downloadFile(String url, String subPath) async {
    try {
      final appDir = await getAppDirectory();
      final fullPath = p.join(appDir, subPath);
      final file = File(fullPath);

      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      await _dio.download(url, fullPath);
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

  Future<String> getChapterPagePath(String sourceId, String mangaId, String chapterId, int index) async {
    final appDir = await getAppDirectory();
    return p.join(appDir, 'downloads', sourceId, mangaId, chapterId, 'page${index.toString().padLeft(3, '0')}.jpg');
  }

  Future<void> deleteChapter(String sourceId, String mangaId, String chapterId) async {
    final appDir = await getAppDirectory();
    final chapterDir = Directory(p.join(appDir, 'downloads', sourceId, mangaId, chapterId));
    if (await chapterDir.exists()) {
      await chapterDir.delete(recursive: true);
    }
  }
}
