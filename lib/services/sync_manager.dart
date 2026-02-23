import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:isar/isar.dart';
import '../models/local_models.dart';
import 'library_api.dart';

class SyncManager {
  final Isar isar;
  final LibraryApi libraryApi;
  final String? Function() getToken;
  
  Timer? _syncTimer;
  bool _isProcessing = false;

  SyncManager({
    required this.isar,
    required this.libraryApi,
    required this.getToken,
  }) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        processSyncQueue();
      }
    });

    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) => processSyncQueue());
  }

  void dispose() {
    _syncTimer?.cancel();
  }

  Future<void> addToQueue(String type, Map<String, dynamic> payload) async {
    final op = SyncOperation()
      ..type = type
      ..payload = json.encode(payload)
      ..timestamp = DateTime.now()
      ..completed = false;

    await isar.writeTxn(() async {
      await isar.collection<SyncOperation>().put(op);
    });

    processSyncQueue();
  }

  Future<void> processSyncQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final token = getToken();
      if (token == null) return;

      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      final pendingOps = await isar.collection<SyncOperation>()
          .filter()
          .completedEqualTo(false)
          .sortByTimestamp()
          .findAll();

      for (final op in pendingOps) {
        bool success = await _executeOperation(op, token);
        if (success) {
          op.completed = true;
          await isar.writeTxn(() => isar.collection<SyncOperation>().put(op));
        } else {
          // Break to maintain FIFO order and handle dependencies
          break; 
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> _executeOperation(SyncOperation op, String token) async {
    final Map<String, dynamic> payload = json.decode(op.payload);
    
    try {
      switch (op.type) {
        case 'ADD_LIBRARY':
          final response = await libraryApi.addMangaToLibrary(token, payload);
          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = json.decode(response.body);
            final String serverId = data['id'];
            
            await isar.writeTxn(() async {
              final entry = await isar.collection<LocalLibraryEntry>().filter()
                  .mangaIdEqualTo(payload['mangaId'])
                  .sourceIdEqualTo(payload['sourceId'])
                  .findFirst();
              if (entry != null) {
                entry.serverId = serverId;
                await isar.collection<LocalLibraryEntry>().put(entry);
              }
            });
            return true;
          }
          break;

        case 'CREATE_CATEGORY':
          final response = await libraryApi.createCategory(token, payload['name']);
          if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 409) {
            final data = json.decode(response.body);
            final String? serverId = data['id'];
            
            await isar.writeTxn(() async {
              final cat = await isar.collection<LocalCategory>().get(payload['localId']);
              if (cat != null) {
                if (serverId != null) cat.serverId = serverId;
                cat.isSynced = true;
                await isar.collection<LocalCategory>().put(cat);
              }
            });
            return true;
          }
          break;

        case 'ASSIGN_CATEGORY':
          final String mangaId = payload['mangaId'];
          final String sourceId = payload['sourceId'];
          final int localCategoryId = payload['localCategoryId'];

          // Resolve Category serverId if it was local-only when queued
          final cat = await isar.collection<LocalCategory>().get(localCategoryId);
          final String? serverCategoryId = cat?.serverId;

          // Ensure Manga is synced to server library first
          final entry = await isar.collection<LocalLibraryEntry>().filter()
              .mangaIdEqualTo(mangaId)
              .sourceIdEqualTo(sourceId)
              .findFirst();
          
          if (serverCategoryId == null || entry?.serverId == null) {
            // Dependency not met yet (ADD_LIBRARY or CREATE_CATEGORY hasn't finished)
            return false;
          }

          final response = await libraryApi.assignMangaToCategory(token, mangaId, serverCategoryId);
          return response.statusCode == 200 || response.statusCode == 201;

        case 'REMOVE_LIBRARY':
          final response = await libraryApi.deleteLibraryEntry(token, payload['id']);
          return response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404;

        case 'UPDATE_LIBRARY':
          final response = await libraryApi.updateLibraryEntry(token, payload['id'], payload['updates']);
          return response.statusCode == 200 || response.statusCode == 204;

        case 'DELETE_CATEGORY':
          final response = await libraryApi.deleteCategory(token, payload['id']);
          return response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404;

        case 'UPDATE_PREFERENCES':
          final response = await libraryApi.updatePreferences(token, payload);
          return response.statusCode == 200 || response.statusCode == 204;
      }
    } catch (e) {
      // Log error
      op.errorMessage = e.toString();
      op.retryCount++;
      await isar.writeTxn(() async {
        await isar.collection<SyncOperation>().put(op);
      });
    }
    return false;
  }

  Future<void> _updateLocalServerId<T>(
      {required QueryBuilder<T, T, QAfterFilterCondition> Function(QueryBuilder<T, T, QFilterCondition> q) filter,
      required String serverId}) async {
    await isar.writeTxn(() async {
      final item = await filter(isar.collection<T>().filter()).findFirst();
      if (item != null) {
        if (item is LocalLibraryEntry) {
          (item as LocalLibraryEntry).serverId = serverId;
          await isar.collection<LocalLibraryEntry>().put(item as LocalLibraryEntry);
        } else if (item is LocalCategory) {
          (item as LocalCategory).serverId = serverId;
          (item as LocalCategory).isSynced = true;
          await isar.collection<LocalCategory>().put(item as LocalCategory);
        }
      }
    });
  }
}
