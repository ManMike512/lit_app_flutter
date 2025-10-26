import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class LitPagedListView<T> extends StatefulWidget {
  const LitPagedListView({super.key, required this.itemBuilder, required this.pagingController, this.emptyListBuilder});

  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget Function(BuildContext)? emptyListBuilder;
  final PagingController<int, T> pagingController;
  @override
  State<LitPagedListView<T>> createState() => _LitPagedListViewState<T>();
}

class _LitPagedListViewState<T> extends State<LitPagedListView<T>> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {
    widget.pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    PagingListener(
                      controller: widget.pagingController,
                      builder: (context, state, fetchNextPage) => PagedSliverList<int, T>(
                        // pagingController: widget.pagingController,
                        fetchNextPage: fetchNextPage,
                        state: state,
                        builderDelegate: PagedChildBuilderDelegate<T>(
                          itemBuilder: widget.itemBuilder,
                          noItemsFoundIndicatorBuilder: widget.emptyListBuilder,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // widget.pagingController.dispose();
    super.dispose();
  }
}
