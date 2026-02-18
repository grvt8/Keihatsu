import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/source.dart';
import '../models/manga.dart';
import '../models/chapter.dart';

class SourcesApi {
  final String baseUrl;

  SourcesApi({this.baseUrl = 'http://192.168.59.84:3000'});

  Future<List<Source>> getSources() async {
    final response = await http.get(Uri.parse('$baseUrl/sources'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Source.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sources');
    }
  }

  Future<MangasPage> getMangaList(String sourceId, String type, {int page = 1, String? q}) async {
    final queryParams = {
      'type': type,
      'page': page.toString(),
    };
    if (q != null) queryParams['q'] = q;

    final uri = Uri.parse('$baseUrl/sources/$sourceId/manga').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return MangasPage.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load manga list');
    }
  }

  Future<Manga> getMangaDetails(String sourceId, String mangaId) async {
    final response = await http.get(Uri.parse('$baseUrl/sources/$sourceId/manga/$mangaId'));

    if (response.statusCode == 200) {
      return Manga.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load manga details');
    }
  }

  Future<List<Chapter>> getChapters(String sourceId, String mangaId) async {
    final response = await http.get(Uri.parse('$baseUrl/sources/$sourceId/manga/$mangaId/chapters'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Chapter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chapters');
    }
  }

  Future<List<ReaderPage>> getPages(String sourceId, String chapterId) async {
    final response = await http.get(Uri.parse('$baseUrl/sources/$sourceId/chapters/$chapterId/pages'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReaderPage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pages');
    }
  }
}
