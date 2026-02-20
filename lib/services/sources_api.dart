import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/source.dart';
import '../models/manga.dart';
import '../models/chapter.dart';

class SourcesApi {
  // Using the IP address that was previously working for your physical device (TECNO BG6).
  // If your machine's IP changes, update this string.
  final String baseUrl;

  SourcesApi({this.baseUrl = 'http://192.168.1.127:3000'});

  Future<List<Source>> getSources() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sources')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Source.fromJson(json)).toList();
      }
      throw Exception('Failed to load sources: ${response.statusCode}');
    } catch (e) {
      print('SourcesApi.getSources error: $e');
      rethrow;
    }
  }

  Future<MangasPage> getMangaList(String sourceId, String type, {int page = 1, String? q}) async {
    try {
      final queryParams = {
        'type': type,
        'page': page.toString(),
      };
      if (q != null) queryParams['q'] = q;

      final uri = Uri.parse('$baseUrl/sources/$sourceId/manga').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return MangasPage.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load manga list: ${response.statusCode}');
    } catch (e) {
      print('SourcesApi.getMangaList error: $e');
      rethrow;
    }
  }

  Future<Manga> getMangaDetails(String sourceId, String mangaId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sources/$sourceId/manga/$mangaId')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return Manga.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load manga details: ${response.statusCode}');
    } catch (e) {
      print('SourcesApi.getMangaDetails error: $e');
      rethrow;
    }
  }

  Future<List<Chapter>> getChapters(String sourceId, String mangaId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sources/$sourceId/manga/$mangaId/chapters')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Chapter.fromJson(json)).toList();
      }
      throw Exception('Failed to load chapters: ${response.statusCode}');
    } catch (e) {
      print('SourcesApi.getChapters error: $e');
      rethrow;
    }
  }

  Future<List<ReaderPage>> getPages(String sourceId, String chapterId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sources/$sourceId/chapters/$chapterId/pages')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ReaderPage.fromJson(json)).toList();
      }
      throw Exception('Failed to load pages: ${response.statusCode}');
    } catch (e) {
      print('SourcesApi.getPages error: $e');
      rethrow;
    }
  }
}
