import 'dart:convert';
import 'package:http/http.dart' as http;

class LibraryApi {
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Replace with your backend URL

  // --- Library Endpoints ---

  static Future<http.Response> getLibrary({
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
    return await http.get(uri);
  }

  static Future<http.Response> addMangaToLibrary(Map<String, dynamic> mangaData) async {
    return await http.post(
      Uri.parse('$baseUrl/user/library'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(mangaData),
    );
  }

  static Future<http.Response> updateLibraryEntry(String id, Map<String, dynamic> updateData) async {
    return await http.put(
      Uri.parse('$baseUrl/user/library/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );
  }

  static Future<http.Response> deleteMangaFromLibrary(String id) async {
    return await http.delete(Uri.parse('$baseUrl/user/library/$id'));
  }

  // --- Categories Endpoints ---

  static Future<http.Response> getCategories({bool includeCount = false}) async {
    final uri = Uri.parse('$baseUrl/user/categories').replace(
      queryParameters: {'include_count': includeCount.toString()},
    );
    return await http.get(uri);
  }

  static Future<http.Response> createCategory(String name) async {
    return await http.post(
      Uri.parse('$baseUrl/user/categories'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );
  }

  static Future<http.Response> updateCategory(String id, String name) async {
    return await http.put(
      Uri.parse('$baseUrl/user/categories/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );
  }

  static Future<http.Response> deleteCategory(String id) async {
    return await http.delete(Uri.parse('$baseUrl/user/categories/$id'));
  }

  static Future<http.Response> assignMangaToCategory(String mangaId, String categoryId) async {
    return await http.post(
      Uri.parse('$baseUrl/manga/$mangaId/category/$categoryId'),
    );
  }

  // --- User Preferences Endpoints ---

  static Future<http.Response> getUserPreferences() async {
    return await http.get(Uri.parse('$baseUrl/user/preferences'));
  }

  static Future<http.Response> updateUserPreferences(Map<String, dynamic> preferences) async {
    return await http.put(
      Uri.parse('$baseUrl/user/preferences'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(preferences),
    );
  }
}
