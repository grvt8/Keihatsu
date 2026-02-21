import 'package:isar/isar.dart';

import 'local_models.g.dart';

@collection
class LocalSource {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sourceId;

  late String name;
  late String lang;
  late String baseUrl;
  String? iconUrl;
  String? iconLocalPath;
  bool pinned = false;
  bool enabled = true;
  int versionId = 0;
  DateTime? lastUpdatedAt;
}

@collection
class LocalManga {
  Id id = Isar.autoIncrement;

  @Index(unique: true, composite: [CompositeIndex('sourceId')], replace: true)
  late String mangaId;
  late String sourceId;

  late String title;
  String? description;
  String? thumbnailUrl;
  String? thumbnailLocalPath;
  String? author;
  String? artist;
  String? status;
  List<String>? genres;

  bool isFavorite = false;
  DateTime? lastReadAt;
}

@collection
class LocalChapter {
  Id id = Isar.autoIncrement;

  @Index(unique: true, composite: [CompositeIndex('mangaId'), CompositeIndex('sourceId')], replace: true)
  late String chapterId;
  late String mangaId;
  late String sourceId;

  late String name;
  late double chapterNumber;
  late int dateUpload;
  String? scanlator;

  bool downloaded = false;
  DateTime? lastReadAt;
  int? lastPageRead;
}

@collection
class LocalPage {
  Id id = Isar.autoIncrement;

  @Index()
  late String chapterId;

  late int index;
  String? imageLocalPath;
  late String imageRemoteUrl;
}

@collection
class LocalLibraryEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true, composite: [CompositeIndex('sourceId')], replace: true)
  late String mangaId;
  late String sourceId;

  bool bookmarked = false;
  bool completed = false;
  bool unread = true;

  // Snapshot of manga metadata
  late String title;
  String? thumbnailUrl;
  String? author;
}

@collection
class LocalCategory {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? serverId; // null if not synced yet

  late String name;
  bool isSynced = false;
}

@collection
class LocalCategoryAssignment {
  Id id = Isar.autoIncrement;

  @Index()
  late String mangaId;
  @Index()
  late String sourceId;
  @Index()
  late int localCategoryId; // Links to LocalCategory.id
}

@collection
class SyncOperation {
  Id id = Isar.autoIncrement;

  late String type; // 'ADD_LIBRARY', 'REMOVE_LIBRARY', 'CREATE_CATEGORY', etc.
  late String payload; // JSON string
  late DateTime timestamp;

  @Index()
  bool completed = false;
  int retryCount = 0;
  String? errorMessage;
}

@collection
class LocalUserPreferences {
  Id id = Isar.autoIncrement;

  String? libraryDisplayStyle;
  late String sourcePreferencesJson; // Store as JSON string for simplicity
}
