import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user.dart';
import '../models/user_preferences.dart';
import 'api_constants.dart';

class AuthApi {
  final String baseUrl;

  AuthApi({this.baseUrl = ApiConstants.baseUrl});

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    try {
      print('Attempting login at: $baseUrl/auth/google');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': idToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        print('Backend Error: Status ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Server Error (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      print('Connection Refused: Is your backend running? $e');
      throw Exception('Cannot reach server. Ensure backend is running at $baseUrl');
    } catch (e) {
      print('Unexpected Login Error: $e');
      rethrow;
    }
  }

  Future<User> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<User> updateProfile({
    required String token,
    String? username,
    String? bio,
    File? avatar,
    File? banner,
  }) async {
    try {
      var request = http.MultipartRequest('PATCH', Uri.parse('$baseUrl/user/profile'));
      request.headers['Authorization'] = 'Bearer $token';

      if (username != null) request.fields['username'] = username;
      if (bio != null) request.fields['bio'] = bio;

      if (avatar != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          avatar.path,
          contentType: MediaType('image', avatar.path.split('.').last),
        ));
      }

      if (banner != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'banner',
          banner.path,
          contentType: MediaType('image', banner.path.split('.').last),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        print('Update Profile Error: ${response.statusCode} - ${response.body}');
        throw Exception(json.decode(response.body)['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Update Profile Exception: $e');
      rethrow;
    }
  }

  // --- User Preferences Endpoints ---

  Future<UserPreferences> getPreferences(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/preferences'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return UserPreferences.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch preferences');
    }
  }

  Future<UserPreferences> updatePreferences(String token, Map<String, dynamic> preferences) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/preferences'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(preferences),
    );

    if (response.statusCode == 200) {
      return UserPreferences.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update preferences');
    }
  }
}
