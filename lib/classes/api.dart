import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lit_reader/data/categories.dart';
import 'package:lit_reader/env/consts.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/account.dart';
import 'package:lit_reader/models/activity_wall.dart';
import 'package:lit_reader/models/author.dart';
import 'package:lit_reader/models/category_search_result.dart';
import 'package:lit_reader/models/favorite_lists.dart';
import 'package:lit_reader/models/list.dart';
import 'package:lit_reader/models/search_result.dart';
import 'package:lit_reader/models/search_result_members.dart';
import 'package:lit_reader/models/story.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/models/tag.dart';
import 'package:lit_reader/models/tag_search_results.dart';
import 'package:lit_reader/models/token.dart';
import 'package:logging/logging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _logger = Logger('API');

final cookieJar = CookieJar();

class API {
  Future<Token> login(String username, String password) async {
    Account account = Account(login: username, password: password);
    try {
      dioController.dio.interceptors.add(CookieManager(cookieJar));
      const url = '${authUrl}login';

      final response = await dioController.dio.post(
        url,
        data: account.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        Token token = await fetchToken();
        return token;
      } else {
        toast(response.data ?? 'Login failed');
        return Token(token: null, expires: null);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      toast(e.toString());
      return Token(token: null, expires: null);
    }
  }

  Future<Token> fetchToken() async {
    try {
      //validate login request
      var validateUrl = '${authUrl}check?timestamp=${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
      final validateResponse = await dioController.dio.get(
        validateUrl,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (validateResponse.statusCode != 200) {
        Token refreshedToken = await loginController.login();
        return refreshedToken;
      }

      var tokenResponse = validateResponse.data;
      _logger.info('Token response: $tokenResponse');

      Map<String, dynamic> decodedToken = JwtDecoder.decode(tokenResponse);
      int timestamp = decodedToken['exp'];
      DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

      Token token = Token(token: tokenResponse, expires: expirationDate);
      return token;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      toast(e.toString());
      return Token(token: null, expires: null);
    }
  }

  Future<bool> logout() async {
    await loginController.isTokenValid();
    if (loginController.loginState != LoginState.loggedIn) {
      // loginController.dispose();
      return false;
    }

    try {
      //logout request
      const url = '${authUrl}session/logout';
      final response = await dioController.dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': loginController.token.token!,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 401) {
        loginController.token = Token();
        loginController.loginState = LoginState.loggedOut;
        final SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.remove('token');
        loginController.password = "";
        // preferences.remove('username');
        preferences.remove('password');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      toast(e.toString());
      return false;
    } finally {
      // loginController.dispose();
    }
  }

  Future<Story> getStory(String storyURL, {int page = 1}) async {
    try {
      final url = '${apiUrl}stories/$storyURL?params={"contentPage":$page}';
      _logger.info('Get Story: $url');

      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return Story.fromJson(response.data);
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return Story.empty();
    } finally {}
  }

  Future<List<Submission>> getSeries(int seriesId) async {
    try {
      final url = '${apiUrl}series/$seriesId/works';
      _logger.info('Get Story Series: $url');

      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<Submission> series = response.data.map<Submission>((list) => Submission.fromJson(list)).toList();

      return series;
    } finally {}
  }

  Future<Author> getAuthor(int userId) async {
    try {
      final url = '${apiUrl}authors/$userId';
      _logger.info('Get Author details : $url');

      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      Map<String, dynamic>? data;
      if (response.data is List && response.data.length > 0) {
        data = response.data[0];
      } else {
        data = response.data;
      }

      return Author.fromJson(data!);
    } finally {}
  }

  Future<List<Category>> getCategories() async {
    try {
      const url = '${apiUrl}stories/categories?params={"period":"all","language":1,"public_domain":true}';
      _logger.info('Get Categories: $url');

      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        return [];
      }

      final List<Category> categories = response.data.map<Category>((list) => Category.fromJson(list)).toList();

      return categories;
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return [];
    } finally {}
  }

  Future<SearchResult> getAuthorStories(String authorUserName,
      {int page = 1,
      String? searchTerm,
      List<String> categories = const [],
      bool isPopular = false,
      bool isWinner = false,
      bool isEditorsChoice = false,
      String? sortOrder}) async {
    var url = '${apiUrl}search/stories?params={"author":"$authorUserName","page":$page,"languages":[1]';

    if (categories.isNotEmpty) {
      url += ',"categories":[${categories.join(',')}]';
    }
    if (isPopular) {
      url += ',"popular":true';
    }
    if (isWinner) {
      url += ',"winner":true';
    }
    if (isEditorsChoice) {
      url += ',"editorsChoice":true';
    }
    if (sortOrder != null) {
      url += ',"sort":"$sortOrder"';
    }
    if (searchTerm != null && searchTerm.isNotEmpty) {
      url += ',"q":"$searchTerm"';
    }
    url += '}';

    _logger.info('Called: $url');

    try {
      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final SearchResult searchResult = SearchResult.fromJson(response.data);

      return searchResult;
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return SearchResult.empty();
    }
  }

  Future<List<Submission>> getSimilarStories(String storyURL) async {
    try {
      final url = '${apiUrl}stories/$storyURL/similar';
      _logger.info('Get Similar Story: $url');
      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<Submission> series = response.data.map<Submission>((list) => Submission.fromJson(list)).toList();

      return series;
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return [];
    }
  }

  Future<ActivityWall> getFeed({int limit = 25, String? lastId}) async {
    await loginController.isTokenValid();
    if (loginController.loginState != LoginState.loggedIn) {
      if (loginController.username.isNotEmpty && loginController.password.isNotEmpty) {
        await loginController.login();
      } else {
        return ActivityWall(data: [], new_activity_count: 0);
      }
    }

    try {
      var url = '${apiUrl}activity/wall?params={"chunked":1,"limit":$limit';

      if (lastId != null) {
        url += ',"last_id":$lastId';
      }
      url += '}';

      _logger.info('Called: $url');

      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': loginController.token.token!,
          },
        ),
      );

