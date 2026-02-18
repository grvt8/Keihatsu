import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manga.dart';

class LibraryProvider with ChangeNotifier {
  List<Manga> _library = [];
  bool _isLoading = true;

  List<Manga> get library => _library;
  bool get isLoading => _isLoading;

  LibraryProvider() {
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String? libraryJson = prefs.getString('manga_library');

    if (libraryJson != null) {
      final List<dynamic> decoded = json.decode(libraryJson);
      _library = decoded.map((item) => Manga.fromJson(item)).toList();
    } else {
      _library = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLibrary(Manga manga) async {
    final index = _library.indexWhere((m) => m.id == manga.id && m.sourceId == manga.sourceId);
    
    if (index >= 0) {
      _library.removeAt(index);
    } else {
      _library.add(manga);
    }

    notifyListeners();
    await _saveLibrary();
  }

  bool isInLibrary(String mangaId, String sourceId) {
    return _library.any((m) => m.id == mangaId && m.sourceId == sourceId);
  }

  Future<void> _saveLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_library.map((m) => m.toJson()).toList());
    await prefs.setString('manga_library', encoded);
  }
}
