import 'package:flutter/material.dart';
import '../models/local_models.dart';
import '../models/manga.dart';
import '../services/library_repository.dart';
import '../services/manga_repository.dart';

class LibraryFilterState {
  bool filterDownloaded = false;
  bool filterUnread = false;
  bool filterStarted = false;
  bool filterBookmarked = false;
  bool filterCompleted = false;
  String? search;
  String sortBy = 'date_added';
  String order = 'desc';

  LibraryFilterState();

  LibraryFilterState copyWith({
    bool? filterDownloaded,
    bool? filterUnread,
    bool? filterStarted,
    bool? filterBookmarked,
    bool? filterCompleted,
    String? search,
    String? sortBy,
    String? order,
  }) {
    final newState = LibraryFilterState();
    newState.filterDownloaded = filterDownloaded ?? this.filterDownloaded;
    newState.filterUnread = filterUnread ?? this.filterUnread;
    newState.filterStarted = filterStarted ?? this.filterStarted;
    newState.filterBookmarked = filterBookmarked ?? this.filterBookmarked;
    newState.filterCompleted = filterCompleted ?? this.filterCompleted;
    newState.search = search ?? this.search;
    newState.sortBy = sortBy ?? this.sortBy;
    newState.order = order ?? this.order;
    return newState;
  }
}

class OfflineLibraryProvider with ChangeNotifier {
  final LibraryRepository libraryRepo;
  final MangaRepository mangaRepo;
  final String? Function() getToken;

  List<LocalLibraryEntry> _library = [];
  List<LocalCategory> _categories = [];
  bool _isLoading = false;
  LibraryFilterState _filterState = LibraryFilterState();

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
  LibraryFilterState get filterState => _filterState;

  Future<void> _loadCategories() async {
    _categories = await libraryRepo.getCategories();
    notifyListeners();
  }

  void updateFilters(LibraryFilterState newState) {
    _filterState = newState;
    refresh(true);
  }

  Future<void> refresh(bool force) async {
    final token = getToken();
    if (token == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    await libraryRepo.refreshLibrary(
      token: token,
      filterDownloaded: _filterState.filterDownloaded,
      filterUnread: _filterState.filterUnread,
      filterStarted: _filterState.filterStarted,
      filterBookmarked: _filterState.filterBookmarked,
      filterCompleted: _filterState.filterCompleted,
      sortBy: _filterState.sortBy,
      order: _filterState.order,
      search: _filterState.search,
    );
    await _loadCategories();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLibrary(Manga manga, {List<String>? categories}) async {
    final token = getToken();
    if (token == null) return;

    final inLibrary = _library.any((e) => e.mangaId == manga.id && e.sourceId == manga.sourceId);
    
    if (inLibrary) {
      await libraryRepo.removeFromLibrary(token, manga.id, manga.sourceId);
    } else {
      await libraryRepo.addToLibrary(token, manga, categories: categories);
    }
  }

  Future<void> updateEntry(String mangaId, Map<String, dynamic> updates) async {
    final token = getToken();
    if (token == null) return;
    await libraryRepo.updateLibraryEntry(token, mangaId, updates);
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
