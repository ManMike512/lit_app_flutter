import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/list.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/widgets/lit_search_bar.dart';
import 'package:lit_reader/screens/widgets/story_item.dart';

class ListItemListView extends StatefulWidget {
  const ListItemListView({super.key, required this.listName, required this.urlname});

  final String listName;
  final String urlname;

  @override
  State<ListItemListView> createState() => _ListItemListViewState();
}

class _ListItemListViewState extends State<ListItemListView> {
  final formKey = GlobalKey<FormState>();
  late final _pagingController = PagingController<int, Submission>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) {
      final results = _fetchPage(pageKey);
      return results;
    },
  );
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int? listId;

  @override
  void initState() {
    super.initState();
  }

  Future<List<Submission>> _fetchPage(int pageKey) async {
    if (widget.urlname.isEmpty) {
      return [];
    }
    final ListItem newItems = await api.getListItems(
      widget.urlname,
      page: pageKey,
      searchTerm: _searchController.text,
    );
    if (newItems.list?.id != null) {
      setState(() {
        listId = newItems.list?.id;
      });
    }

    return newItems.works?.data ?? [];
  }

  Future<void> _refresh() async {
    _pagingController.refresh();
  }

  void onChangeCustom() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _pagingController.refresh();
    });
  }

  Future<void> onRemoveFavorite(Submission submission) async {
    await api.toggleListItem(submission.id, listId!, false);
    _pagingController.refresh(); // This will reload the list and remove the deleted item
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _pagingController.refresh();
            },
          ),
        ],
        title: Text(widget.listName),
      ),
      body: body(formKey),
    );
  }

  Column body(GlobalKey<FormState> formKey) {
    return Column(
      children: <Widget>[
        SafeArea(
          top: true,
          bottom: false,
          child: LitSearchBar(
            formKey: formKey,
            searchFieldTextController: _searchController,
            onChanged: onChangeCustom,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: PagingListener(
              controller: _pagingController,
              builder: (context, state, fetchNextPage) => PagedListView<int, Submission>(
                padding: const EdgeInsets.only(top: 10),
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate<Submission>(
                  itemBuilder: (context, item, index) => StoryItem(
                    submission: item,
                    onDelete: listId != null ? onRemoveFavorite : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
