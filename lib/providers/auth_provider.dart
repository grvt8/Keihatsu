import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_api.dart';

class AuthProvider with ChangeNotifier {
  static const String _webClientId = '887783028868-hgp7fi78npk9otdkk6hil8ot74asaj83.apps.googleusercontent.com';
  
  final AuthApi _authApi = AuthApi(
    baseUrl: 'http://192.168.1.127:3000',
  );
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
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
        notifyListeners();
      } catch (e) {
        _token = null;
        await prefs.remove('accessToken');
        notifyListeners();
      }
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
    _user = null;
    _token = null;
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
