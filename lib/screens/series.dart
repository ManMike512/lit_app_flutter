import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/widgets/paged_list_view.dart';
import 'package:lit_reader/screens/widgets/story_item.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key, required this.story});
  final Submission story;

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  late final _pagingController = PagingController<int, Submission>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) {
      final results = _fetchPage(pageKey);
      return results;
    },
  );

  Future<List<Submission>> _fetchPage(int pageKey) async {
    try {
      final story = await api.getStory(widget.story.url);
      List<Submission> newItems = [];
      if (story.submission?.series.meta.id != null) {
        newItems = await api.getSeries(story.submission!.series.meta.id);
      }

      // _pagingController.appendLastPage(newItems);
      return newItems;
    } catch (error) {
      // _pagingController.error = error;
      rethrow;
    }
  }

  @override
  void initState() {
    _pagingController.refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Series'),
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
