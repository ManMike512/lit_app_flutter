import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lit_reader/classes/db_helper.dart';
import 'package:lit_reader/classes/prefs_functions.dart';
import 'package:lit_reader/models/read_history.dart';
import 'package:lit_reader/models/story_download.dart';
import 'package:permission_handler/permission_handler.dart';

class BackupData {
  final List<ReadHistory> history;
  final List<StoryDownload> downloads; // Replace dynamic with your StoryDownload model
  BackupData({required this.history, required this.downloads});

  static BackupData copyWith(BackupData original, {List<ReadHistory>? history, List<StoryDownload>? downloads}) {
    return BackupData(
      history: history ?? original.history,
      downloads: downloads ?? original.downloads,
    );
  }

  Map<String, dynamic> toJson() => {
        'history': history.map((e) => e.toJson()).toList(),
        'downloads': downloads.map((e) => e.toJson()).toList(),
      };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      history: (json['history'] as List<dynamic>?)?.map((e) => ReadHistory.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      downloads:
          (json['downloads'] as List<dynamic>?)?.map((e) => StoryDownload.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

PrefsFunctions prefsFunctions = PrefsFunctions();

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  String? storedPath;
  List<FileSystemEntity> files = [];

  Future<void> getBackups() async {
    if (storedPath != null) {
      final dir = Directory(storedPath!);
      files = await dir
          .list()
          .where(
              (entity) => entity is File && entity.path.endsWith('.json') && entity.path.split('/').last.startsWith('lit_backup'))
          .toList();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No backup directory set')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    storedPath = prefsFunctions.getStoragePath();
    getBackups();
  }

  @override
  Widget build(BuildContext context) {
    Future<BackupData> getData() async {
      DBHelper dbHelper = DBHelper();
      await dbHelper.init();
      final history = await dbHelper.getHistory();
      final downloads = await dbHelper.getDownloads();
      return BackupData(history: history, downloads: downloads);
    }

    Future<void> setDirectory() async {
      if (!await Permission.manageExternalStorage.request().isGranted) {
        await Permission.manageExternalStorage.request();
      }
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        await prefsFunctions.saveStoragePath(selectedDirectory);
      }
    }

    Future<void> restoreBackup(FileSystemEntity file) async {
      final jsonContent = await (file as File).readAsString();
      final Map<String, dynamic> json = jsonContent.isNotEmpty ? jsonDecode(jsonContent) : {};
      BackupData backupData = BackupData.fromJson(json);

      DBHelper dbHelper = DBHelper();
      await dbHelper.init();
      await dbHelper.clearHistory();
      for (var history in backupData.history) {
        await dbHelper.addHistory(history.url, history);
      }
      await dbHelper.clearDownloads();
      for (var download in backupData.downloads) {
        await dbHelper.addDownload(download.url, download);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup restored from ${file.path}')),
      );
    }

    Future<void> saveJsonFile(String jsonString) async {
      if (storedPath != null) {
        final now = DateTime.now();
        final timestamp = DateFormat('dd_MMM_yyyy_HH_mm_ss').format(now);
        final filePath = '$storedPath/lit_backup_$timestamp.json';
        final file = File(filePath);
        await file.writeAsString(jsonString, flush: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved to $filePath')),
        );
      } else {
        // User canceled the picker
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No backup directory set')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backups'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await setDirectory();
                  },
                  icon: const Icon(Icons.folder_open),
                  label: Text(storedPath ?? 'Set Backup Directory'),
                ),
                if (storedPath != null)
                  IconButton(
                      onPressed: () async {
                        final backupData = await getData();
                        final jsonString = jsonEncode(backupData.toJson());
                        await saveJsonFile(jsonString);
                        await getBackups();
                      },
                      icon: const Icon(Icons.settings_backup_restore_sharp))
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: files
                      .map((file) => ListTile(
                          title: Text(file.path.split('/').last),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              icon: const Icon(Icons.restore_sharp),
                              onPressed: () async {
                                return showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Restore Backup"),
                                      content: Text("Clear and restore backup ${file.path}?"),
                                      actions: [
                                        TextButton(
                                          child: const Text("Restore"),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await restoreBackup(file);
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await file.delete();
                                await getBackups();
                              },
                            ),
                          ])))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
