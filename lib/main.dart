import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lit_reader/controllers/dio_controller.dart';
import 'package:lit_reader/controllers/history_download_screen_controller.dart';
import 'package:lit_reader/controllers/lists_controller.dart';
import 'package:lit_reader/controllers/log_controller.dart';
import 'package:lit_reader/controllers/login_controller.dart';
import 'package:lit_reader/controllers/search_controller.dart' as searchController;
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/consts.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/screens/home.dart';
import 'package:logging/logging.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL; // Log messages emitted at all levels
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
  WidgetsFlutterBinding.ensureInitialized();
  await initSharedPreferences();
  await getAppVersion();
  await updateController.checkForUpdate();
  _initServices();

  runApp(const OverlaySupport(child: MyApp()));
}

void _initServices() {
  try {
    ioc.registerSingleton<LogController>(LogController());
    ioc.registerSingleton<DioController>(DioController());
    ioc.registerSingleton<LoginController>(LoginController());
    ioc.registerSingleton<searchController.SearchController>(searchController.SearchController());
    ioc.registerSingleton<HistoryDownloadController>(HistoryDownloadController());
    ioc.registerSingleton<ListController>(ListController());
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> initPrefs() async {
    loginController.username = preferences.getString('username') ?? '';
    loginController.password = preferences.getString('password') ?? '';
    loginController.token = loginController.token.copyWith(token: preferences.getString('token') ?? '');
    if (await loginController.isTokenValid()) {
      loginController.loginState = LoginState.loggedIn;
    } else if (loginController.username.isNotEmpty && loginController.password.isNotEmpty) {
      loginController.refreshToken();
    } else {
      loginController.loginState = LoginState.loggedOut;
    }
    await litSearchController.getCategories();

    // read saved search categories from SharedPreferences on app start
    litSearchController.selectedCategory = prefsFunctions.getSearchCategories();
  }

  @override
  void initState() {
    super.initState();

    initPrefs();
    logController.addLog('App started');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: knavigatorKey,
      title: 'Lit Reader',
      themeMode: ThemeMode.dark, // Enforce dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // Define your dark theme here
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kRed),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
