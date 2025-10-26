import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/author.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/widgets/paged_list_view.dart';
import 'package:lit_reader/screens/widgets/story_item.dart';

class AuthorsStoriesScreen extends StatefulWidget {
  const AuthorsStoriesScreen({super.key, required this.author, this.listOnly = false});
  final Author author;
  final bool listOnly;

  @override
  State<AuthorsStoriesScreen> createState() => _AuthorsStoriesScreenState();
}

class _AuthorsStoriesScreenState extends State<AuthorsStoriesScreen> {
  late final _pagingController = PagingController<int, Submission>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) {
      final results = _fetchPage(pageKey);
      return results;
    },
  );

  Future<List<Submission>> _fetchPage(int pageKey) async {
    try {
      final result = await api.getAuthorStories(widget.author.username, page: pageKey);
      final newItems = result.data;
      return newItems;
    } catch (error) {
      rethrow;
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

  @override
  Widget build(BuildContext context) {
    if (widget.listOnly) {
      return body();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Author\'s Stories'),
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: body(),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        children: <Widget>[
          Expanded(
            child: LitPagedListView<Submission>(
              pagingController: _pagingController,
              itemBuilder: (context, item, index) {
                return Center(
                    child: StoryItem(
                  submission: item,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
