import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lit_reader/data/categories.dart';
import 'package:lit_reader/env/consts.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/author.dart';
import 'package:lit_reader/models/category_search_result.dart';
import 'package:lit_reader/models/search_result.dart';
import 'package:lit_reader/models/search_result_members.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:logging/logging.dart';

final _logger = Logger('SearchController');

class SearchController extends GetxController {
  final _searchTerm = ''.obs;
  final _page = 1.obs;
  final _maxPage = 1.obs;
  final _selectedCategory = <String>[].obs;
  final _searchTags = false.obs;

  final _isPopular = false.obs;
  final _isWinner = false.obs;
  final _isEditorsChoice = false.obs;
  final _searchResults = <Submission>[].obs;
  final _memberResults = <Author>[].obs;
  final _tagList = <String>[].obs;
  final _categorySearch = false.obs;

  final _searchAuthors = ''.obs;
  String get searchAuthors => _searchAuthors.value;
  set searchAuthors(String value) => _searchAuthors.value = value;

  final _memberGenders = <AuthorGender>[].obs;
  List<AuthorGender> get memberGenders => _memberGenders;
  set memberGenders(List<AuthorGender> value) => _memberGenders.value = value;

  final _sortOrder = SearchSortField.relevant.obs;
  final RxnString _sortString = RxnString(null);

  String get searchTerm => _searchTerm.value;
  set searchTerm(String value) => _searchTerm.value = value;
  RxInterface get searchTermRx => _searchTerm;

  int get page => _page.value;
  set page(int value) => _page.value = value;

  int get maxPage => _maxPage.value;
  set maxPage(int value) => _maxPage.value = value;

  List<String> get selectedCategory => _selectedCategory;
  set selectedCategory(List<String> value) => _selectedCategory.value = value;

  bool get searchTags => _searchTags.value;
  set searchTags(bool value) {
    if (value == false && selectedCategory.length > 1) {
      selectedCategory = [(selectedCategory..sort((a, b) => b.compareTo(a))).first];
    }
    _searchTags.value = value;
  }

  SearchSortField get sortOrder => _sortOrder.value;
  set sortOrder(SearchSortField value) => _sortOrder.value = value;

  String? get sortString => _sortString.value;
  set sortString(String? value) => _sortString.value = value;

  bool get isPopular => _isPopular.value;
  set isPopular(bool value) => _isPopular.value = value;

  bool get isWinner => _isWinner.value;
  set isWinner(bool value) => _isWinner.value = value;

  bool get isEditorsChoice => _isEditorsChoice.value;
  set isEditorsChoice(bool value) => _isEditorsChoice.value = value;

  List<Submission> get searchResults => _searchResults;
  set searchResults(List<Submission> value) => _searchResults.value = value;

  List<Author> get memberResults => _memberResults;
  set memberResults(List<Author> value) => _memberResults.value = value;

  List<String> get tagList => _tagList;
  set tagList(List<String> value) => _tagList.value = value;
  RxInterface get tagListRx => _tagList;

  bool get categorySearch => _categorySearch.value;
  set categorySearch(bool value) => _categorySearch.value = value;

  final _categorySearchId = RxnInt(null);
  int? get categorySearchId => _categorySearchId.value;
  set categorySearchId(int? value) => _categorySearchId.value = value;
  RxInterface get categorySearchIdRx => _categorySearchId;

  final _newOnly = false.obs;
  bool get newOnly => _newOnly.value;
  set newOnly(bool value) => _newOnly.value = value;

  final _random = false.obs;
  bool get random => _random.value;
  set random(bool value) => _random.value = value;

  final _categories = <Category>[].obs;
  List<Category> get categories => _categories;
  set categories(List<Category> value) => _categories.value = value;
  RxInterface get categoriesRx => _categories;

  ///////////////////////UI index
  final _selectedIndex = 0.obs;
  final _selectedTabName = 'Search'.obs;
  final _selectedTabIcon = const Icon(
    Icons.search,
    color: Colors.white,
  ).obs;

  int get selectedIndex => _selectedIndex.value;
  set selectedIndex(int value) => _selectedIndex.value = value;

  String get selectedTabName => _selectedTabName.value;
  set selectedTabName(String value) => _selectedTabName.value = value;

  Icon get selectedTabIcon => _selectedTabIcon.value;
  set selectedTabIcon(Icon value) => _selectedTabIcon.value = value;

  void togglePageIndex() {
    if (selectedIndex == 0) {
      selectedIndex = 1;
      selectedTabIcon = const Icon(
        Icons.person,
        color: Colors.white,
      );
      selectedTabName = "Search Authors";
    } else {
      selectedIndex = 0;
      selectedTabIcon = const Icon(
        Icons.search,
        color: Colors.white,
      );
      selectedTabName = "Search Stories";
    }
  }

  ///

  Future<void> getCategories() async {
    List<Category> fetchedCategories = await api.getCategories();
    fetchedCategories.sort((a, b) => a.name.compareTo(b.name));
    Category allCategories = Category(
        id: 1,
        language: 1,
        ldesc: "",
        name: "Any Category",
        pageUrl: "",
        sdesc: "",
        topUrl: "",
        type: "story",
        submissionCount: 0);
    fetchedCategories.insert(0, allCategories);

    categories = fetchedCategories;
  }

  Future<void> search() async {
    if (searchTags) {
      if (tagList.isEmpty) {
        return;
      }

      SearchResult result = await api.beginSearchByTags(tagList,
          page: page,
          categories: selectedCategory,
          isPopular: isPopular,
          isWinner: isWinner,
          isEditorsChoice: isEditorsChoice,
          sortOrder: sortString);
      if (page == 1 && result.meta != null) {
        maxPage = (result.meta!.total / (result.meta!.pageSize)).ceil();
      }

      List<Submission> results = result.data;
      searchResults = results;

      _logger.info('page: $page');
      _logger.info('maxPage: $maxPage');
      return;
    } else if (categorySearch && categorySearchId != null) {
      CategorySearchResult result =
          await api.getCategoryStories(categoryId: categorySearchId ?? 1, page: page, random: random, newOnly: newOnly);
      if (page == 1 && result.meta != null) {
        {
          maxPage = (result.meta!.pages);
        }

        List<Submission> results = result.data;
        searchResults = results;

        _logger.info('page: $page');
        _logger.info('maxPage: $maxPage');
        return;
      }
    } else {
      if (searchTerm.isEmpty || searchTerm.length < 3) {
        return;
      }
      SearchResult result = await api.beginSearch(searchTerm,
          page: page,
          categories: selectedCategory,
          isPopular: isPopular,
          isWinner: isWinner,
          isEditorsChoice: isEditorsChoice,
          sortOrder: sortString,
          author: searchAuthors);
      if (page == 1 && result.meta != null) {
        maxPage = (result.meta!.total / (result.meta!.pageSize)).ceil();
      }

      List<Submission> results = result.data;
      searchResults = results;

      _logger.info('page: $page');
      _logger.info('maxPage: $maxPage');
    }
  }

  Future<void> searchMembers() async {
    if (searchTerm.isEmpty || searchTerm.length < 3) {
      return;
    }
    SearchResultMembers result =
        await api.beginAuthorSearch(searchTerm, genders: memberGenders, page: page, sortOrder: sortString);
    if (page == 1 && result.meta != null) {
      maxPage = (result.meta!.total / (result.meta!.pageSize)).ceil();
    }

    List<Author> results = result.data;
    memberResults = results;

    _logger.info('page: $page');
    _logger.info('maxPage: $maxPage');
  }
}
