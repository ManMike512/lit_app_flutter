import 'package:flutter/widgets.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/submission.dart';

class PrefsFunctions {
  void saveScrollPosition({required Submission submission, required ScrollController scrollController}) async {
    preferences.setDouble('${submission.url}_scrollPosition', scrollController.offset);
  }

  void saveCurrentPage({required Submission submission, required PageController controller}) async {
    if (controller.page != null) {
      preferences.setInt('${submission.url}_currentpage', controller.page!.round());
      // ignore: avoid_print
      print("current page: ${controller.page!.round()}");
    }
  }

  int getLastPage({required Submission submission}) {
    int lastPage = preferences.getInt('${submission.url}_currentpage') ?? 0;
    return lastPage;
  }

  double getLastPagePosition({required Submission submission}) {
    double scrollPosition = preferences.getDouble('${submission.url}_scrollPosition') ?? 0.0;
    return scrollPosition;
  }

  void jumpToLastPage(
      {required Submission submission, required PageController controller, required ScrollController scrollController}) {
    int lastPage = getLastPage(submission: submission);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.jumpToPage(lastPage);
    });
  }

  void saveSearchCategories(List<String> categories) {
    preferences.setStringList('searchCategories', categories);
  }

  List<String> getSearchCategories() {
    List<String>? csvCategories = preferences.getStringList('searchCategories');

    // init to no categories
    if (csvCategories == null) {
      preferences.setStringList('searchCategories', []);
      return [];
    }

    return csvCategories;
  }

  String? getStoragePath() {
    return preferences.getString('storagePath');
  }

  Future<bool> saveStoragePath(String path) async {
    return await preferences.setString('storagePath', path);
  }

  Map<String, int> getAllPagePositions() {
    final Map<String, int> result = {};
    final keys = preferences.getKeys();
    for (final key in keys) {
      if (key.contains("_currentpage")) {
        int? value = preferences.getInt(key);
        if (value != null) {
          result[key] = value;
        }
      }
    }
    return result;
  }

  Map<String, double> getAllScrollPositions() {
    final Map<String, double> result = {};
    final keys = preferences.getKeys();
    for (final key in keys) {
      if (key.contains("_scrollPosition")) {
        double? value = preferences.getDouble(key);
        if (value != null) {
          result[key] = value;
        }
      }
    }
    return result;
  }

  Future<void> restoreCurrentPages({required Map<String, int> allPages}) async {
    for (final entry in allPages.entries) {
      try {
        await preferences.setInt(entry.key, entry.value);
      } catch (e) {
        //ignore
        print(e);
      }
    }
  }

  Future<void> restoreScrollPositions({required Map<String, double> allPositions}) async {
    for (final entry in allPositions.entries) {
      try {
        await preferences.setDouble(entry.key, entry.value);
      } catch (e) {
        print(e);
      }
    }
  }
}
