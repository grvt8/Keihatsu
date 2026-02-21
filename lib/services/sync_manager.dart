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
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
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
      await isar.syncOperations.put(op);
    });

    processSyncQueue();
  }

  Future<void> processSyncQueue() async {
    final token = getToken();
    if (token == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final pendingOps = await isar.syncOperations
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
            success = response.statusCode == 200 || response.statusCode == 201;
            break;
          case 'REMOVE_LIBRARY':
            final response = await libraryApi.deleteMangaFromLibrary(token, payload['id']);
            success = response.statusCode == 200 || response.statusCode == 204;
            break;
          case 'CREATE_CATEGORY':
            final response = await libraryApi.createCategory(token, payload['name']);
            if (response.statusCode == 200 || response.statusCode == 201) {
              final data = json.decode(response.body);
              final localCat = await isar.localCategorys.get(payload['localId']);
              if (localCat != null) {
                localCat.serverId = data['id'];
                localCat.isSynced = true;
                await isar.writeTxn(() => isar.localCategorys.put(localCat));
              }
              success = true;
            }
            break;
          case 'UPDATE_PREFERENCES':
             // Call PUT /user/preferences
             success = true; // Placeholder
             break;
        }

        if (success) {
          op.completed = true;
          await isar.writeTxn(() => isar.syncOperations.put(op));
        } else {
          op.retryCount++;
          await isar.writeTxn(() => isar.syncOperations.put(op));
        }
      } catch (e) {
        op.retryCount++;
        await isar.writeTxn(() => isar.syncOperations.put(op));
      }
    }
  }
}
