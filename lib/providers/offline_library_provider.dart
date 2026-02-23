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
  List<LocalCategoryAssignment> _categoryAssignments = [];
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

    libraryRepo.watchCategoryAssignments().listen((assignments) {
      _categoryAssignments = assignments;
      notifyListeners();
    });

    libraryRepo.watchCategories().listen((categories) {
      _categories = categories;
      notifyListeners();
    });
  }

  List<LocalLibraryEntry> get library => _library;
  List<LocalCategory> get categories => _categories;
  List<LocalCategoryAssignment> get categoryAssignments => _categoryAssignments;
  bool get isLoading => _isLoading;
  LibraryFilterState get filterState => _filterState;

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

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLibrary(Manga manga, {List<String>? categories}) async {
    final token = getToken();
    if (token == null) return;

    final inLibrary = _library.any(
          (e) => e.mangaId == manga.id && e.sourceId == manga.sourceId,
    );

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

  Future<void> toggleCategoryAssignment(
      String mangaId,
      String sourceId,
      int localCategoryId,
      ) async {
    await libraryRepo.toggleCategoryAssignment(
      mangaId,
      sourceId,
      localCategoryId,
    );
  }

  bool isInLibrary(String mangaId, String sourceId) {
    return _library.any((e) => e.mangaId == mangaId && e.sourceId == sourceId);
  }

  bool isMangaInCategory(String mangaId, String sourceId, int localCategoryId) {
    return _categoryAssignments.any(
          (a) =>
      a.mangaId == mangaId &&
          a.sourceId == sourceId &&
          a.localCategoryId == localCategoryId,
    );
  }

  // --- Category operations ---

  List<LocalLibraryEntry> getLibraryForCategory(String categoryName) {
    if (categoryName == "Default") {
      // Default = Items with NO category assignments
      return _library.where((entry) {
        return !_categoryAssignments.any(
              (assignment) =>
          assignment.mangaId == entry.mangaId &&
              assignment.sourceId == entry.sourceId,
        );
      }).toList();
    } else {
      // Find the category ID
      final category = _categories.firstWhere(
            (c) => c.name == categoryName,
        orElse: () => LocalCategory()..id = -1,
      );

      if (category.id == -1) return [];

      return _library.where((entry) {
        return _categoryAssignments.any(
              (assignment) =>
          assignment.mangaId == entry.mangaId &&
              assignment.sourceId == entry.sourceId &&
              assignment.localCategoryId == category.id,
        );
      }).toList();
    }
  }

  Future<void> createCategory(String name) async {
    await libraryRepo.createCategory(name);
  }

  Future<void> updateCategory(int id, String name) async {
    await libraryRepo.updateCategory(id, name);
  }

  Future<void> deleteCategory(int id) async {
    await libraryRepo.deleteCategory(id);
  }

  // Chapter Download logic
  final Set<String> _downloadingIds = {};
  Set<String> get downloadingIds => _downloadingIds;

  Future<void> downloadChapter(
      String sourceId,
      String mangaId,
      String chapterId,
      ) async {
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
