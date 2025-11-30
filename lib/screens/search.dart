import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lit_reader/classes/search_config.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/consts.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/widgets/drawer_widget.dart';
import 'package:lit_reader/screens/widgets/empty_list_indicator.dart';
import 'package:lit_reader/screens/widgets/lit_category_multiselect_dropdown.dart';
import 'package:lit_reader/screens/widgets/lit_search_bar.dart';
import 'package:lit_reader/screens/widgets/lit_search_tag_bar.dart';
import 'package:lit_reader/screens/widgets/paged_list_view.dart';
import 'package:lit_reader/screens/widgets/story_item.dart';
import 'package:moon_design/moon_design.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.searchConfig, this.pagingController});
  final SearchConfig? searchConfig;
  final PagingController<int, Submission>? pagingController;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchConfig? get searchConfig => widget.searchConfig;
  late PagingController<int, Submission> _pagingController;
  TextEditingController searchFieldTextController = TextEditingController();
  final searchformKey = GlobalKey<FormState>();
  final searchTagsformKey = GlobalKey<FormState>();
  final filtersformKey = GlobalKey<FormState>();

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
        PagingController<int, Submission>(
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
    // _pagingController.addPageRequestListener((pageKey) {
    //   _fetchPage(pageKey);
    // });
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

  Future<List<Submission>> _fetchPage(int pageKey) async {
    try {
      litSearchController.page = pageKey;
      if (litSearchController.searchTerm.isEmpty &&
          litSearchController.tagList.isEmpty &&
          (litSearchController.categorySearch == true && litSearchController.categorySearchId == null)) {
        if (!mounted) return [];
        return [];
      }
      await litSearchController.search();
      final newItems = litSearchController.searchResults;

      return newItems;
    } catch (error) {
      if (!mounted) rethrow;
      // _pagingController.error = error;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        drawer: searchConfig == null ? const DrawerWidget() : null,
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text('Search Stories'),
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
            if (litSearchController.categorySearch || litSearchController.searchTags)
              IconButton(
                  icon: const Icon(Ionicons.close),
                  onPressed: () {
                    if (litSearchController.categorySearch) {
                      litSearchController.categorySearch = false;
                      litSearchController.categorySearchId = null;
                      litSearchController.tagList.clear();
                      litSearchController.searchTerm = "";
                      litSearchController.searchResults = [];
                    }

                    if (litSearchController.searchTags) {
                      litSearchController.searchTags = false;
                      litSearchController.tagList.clear();
                      litSearchController.searchTerm = "";
                      searchTagsformKey.currentState?.reset();
                    }

                    litSearchController.searchTerm = "";
                    searchFieldTextController.value = TextEditingValue.empty;
                    litSearchController.searchResults = [];
                    _pagingController.refresh();
                  }),
            IconButton(
                icon: const Icon(Icons.person),
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
              if (!litSearchController.searchTags && !litSearchController.categorySearch)
                LitSearchBar(
                    formKey: searchformKey,
                    // initialValue: litSearchController.searchTerm,
                    litSearchController: litSearchController,
                    searchFieldTextController: searchFieldTextController),
              if (litSearchController.searchTags && !litSearchController.categorySearch)
                LitSearchTagBar(
                  formKey: searchTagsformKey,
                  initialValue: litSearchController.tagList.join(","),
                  litSearchController: litSearchController,
                  pagingController: _pagingController,
                  searchFieldTextController: searchFieldTextController,
                ),
              Expanded(
                child: LitPagedListView<Submission>(
                  pagingController: _pagingController,
                  itemBuilder: (context, item, index) {
                    return Center(child: StoryItem(submission: item));
                  },
                  emptyListBuilder: (_) => const EmptyListIndicator(
                    subtext: "No results found",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Future<dynamic> bottomSheetBuilder(BuildContext context) {
  //     return showMoonModalBottomSheet(
  //       context: context,
  //       enableDrag: true,
  //       height: MediaQuery.of(context).size.height * 0.7,
  //       builder: (BuildContext context) => Column(
  //         children: [
  //           // Drag handle for the bottom sheet.
  //           Container(
  //             height: 4,
  //             width: 40,
  //             margin: const EdgeInsets.symmetric(vertical: 8),
  //             decoration: ShapeDecoration(
  //               color: context.moonColors!.beerus,
  //               shape: MoonSquircleBorder(
  //                 borderRadius: BorderRadius.circular(16).squircleBorderRadius(context),
  //               ),
  //             ),
  //           ),
  //           const Expanded(
  //             child: Align(
  //               child: Text('MoonBottomSheet example'),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //  }

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
              Text("Filters", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              Expanded(child: SingleChildScrollView(child: searchFilter())),
            ],
          ),
        );
      },
    );
  }

  Widget searchFilter() {
    TextEditingController authorSearchFieldTextController = TextEditingController(text: litSearchController.searchAuthors);
    return Obx(
      () => Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            LitSearchBar(
              margin: 0,
              prefixIcon: Ionicons.person,
              labelText: "Author",
              formKey: filtersformKey,
              onChanged: () {
                litSearchController.searchAuthors = authorSearchFieldTextController.text;
              },
              searchFieldTextController: authorSearchFieldTextController,
            ),
            CheckboxListTile(
              title: const Text("Search Tags (Commas)"),
              value: litSearchController.searchTags,
              contentPadding: EdgeInsets.zero,
              onChanged: (bool? value) {
                setState(() {
                  if (value == null) {
                    return;
                  }
                  litSearchController.searchTags = value;
                });
              },
            ),
            const SizedBox(height: 10),
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
            RadioMenuButton<SearchSortField>(
              value: SearchSortField.voteDesc,
              groupValue: litSearchController.sortOrder,
              onChanged: (value) {
                litSearchController.sortOrder = value!;
                litSearchController.sortString = SearchString.voteDesc;
              },
              child: const Text("Rating"),
            ),
            RadioMenuButton<SearchSortField>(
              value: SearchSortField.commentsDesc,
              groupValue: litSearchController.sortOrder,
              onChanged: (value) {
                litSearchController.sortOrder = value!;
                litSearchController.sortString = SearchString.commentsDesc;
              },
              child: const Text("Number of Comments"),
            ),
            const SizedBox(height: 20),
            LitMultiCategories(searchController: litSearchController),
            const SizedBox(height: 20),
            CheckboxMenuButton(
              value: litSearchController.isPopular,
              onChanged: (bool? value) {
                litSearchController.isPopular = value!;
              },
              child: const Text("Popular"),
            ),
            CheckboxMenuButton(
              value: litSearchController.isWinner,
              onChanged: (bool? value) {
                litSearchController.isWinner = value!;
              },
              child: const Text("Contest Winner"),
            ),
            CheckboxMenuButton(
              value: litSearchController.isEditorsChoice,
              onChanged: (bool? value) {
                litSearchController.isEditorsChoice = value!;
              },
              child: const Text("Editors Choice"),
            ),
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
