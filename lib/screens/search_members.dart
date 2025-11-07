import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lit_reader/classes/search_config.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/consts.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/author.dart';
import 'package:lit_reader/screens/widgets/author_item.dart';
import 'package:lit_reader/screens/widgets/drawer_widget.dart';
import 'package:lit_reader/screens/widgets/empty_list_indicator.dart';
import 'package:lit_reader/screens/widgets/lit_search_bar.dart';
import 'package:lit_reader/screens/widgets/paged_list_view.dart';
import 'package:moon_design/moon_design.dart';

class SearchMembersScreen extends StatefulWidget {
  const SearchMembersScreen({super.key, this.searchConfig, this.pagingController});
  final SearchConfig? searchConfig;
  final PagingController<int, Author>? pagingController;

  @override
  State<SearchMembersScreen> createState() => _SearchMembersScreenState();
}

class _SearchMembersScreenState extends State<SearchMembersScreen> {
  SearchConfig? get searchConfig => widget.searchConfig;
  late PagingController<int, Author> _pagingController;
  TextEditingController searchFieldTextController = TextEditingController();

  @override
  void dispose() {
    if (widget.pagingController == null) {
      _pagingController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pagingController = widget.pagingController ??
        PagingController<int, Author>(
          getNextPageKey: (state) =>
              state.pages == null || state.pages!.length + 1 < litSearchController.maxPage ? state.nextIntPageKey : null,
          fetchPage: (pageKey) {
            final results = _fetchPage(pageKey);
            return results;
          },
        );

    searchFieldTextController.text = litSearchController.searchTerm;

    if (searchConfig != null) {
      litSearchController.searchTags = searchConfig!.isTagSearch;
      if (searchConfig!.isTagSearch) {
        litSearchController.tagList = searchConfig!.tagList ?? [];
      } else {
        litSearchController.searchTerm = searchConfig!.searchTerm ?? "";
      }

      litSearchController.sortOrder = searchConfig!.sortOrder;
      litSearchController.sortString = searchConfig!.sortString;
      litSearchController.isPopular = searchConfig!.isPopular;
      litSearchController.isWinner = searchConfig!.isWinner;
      litSearchController.isEditorsChoice = searchConfig!.isEditorsChoice;
    }
    _pagingController.refresh();
    ever(litSearchController.searchTermRx, (_) {
      if (!mounted) return;
      _pagingController.refresh();
    });
    ever(litSearchController.tagListRx, (_) {
      if (!mounted) return;

      _pagingController.refresh();
    });

    ever(litSearchController.categorySearchIdRx, (_) {
      if (!mounted) return;
      litSearchController.tagList.clear();
      litSearchController.searchTerm = "";
      _pagingController.refresh();
    });
  }

  Future<List<Author>> _fetchPage(int pageKey) async {
    try {
      litSearchController.page = pageKey;
      if (litSearchController.searchTerm.isEmpty) {
        if (!mounted) return [];
        return [];
      }
      await litSearchController.searchMembers();
      final newItems = litSearchController.memberResults;

      return newItems;
    } catch (error) {
      if (!mounted) rethrow;
      // _pagingController.error = error;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchformKey = GlobalKey<FormState>();

    return Scaffold(
      drawer: searchConfig == null ? const DrawerWidget() : null,
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Search Authors'),
        leading: searchConfig != null
            ? IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                litSearchController.togglePageIndex();
              }),
          IconButton(
            icon: const Icon(Ionicons.filter),
            onPressed: () {
              filterFormDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          children: <Widget>[
            LitSearchBar(
                formKey: searchformKey,
                // initialValue: litSearchController.searchTerm,
                litSearchController: litSearchController,
                searchFieldTextController: searchFieldTextController),
            Expanded(
              child: LitPagedListView<Author>(
                pagingController: _pagingController,
                itemBuilder: (context, item, index) {
                  return Center(child: AuthorItem(author: item));
                },
                emptyListBuilder: (_) => const EmptyListIndicator(
                  subtext: "No results found",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> filterFormDialog(BuildContext context) {
    return showMoonModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      height: MediaQuery.of(context).size.height * 0.75,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Text("Filters", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Expanded(child: SingleChildScrollView(child: searchFilter())),
            ],
          ),
        );
      },
    );
  }

  Widget searchFilter() {
    return Obx(
      () => Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text("Sort", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            RadioMenuButton<SearchSortField>(
              value: SearchSortField.relevant,
              groupValue: litSearchController.sortOrder,
              onChanged: (value) {
                litSearchController.sortOrder = value!;
                litSearchController.sortString = SearchString.relevant;
              },
              child: const Text("Relevancy"),
            ),
            RadioMenuButton<SearchSortField>(
              value: SearchSortField.dateAsc,
              groupValue: litSearchController.sortOrder,
              onChanged: (value) {
                litSearchController.sortOrder = value!;
                litSearchController.sortString = SearchString.dateDesc;
              },
              child: const Text("Newest"),
            ),
            RadioMenuButton<SearchSortField>(
              value: SearchSortField.dateDesc,
              groupValue: litSearchController.sortOrder,
              onChanged: (value) {
                litSearchController.sortOrder = value!;
                litSearchController.sortString = SearchString.dateAsc;
              },
              child: const Text("Oldest"),
            ),
            const SizedBox(height: 20),
            const Text("Gender", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ...AuthorGender.values.map((g) => CheckboxMenuButton(
                  value: litSearchController.memberGenders.contains(g),
                  onChanged: (bool? value) {
                    litSearchController.memberGenders.contains(g)
                        ? litSearchController.memberGenders.remove(g)
                        : litSearchController.memberGenders.add(g);
                  },
                  child: Text(g.text),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: kRed),
                    ),
                  ),
                  onPressed: () {
                    if (!mounted) return;
                    _pagingController.refresh();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