      if (response.statusCode == 200) {
        final ActivityWall feed = ActivityWall.fromJson(response.data);

        return feed;
      }

      return ActivityWall(data: [], new_activity_count: 0);
    } catch (e) {
      // ignore: avoid_print
      print(e);
      toast(e.toString());
      return ActivityWall(data: [], new_activity_count: 0);
    } finally {}
  }

  Future<ActivityWall> getOldFeed({int limit = 25, String? lastId}) async {
    await loginController.isTokenValid();
    if (loginController.loginState != LoginState.loggedIn) {
      if (loginController.username.isNotEmpty && loginController.password.isNotEmpty) {
        await loginController.login();
      } else {
        return ActivityWall(data: [], new_activity_count: 0);
      }
    }

    try {
      var url = '${apiUrl}activity/old/wall?params={"chunked":1,"limit":$limit';

      if (lastId != null) {
        url += ',"last_id":$lastId';
      }
      url += '}';

      _logger.info('Called: $url');

      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': loginController.token.token!,
          },
        ),
      );

      if (response.statusCode == 200) {
        final ActivityWall feed = ActivityWall.fromJson(response.data);

        return feed;
      }

      return ActivityWall(data: [], new_activity_count: 0);
    } catch (e) {
      // ignore: avoid_print
      print(e);
      toast(e.toString());
      return ActivityWall(data: [], new_activity_count: 0);
    } finally {}
  }

  Future<SearchResult> beginSearch(String searchTerm,
      {int page = 1,
      List<String> categories = const [],
      bool isPopular = false,
      bool isWinner = false,
      bool isEditorsChoice = false,
      String? sortOrder,
      String? author}) async {
    var url = '${apiUrl}search/stories?params={"q":"$searchTerm","page":$page,"languages":[1]';

    if (categories.isNotEmpty) {
      url += ',"categories":[${categories.join(',')}]';
    }
    if (isPopular) {
      url += ',"popular":true';
    }
    if (isWinner) {
      url += ',"winner":true';
    }
    if (isEditorsChoice) {
      url += ',"editorsChoice":true';
    }
    if (sortOrder != null) {
      url += ',"sort":"$sortOrder"';
    }
    if (author != null && author.isNotEmpty) {
      url += ',"author":"$author"';
    }
    url += '}';

    _logger.info('Called: $url');

    try {
      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final SearchResult searchResult = SearchResult.fromJson(response.data);

      return searchResult;
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return SearchResult.empty();
    }
  }

  Future<SearchResultMembers> beginAuthorSearch(String searchTerm,
      {int page = 1, List<AuthorGender> genders = const [], String? sortOrder}) async {
    var url = '${apiUrl}search/members?params={"q":"$searchTerm","page":$page,"languages":[1],"user_type":"authors"';

    if (genders.isNotEmpty) {
      url += ',"sex":[${genders.map((g) => "\"${g.apiValue}\"").join(',')}]';
    }

    if (sortOrder != null) {
      url += ',"sort":"$sortOrder"';
    }
    url += '}';

    _logger.info('Called: $url');

    try {
      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final SearchResultMembers searchResult = SearchResultMembers.fromJson(response.data);

      return searchResult;
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return SearchResultMembers.empty();
    }
  }

  Future<CategorySearchResult> getCategoryStories({
    required int categoryId,
    int limit = 25,
    int page = 1,
    bool random = false,
    bool newOnly = false,
  }) async {
    List<Map<String, dynamic>> filters = [];
    filters.add({"property": "type", "value": "story"});
    filters.add({"property": "category_id", "value": categoryId});

    if (random && !newOnly) {
      filters.add({"property": "random", "value": "yes"});
    }
    if (newOnly && !random) {
      filters.add({"property": "newonly", "value": "yes"});
    }

    var url = '${apiUrlV1}submissions';

    url += '?filter=${jsonEncode(filters)}';

    url += '&appid=$app_id';
    url += '&apikey=$api_key';
    url += '&page=$page';
    url += '&limit=$limit';

    _logger.info('Called: $url');

    try {
      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final CategorySearchResult searchResult = CategorySearchResult.fromJson(response.data);

      return searchResult;
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return CategorySearchResult.empty();
    }
  }

  Future<SearchResult> beginSearchByTags(List<String> tagList,
      {int page = 1,
      List<String> categories = const [],
      bool isPopular = false,
      bool isWinner = false,
      bool isEditorsChoice = false,
      String? sortOrder}) async {
    var url = '${apiUrl}search/stories?params={"q":"${tagList.join(", ")}","page":$page,"languages":[1],"where":"tags"';

    if (categories.isNotEmpty) {
      url += ',"categories":[${categories.join(',')}]';
    }
    if (isPopular) {
      url += ',"popular":true';
    }
    if (isWinner) {
      url += ',"winner":true';
    }
    if (isEditorsChoice) {
      url += ',"editorsChoice":true';
    }
    if (sortOrder != null) {
      url += ',"sort":"$sortOrder"';
    }
    url += '}';

    _logger.info('Called: $url');

    try {
      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final SearchResult searchResult = SearchResult.fromJson(response.data);

      return searchResult;
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return SearchResult.empty();
    }
  }

  Future<List<Lists>> getLists() async {
    await loginController.isTokenValid();
    if (loginController.loginState != LoginState.loggedIn) {
      if (loginController.username.isNotEmpty && loginController.password.isNotEmpty) {
        await loginController.login();
      } else {
        // loginController.dispose();
        return [];
      }
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(loginController.token.token!);
    var userid = decodedToken['sub'];
    final url = '${apiUrl}users/$userid/lists';

    try {
      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': loginController.token.token!,
          },
        ),
      );
      List<Lists> lists = response.data.map<Lists>((list) => Lists.fromJson(list)).toList();
      List<String> excludedListTypes = ['poem', 'audio', 'illustra', 'sg'];
      lists = lists.where((list) => !excludedListTypes.contains(list.submissionType)).toList();

      return lists;
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return [];
    } finally {
      // loginController.dispose();
    }
  }

  Future<bool> toggleListItem(int storyId, int listId, bool addToList) async {
    await loginController.isTokenValid();
    if (loginController.loginState != LoginState.loggedIn) {
      if (loginController.username.isNotEmpty && loginController.password.isNotEmpty) {
        await loginController.login();
      } else {
        return false;
      }
    }

    try {
      final url = '${apiUrl}stories/$storyId/lists/$listId';
      if (addToList) {
        final response = await dioController.dio.put(
          url,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': loginController.token.token!,
            },
          ),
        );
        if (response.statusCode == 200) {
          await listController.fetchLists();
          return true;
        }
      } else {
        final response = await dioController.dio.delete(
          url,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': loginController.token.token!,
            },
          ),
        );
        if (response.statusCode == 200) {
          await listController.fetchLists();
          return true;
        }
      }

      return false;
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return false;
    }
  }

  Future<List<Tag>> getPopularTags() async {
    try {
      const url = '${apiUrl}tagsportal/top?params={"limit":500,"periodCheck":true,"period":"all","language":1}';
      _logger.info('Called: $url');

      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // 'Authorization': loginController.token.token!,
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<Tag> lists = TagSearchResults.fromJson(response.data).tags;

        return lists;
      }

      return [];
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return [];
    } finally {}
  }

  Future<List<int>> getListsWithStory(String storyId) async {
    await loginController.isTokenValid();
    if (loginController.loginState != LoginState.loggedIn) {
      if (loginController.username.isNotEmpty && loginController.password.isNotEmpty) {
        await loginController.login();
      } else {
        // loginController.dispose();
        return [];
      }
    }

    try {
      final url = '${apiUrl}stories/$storyId/lists';

      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': loginController.token.token!,
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          List<int> lists = (response.data as List).map<int>((item) => item as int).toList();
          return lists;
        }
      }

      return [];
    } catch (e) {
      _logger.info(e);
      toast(e.toString());
      return [];
    } finally {}
  }

  Future<ListItem> getListItems(String listUrl, {int page = 1, String? searchTerm}) async {
    await loginController.isTokenValid();
    if (loginController.loginState != LoginState.loggedIn) {
      if (loginController.username.isNotEmpty && loginController.password.isNotEmpty) {
        await loginController.login();
      } else {
        return ListItem(list: null, works: null);
      }
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(loginController.token.token!);
    var userid = decodedToken['sub'];

    try {
      final url = '${apiUrl}users/$userid/lists/$listUrl?params={"s":"${searchTerm ?? ''}","page":"$page","sort":"dateadd"}';
      _logger.info('Called: $url');
      // ignore: avoid_print
      print('Called: $url');

      final response = await dioController.dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': loginController.token.token!,
          },
        ),
      );

      final ListItem listItem = ListItem.fromJson(response.data);

      return listItem;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      toast(e.toString());
      return ListItem(list: null, works: null);
    } finally {}
  }
}
