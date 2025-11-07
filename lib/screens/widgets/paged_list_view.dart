import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lit_reader/env/colors.dart';

class LitPagedListView<T> extends StatefulWidget {
  const LitPagedListView(
      {super.key, required this.itemBuilder, required this.pagingController, this.emptyListBuilder, this.shrinkWrap = false});

  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget Function(BuildContext)? emptyListBuilder;
  final PagingController<int, T> pagingController;
  final bool shrinkWrap;
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
                  shrinkWrap: widget.shrinkWrap,
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
                          firstPageProgressIndicatorBuilder: (context) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: kRed,
                              ),
                            ),
                          ),
                          newPageProgressIndicatorBuilder: (context) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: kRed,
                              ),
                            ),
                          ),
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
