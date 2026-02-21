import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:isar/isar.dart';
import '../models/local_models.dart';
import 'library_api.dart';

class SyncManager {
  final Isar isar;
  final LibraryApi libraryApi;
  final String? Function() getToken;

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
      try {
        final payload = json.decode(op.payload);
        bool success = false;

        switch (op.type) {
          case 'ADD_LIBRARY':
            final response = await libraryApi.addMangaToLibrary(token, payload);
            if (response.statusCode == 200 || response.statusCode == 201) {
              final data = json.decode(response.body);
              final mangaId = payload['mangaId'];
              final sourceId = payload['sourceId'];
              
              // Update local entry with serverId
              final localEntry = await isar.collection<LocalLibraryEntry>().filter()
                  .mangaIdEqualTo(mangaId)
                  .sourceIdEqualTo(sourceId)
                  .findFirst();
              
              if (localEntry != null) {
                localEntry.serverId = data['id'];
                await isar.writeTxn(() => isar.collection<LocalLibraryEntry>().put(localEntry));
              }
              success = true;
            }
            break;
          case 'UPDATE_LIBRARY':
            final response = await libraryApi.updateLibraryEntry(token, payload['id'], payload['updates']);
            success = response.statusCode == 200 || response.statusCode == 204;
            break;
          case 'REMOVE_LIBRARY':
            final response = await libraryApi.deleteMangaFromLibrary(token, payload['id']);
            success = response.statusCode == 200 || response.statusCode == 204;
            break;
          case 'CREATE_CATEGORY':
            final response = await libraryApi.createCategory(token, payload['name']);
            if (response.statusCode == 200 || response.statusCode == 201) {
              final data = json.decode(response.body);
              final localCat = await isar.collection<LocalCategory>().get(payload['localId']);
              if (localCat != null) {
                localCat.serverId = data['id'];
                localCat.isSynced = true;
                await isar.writeTxn(() => isar.collection<LocalCategory>().put(localCat));
              }
              success = true;
            }
            break;
          case 'UPDATE_CATEGORY':
            final response = await libraryApi.updateCategory(token, payload['id'], payload['name']);
            success = response.statusCode == 200 || response.statusCode == 204;
            break;
          case 'DELETE_CATEGORY':
            final response = await libraryApi.deleteCategory(token, payload['id']);
            success = response.statusCode == 200 || response.statusCode == 204;
            break;
        }

        if (success) {
          op.completed = true;
          await isar.writeTxn(() => isar.collection<SyncOperation>().put(op));
        } else {
          op.retryCount++;
          await isar.writeTxn(() => isar.collection<SyncOperation>().put(op));
        }
      } catch (e) {
        op.retryCount++;
        await isar.writeTxn(() => isar.collection<SyncOperation>().put(op));
      }
    }
  }
}
