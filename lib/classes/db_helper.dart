// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:lit_reader/models/read_history.dart';
import 'package:lit_reader/models/story_download.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class DBHelper {
  late Database db;
  late StoreRef historyStore;
  late StoreRef downloadStore;

  DBHelper() {
    // init();
  }

  Future<void> init() async {
    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docDir.path, 'literotica', 'lit.db');

    db = await databaseFactoryIo.openDatabase(dbPath); //open/init db
    historyStore = stringMapStoreFactory.store('history'); //creates/finds a table
    downloadStore = stringMapStoreFactory.store('downloads'); //creates/finds a table
  }

  Future<void> addHistory(String key, ReadHistory value) async {
    try {
      print("adding history for $key");
      final record = historyStore.record(key);
      final val = jsonEncode(value.toJson());

      await record.put(db, val);
      print("history added for $key");
      print(record);
    } catch (e) {
      print(e);
    }
  }

  Future<List<ReadHistory>> getHistory([String? key]) async {
    try {
      List<ReadHistory> history = [];
      if (key != null) {
        var searchResult = await historyStore.record(key).get(db);
        if (searchResult != null) {
          if (searchResult is String) {
            history.add(ReadHistory.fromJson(jsonDecode(searchResult) as Map<String, dynamic>));
          } else {
            history.add(ReadHistory.fromJson(searchResult as Map<String, dynamic>));
          }
        }
      } else {
        var records = await historyStore.find(db);
        for (var record in records) {
          if (record.value is String) {
            history.add(ReadHistory.fromJson(jsonDecode(record.value as String) as Map<String, dynamic>));
          } else {
            history.add(ReadHistory.fromJson(record.value as Map<String, dynamic>));
          }
        }
      }

      print(history.length);
      return history..sort((ReadHistory a, ReadHistory b) => b.lastReadDate!.compareTo(a.lastReadDate!));
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> removeHistory(String key) async {
    await historyStore.record(key).delete(db);
  }

  Future<void> clearHistory() async {
    await historyStore.delete(db);
  }

  Future<void> addDownload(String key, StoryDownload value) async {
    final record = downloadStore.record(key);
    final val = jsonEncode(value.toJson());
    await record.put(db, val);
  }

  Future<List<StoryDownload>> getDownloads([String? key]) async {
    try {
      List<StoryDownload> downloads = [];
      if (key != null) {
        var searchResult = await downloadStore.record(key).get(db);
        if (searchResult != null) {
          if (searchResult is String) {
            downloads.add(StoryDownload.fromJson(jsonDecode(searchResult) as Map<String, dynamic>));
          } else {
            downloads.add(StoryDownload.fromJson(searchResult as Map<String, dynamic>));
          }
        }
      } else {
        var records = await downloadStore.find(db);
        for (var record in records) {
          if (record.value is String) {
            downloads.add(StoryDownload.fromJson(jsonDecode(record.value as String) as Map<String, dynamic>));
          } else {
            downloads.add(StoryDownload.fromJson(record.value as Map<String, dynamic>));
          }
        }
      }
      return downloads..sort((StoryDownload a, StoryDownload b) => b.lastReadDate!.compareTo(a.lastReadDate!));
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> removeDownload(String key) async {
    await downloadStore.record(key).delete(db);
  }

  Future<void> clearDownloads() async {
    await downloadStore.delete(db);
  }
}
