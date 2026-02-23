import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/user_preferences.dart';
import '../services/auth_api.dart';
import '../services/api_constants.dart';

class AuthProvider with ChangeNotifier {
  static const String _webClientId = '887783028868-hgp7fi78npk9otdkk6hil8ot74asaj83.apps.googleusercontent.com';

  final AuthApi _authApi = AuthApi(
    baseUrl: ApiConstants.baseUrl,
  );
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final Future<void> Function()? onLogout;

  User? _user;
  String? _token;
  UserPreferences? _preferences;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _user;
  String? get token => _token;
  UserPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthProvider({this.onLogout}) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: _webClientId,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint("GoogleSignIn initialization failed: $e");
    }
    await _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('accessToken');
    if (_token != null) {
      try {
        _user = await _authApi.getMe(_token!);
        await fetchPreferences();
        notifyListeners();
      } catch (e) {
        _token = null;
        await prefs.remove('accessToken');
        notifyListeners();
      }
    }
  }

  Future<void> fetchPreferences() async {
    if (_token == null) return;
    try {
      _preferences = await _authApi.getPreferences(_token!);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching preferences: $e");
    }
  }

  Future<void> updatePreferences(Map<String, dynamic> updates) async {
    if (_token == null) return;
    try {
      _preferences = await _authApi.updatePreferences(_token!, updates);
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating preferences: $e");
      rethrow;
    }
  }

  Future<void> updateSourcePreference(String sourceId, {bool? enabled, bool? pinned}) async {
    if (_token == null || _preferences == null) return;

    final currentPrefs = _preferences!.sourcePreferences[sourceId] ?? SourcePreference();
    final newPrefs = SourcePreference(
      enabled: enabled ?? currentPrefs.enabled,
      pinned: pinned ?? currentPrefs.pinned,
    );

    try {
      await updatePreferences({
        'source_preferences': {
          sourceId: newPrefs.toJson(),
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!_isInitialized) {
        await _googleSignIn.initialize(serverClientId: _webClientId);
        _isInitialized = true;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google returned a null ID Token. Check your SHA-1 fingerprint in Google Cloud Console.');
      }

      final authResponse = await _authApi.loginWithGoogle(idToken);
      _user = authResponse.user;
      _token = authResponse.accessToken;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _token!);

      await fetchPreferences();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    if (onLogout != null) {
      await onLogout!();
    }

    _user = null;
    _token = null;
    _preferences = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    notifyListeners();
  }

  Future<void> updateProfile({
    String? username,
    String? bio,
    File? avatar,
    File? banner,
  }) async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await _authApi.updateProfile(
        token: _token!,
        username: username,
        bio: bio,
        avatar: avatar,
        banner: banner,
      );
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
