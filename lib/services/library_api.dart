import 'dart:convert';
import 'package:http/http.dart' as http;

class LibraryApi {
  final String baseUrl;
  LibraryApi({this.baseUrl = 'http://192.168.1.127:3000'});

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // --- Library Endpoints ---

  Future<http.Response> getLibrary({
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
    final queryParams = {
      if (filterDownloaded != null) 'filter_downloaded': filterDownloaded.toString(),
      if (filterUnread != null) 'filter_unread': filterUnread.toString(),
      if (filterStarted != null) 'filter_started': filterStarted.toString(),
      if (filterBookmarked != null) 'filter_bookmarked': filterBookmarked.toString(),
      if (filterCompleted != null) 'filter_completed': filterCompleted.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      if (order != null) 'order': order,
      if (search != null) 'search': search,
    };

    final uri = Uri.parse('$baseUrl/user/library').replace(queryParameters: queryParams);
    return await http.get(uri, headers: _headers(token));
  }

  Future<http.Response> addMangaToLibrary(String token, Map<String, dynamic> mangaData) async {
    return await http.post(
      Uri.parse('$baseUrl/user/library'),
      headers: _headers(token),
      body: json.encode(mangaData),
    );
  }

  Future<http.Response> updateLibraryEntry(String token, String id, Map<String, dynamic> updateData) async {
    return await http.put(
      Uri.parse('$baseUrl/user/library/$id'),
      headers: _headers(token),
      body: json.encode(updateData),
    );
  }

  Future<http.Response> deleteMangaFromLibrary(String token, String id) async {
    return await http.delete(Uri.parse('$baseUrl/user/library/$id'), headers: _headers(token));
  }

  // --- Categories Endpoints ---

  Future<http.Response> getCategories(String token, {bool includeCount = false}) async {
    final uri = Uri.parse('$baseUrl/user/categories').replace(
      queryParameters: {'include_count': includeCount.toString()},
    );
    return await http.get(uri, headers: _headers(token));
  }

  Future<http.Response> createCategory(String token, String name) async {
    return await http.post(
      Uri.parse('$baseUrl/user/categories'),
      headers: _headers(token),
      body: json.encode({'name': name}),
    );
  }

  // ... (Other category methods can follow the same pattern)
}
