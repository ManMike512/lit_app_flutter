import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/widgets/paged_list_view.dart';
import 'package:lit_reader/screens/widgets/story_item.dart';

class SimilarScreen extends StatefulWidget {
  const SimilarScreen({super.key, required this.story});
  final Submission story;

  @override
  State<SimilarScreen> createState() => _SimilarScreenState();
}

class _SimilarScreenState extends State<SimilarScreen> {
  late final _pagingController = PagingController<int, Submission>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async {
      if (pageKey > 1) {
        return [];
      }
      return await api.getSimilarStories(widget.story.url);
    },
  );

  @override
  void initState() {
    _pagingController.refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar'),
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
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
      ),
    );
  }
}
