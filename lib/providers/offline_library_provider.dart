import 'package:flutter/material.dart';
import '../models/local_models.dart';
import '../models/manga.dart';
import '../services/library_repository.dart';
import '../services/manga_repository.dart';
import '../services/auth_api.dart';

class OfflineLibraryProvider with ChangeNotifier {
  final LibraryRepository libraryRepo;
  final MangaRepository mangaRepo;
  final String? Function() getToken;

  List<LocalLibraryEntry> _library = [];
  List<LocalCategory> _categories = [];
  bool _isLoading = false;

  OfflineLibraryProvider({
    required this.libraryRepo,
    required this.mangaRepo,
    required this.getToken,
  }) {
    _init();
  }

  void _init() {
    libraryRepo.watchLibrary().listen((entries) {
      _library = entries;
      notifyListeners();
    });
    _loadCategories();
  }

  List<LocalLibraryEntry> get library => _library;
  List<LocalCategory> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> _loadCategories() async {
    _categories = await libraryRepo.getCategories();
    notifyListeners();
  }

  Future<void> refresh(bool force) async {
    final token = getToken();
    if (token == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    await libraryRepo.refreshLibrary(token);
    await _loadCategories();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLibrary(Manga manga) async {
    final token = getToken();
    if (token == null) return;

    final inLibrary = _library.any((e) => e.mangaId == manga.id && e.sourceId == manga.sourceId);
    
    if (inLibrary) {
      await libraryRepo.removeFromLibrary(token, manga.id, manga.sourceId);
    } else {
      await libraryRepo.addToLibrary(token, manga);
    }
  }

  bool isInLibrary(String mangaId, String sourceId) {
    return _library.any((e) => e.mangaId == mangaId && e.sourceId == sourceId);
  }

  // Chapter Download logic
  final Set<String> _downloadingIds = {};
  Set<String> get downloadingIds => _downloadingIds;

  Future<void> downloadChapter(String sourceId, String mangaId, String chapterId) async {
    final token = getToken();
    if (token == null) return;

    _downloadingIds.add(chapterId);
    notifyListeners();

    try {
      await mangaRepo.downloadChapter(token, sourceId, mangaId, chapterId);
    } finally {
      _downloadingIds.remove(chapterId);
      notifyListeners();
    }
  }
}
