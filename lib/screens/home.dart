import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/screens/explore.dart';
import 'package:lit_reader/screens/feed.dart';
import 'package:lit_reader/screens/history_downloads.dart';
import 'package:lit_reader/screens/lists.dart';
import 'package:lit_reader/screens/search.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => PersistentTabView(
          gestureNavigationEnabled: true,
          controller: persistentTabcontroller,
          // navBarHeight: kBottomNavigationBarHeight + 5,
          tabs: [
            PersistentTabConfig(
              screen: const HistoryDownloadsScreen(),
              // onSelectedTabPressWhenNoScreensPushed: () {
              //   historyDownloadController.selectedIndex = historyDownloadController.selectedIndex == 1 ? 0 : 1;
              //   historyDownloadController.selectedTabIcon =
              //       historyDownloadController.selectedIndex == 0 ? const Icon(Ionicons.time) : const Icon(Ionicons.download);
              //   historyDownloadController.selectedTabName =
              //       historyDownloadController.selectedIndex == 0 ? "History" : "Downloads";
              // },
              item: ItemConfig(
                icon: historyDownloadController.selectedTabIcon,
                title: (historyDownloadController.selectedTabName),
                activeForegroundColor: kRed,
                inactiveForegroundColor: Colors.grey,
              ),
            ),
            PersistentTabConfig(
              screen: const ExploreScreen(),
              item: ItemConfig(
                icon: const Icon(Ionicons.bar_chart),
                title: ("Explore"),
                activeForegroundColor: kRed,
                inactiveForegroundColor: Colors.grey,
              ),
            ),
            PersistentTabConfig(
              screen: const SearchScreen(),
              item: ItemConfig(
                icon: const Icon(
                  Ionicons.search,
                  color: Colors.white,
                ),
                title: ("Search"),
                activeForegroundColor: kRed,
                inactiveForegroundColor: Colors.grey,
              ),
            ),
            PersistentTabConfig(
              screen: const FeedScreen(),
              item: ItemConfig(
                icon: const Icon(Ionicons.newspaper),
                title: ("Feed"),
                activeForegroundColor: kRed,
                inactiveForegroundColor: Colors.grey,
              ),
            ),
            PersistentTabConfig(
              screen: const ListScreen(),
              item: ItemConfig(
                icon: const Icon(Ionicons.list),
                title: ("Lists"),
                activeForegroundColor: kRed,
                inactiveForegroundColor: Colors.grey,
              ),
            ),
          ],
          backgroundColor: Colors.black,
          navBarBuilder: (navBarConfig) => Style15BottomNavBar(
            navBarConfig: navBarConfig,
            navBarDecoration: const NavBarDecoration(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
