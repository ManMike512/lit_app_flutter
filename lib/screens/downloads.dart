import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lit_reader/classes/db_helper.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/story_download.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/widgets/drawer_widget.dart';
import 'package:lit_reader/screens/widgets/empty_list_indicator.dart';
import 'package:lit_reader/screens/widgets/lit_search_bar.dart';
import 'package:lit_reader/screens/widgets/story_item.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  TextEditingController searchController = TextEditingController();

  late final _pagingController = PagingController<int, StoryDownload>(
    getNextPageKey: (state) => state.items != null && state.items!.isNotEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) {
      final results = _fetchPage();
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

  Future<List<StoryDownload>> _fetchPage() async {
    try {
      DBHelper dbHelper = DBHelper();
      await dbHelper.init();

      final List<StoryDownload> newItems = await dbHelper.getDownloads();

      return newItems;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _refresh() async {
    _pagingController.refresh();
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

  Future<void> onDeleteDownload(Submission submission) async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.init();
    await dbHelper.removeDownload(submission.url);
    await _fetchPage();
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
            Text("Downloads"),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Clear Downloads"),
                    content: const Text("Are you sure you want to clear your downloads?"),
                    actions: [
                      TextButton(
                        child: const Text("Clear"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          DBHelper dbHelper = DBHelper();
                          await dbHelper.init();
                          await dbHelper.clearDownloads();
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
              historyDownloadController.selectedIndex = 0;
              historyDownloadController.selectedTabName = "History";
              historyDownloadController.selectedTabIcon = const Icon(Ionicons.time);
            },
            icon: const Icon(Ionicons.time),
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
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: PagingListener(
                controller: _pagingController,
                builder: (context, state, fetchNextPage) => PagedListView<int, StoryDownload>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate<StoryDownload>(
                    itemBuilder: (context, item, index) => StoryItem(
                      submission: item.submission,
                      onDelete: onDeleteDownload,
                    ),
                    noItemsFoundIndicatorBuilder: (_) => const EmptyListIndicator(
                      subtext: "Maybe try downloading something",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
