import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:lit_reader/classes/api.dart';
import 'package:lit_reader/classes/db_functions.dart';
import 'package:lit_reader/classes/prefs_functions.dart';
import 'package:lit_reader/classes/search_config.dart';
import 'package:lit_reader/controllers/dio_controller.dart';
import 'package:lit_reader/controllers/history_download_screen_controller.dart';
import 'package:lit_reader/controllers/lists_controller.dart';
import 'package:lit_reader/controllers/log_controller.dart';
import 'package:lit_reader/controllers/login_controller.dart';
import 'package:lit_reader/controllers/search_controller.dart' as searchController;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<NavigatorState> knavigatorKey = GlobalKey<NavigatorState>();
final ioc = GetIt.instance;

DbFunctions dbFunctions = DbFunctions();

PrefsFunctions prefsFunctions = PrefsFunctions();

API api = API();

late SharedPreferences preferences;

Future<void> initSharedPreferences() async {
  preferences = await SharedPreferences.getInstance();
}

PersistentTabController persistentTabcontroller = PersistentTabController(initialIndex: 0);

void navigateToSearch(SearchConfig searchConfig) {
  litSearchController.categorySearch = searchConfig.isCategorySearch;
  litSearchController.newOnly = searchConfig.newOnly;
  litSearchController.random = searchConfig.random;
  litSearchController.categorySearchId = searchConfig.selectedCategory.first;
  litSearchController.searchTags = searchConfig.isTagSearch;
  litSearchController.tagList = searchConfig.tagList ?? [];
  litSearchController.searchTerm = searchConfig.searchTerm ?? "";
  litSearchController.sortOrder = searchConfig.sortOrder;
  litSearchController.sortString = searchConfig.sortString;
  litSearchController.isPopular = searchConfig.isPopular;
  litSearchController.isWinner = searchConfig.isWinner;
  litSearchController.isEditorsChoice = searchConfig.isEditorsChoice;

  persistentTabcontroller.jumpToTab(2);
}

String versionString = '1.0.0';

Future<void> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  versionString = packageInfo.version; // Version name
}

//controllers
LogController get logController => Get.put(LogController());
DioController get dioController => Get.put(DioController());
LoginController get loginController => Get.put(LoginController());
searchController.SearchController get litSearchController => Get.put(searchController.SearchController());
HistoryDownloadController get historyDownloadController => Get.put(HistoryDownloadController());
ListController get listController => Get.put(ListController());
