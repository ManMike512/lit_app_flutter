import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lit_reader/classes/db_helper.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/read_history.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/widgets/drawer_widget.dart';
import 'package:lit_reader/screens/widgets/empty_list_indicator.dart';
import 'package:lit_reader/screens/widgets/lit_search_bar.dart';
import 'package:lit_reader/screens/widgets/paged_list_view.dart';
import 'package:lit_reader/screens/widgets/story_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TextEditingController searchController = TextEditingController();
  late final _pagingController = PagingController<int, ReadHistory>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      if (pageKey > 1) {
        return [];
      }
      final results = await _fetchPage();
      return results;
    },
  );
  Timer? _debounce;

  void onChangeCustom() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _pagingController.refresh();
    });
  }

  Future<List<ReadHistory>> _fetchPage() async {
    try {
      print("fetch history page");
      DBHelper dbHelper = DBHelper();
      await dbHelper.init();

      final List<ReadHistory> newItems = await dbHelper.getHistory();

      return newItems;
    } catch (error) {
      // _pagingController.error = error;
      print(error);
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> onDeleteHistory(Submission submission) async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.init();
    await dbHelper.removeHistory(submission.url);
    _pagingController.refresh();
    print('Deleted: ${submission.title}');
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleSpacing: null,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("History"),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Clear History"),
                    content: const Text("Are you sure you want to clear your history?"),
                    actions: [
                      TextButton(
                        child: const Text("Clear"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          DBHelper dbHelper = DBHelper();
                          await dbHelper.init();
                          await dbHelper.clearHistory();
                          _pagingController.refresh();
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
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () {
              historyDownloadController.selectedIndex = 1;
              historyDownloadController.selectedTabName = "Downloads";
              historyDownloadController.selectedTabIcon = const Icon(Ionicons.download);
            },
            icon: const Icon(Ionicons.download),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          LitSearchBar(
            formKey: formKey,
            searchFieldTextController: searchController,
            onChanged: onChangeCustom,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: LitPagedListView<ReadHistory>(
              pagingController: _pagingController,
              itemBuilder: (context, item, index) {
                return StoryItem(
                  submission: item.submission,
                );
              },
              emptyListBuilder: (_) => const EmptyListIndicator(
                subtext: "Maybe try reading something",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
