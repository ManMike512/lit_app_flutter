import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lit_reader/classes/search_config.dart';
import 'package:lit_reader/data/categories.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/consts.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/tag.dart';
import 'package:lit_reader/screens/widgets/drawer_widget.dart';
import 'package:lit_reader/screens/widgets/lit_badge.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final _tagPagingController = PagingController<int, Tag>(
    getNextPageKey: (state) => state.items != null && state.items!.isNotEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => api.getPopularTags(),
  );

  late final _categoryPagingController = PagingController<int, Category>(
    getNextPageKey: (state) => state.items != null && state.items!.isNotEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => api.getCategories(),
  );
  PersistentTabController get tabcontroller => persistentTabcontroller;

  List<Category> categoryItems = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const Text('Explore'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            popularCategories(),
            popularTags(),
          ],
        ),
      ),
    );
  }

  Widget popularTags() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 16,
                bottom: 16,
              ),
              child: Text(
                'Popular Tags',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(() => _tagPagingController.refresh()),
                child: PagingListener(
                  controller: _tagPagingController,
                  builder: (context, state, fetchNextPage) => PagedListView<int, Tag>(
                    // pagingController: _tagPagingController,
                    fetchNextPage: fetchNextPage,
                    state: state,
                    builderDelegate: PagedChildBuilderDelegate<Tag>(
                      itemBuilder: (context, item, index) => Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.tag),
                          trailing: Text(
                            item.count.toString(),
                            style: const TextStyle(
                              color: kRed,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            SearchConfig searchConfig = SearchConfig.tagSearch(
                              tagList: [item.tag],
                              sortOrder: SearchSortField.voteDesc,
                              sortString: SearchString.voteDesc,
                            );
                            navigateToSearch(searchConfig);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget popularCategories() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 4, left: 8, right: 8, top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 16,
                bottom: 16,
              ),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(() => _categoryPagingController.refresh()),
                child: PagingListener(
                  controller: _categoryPagingController,
                  builder: (context, state, fetchNextPage) => PagedListView<int, Category>(
                    fetchNextPage: fetchNextPage,
                    state: state,
                    builderDelegate: PagedChildBuilderDelegate<Category>(
                      itemBuilder: (context, item, index) => Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          isThreeLine: true,
                          tileColor: Theme.of(context).scaffoldBackgroundColor,
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.ldesc),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    child: const LitBadge(text: 'Top', color: kHotTag),
                                    onTap: () {
                                      SearchConfig searchConfig = SearchConfig.categorySearch(
                                        selectedCategory: item.id,
                                      );
                                      navigateToSearch(searchConfig);
                                      litSearchController.selectedCategory = [item.id.toString()];
                                    },
                                  ),
                                  InkWell(
                                    child: const LitBadge(text: 'New', color: kNewTag),
                                    onTap: () {
                                      SearchConfig searchConfig = SearchConfig.categorySearch(
                                        selectedCategory: item.id,
                                        newOnly: true,
                                      );
                                      navigateToSearch(searchConfig);
                                      litSearchController.selectedCategory = [item.id.toString()];
                                    },
                                  ),
                                  InkWell(
                                    child: const LitBadge(text: 'Random', color: kWinnerTag),
                                    onTap: () {
                                      SearchConfig searchConfig = SearchConfig.categorySearch(
                                        selectedCategory: item.id,
                                        random: true,
                                      );
                                      navigateToSearch(searchConfig);
                                      litSearchController.selectedCategory = [item.id.toString()];
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
