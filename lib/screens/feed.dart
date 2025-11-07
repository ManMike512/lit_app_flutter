import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lit_reader/env/consts.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/activity_data.dart';
import 'package:lit_reader/screens/widgets/drawer_widget.dart';
import 'package:lit_reader/screens/widgets/empty_list_indicator.dart';
import 'package:lit_reader/screens/widgets/logged_in_error.dart';
import 'package:lit_reader/screens/widgets/paged_list_view.dart';
import 'package:lit_reader/screens/widgets/story_item.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool viewOld = false;
  late final _pagingController = PagingController<int, ActivityData>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      final results = await _fetchPage(pageKey);
      return results;
    },
  );

  void switchFeedState() {
    viewOld = !viewOld;
    _pagingController.refresh();
    setState(() {});
  }

  String? lastId;
  Future<List<ActivityData>> _fetchPage(int pageKey) async {
    try {
      if (pageKey == 1) {
        lastId = null;
      }
      int limit = 25;
      final newItems =
          viewOld ? await api.getOldFeed(limit: limit, lastId: lastId) : await api.getFeed(limit: limit, lastId: lastId);

      if (lastId == newItems.data.last.id) {
        //no new items
        return [];
      }

      lastId = newItems.data.last.id;

      return newItems.data;
    } catch (error) {
      print('Error fetching feed page: $error');
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(viewOld ? 'Archived Feed' : 'Feed'),
        actions: [
          IconButton(
            icon: Icon(viewOld ? Icons.new_releases_outlined : Icons.history),
            onPressed: () {
              switchFeedState();
            },
          ),
        ],
      ),
      body: body(),
    );
  }

  Widget body() {
    return Obx(() {
      if (loginController.loginState == LoginState.loggedIn) {
        return LitPagedListView<ActivityData>(
          pagingController: _pagingController,
          itemBuilder: (context, item, index) {
            return StoryItem(
              submission: item.what,
            );
          },
          emptyListBuilder: (_) => const EmptyListIndicator(
            subtext: "No stories in your feed",
          ),
        );
      } else if (loginController.loginState == LoginState.loggedOut || loginController.loginState == LoginState.failure) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: LoggedInError(
            text: "You must be logged in to view your feed",
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    });
  }
}
