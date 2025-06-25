import 'package:lit_reader/extensions/numeric.dart';
import 'package:lit_reader/models/favorite_lists.dart';
import 'package:lit_reader/models/favorite_listscontent.dart';
import 'package:lit_reader/models/last_update.dart';

class Author {
  final String aim;
  final String? bio;
  final String? biography;
  final int commentsCount;
  final int customtitle;
  final String drink;
  final String editorStatus;
  final int favoriteStoriesCount;
  final int followedStoriesCount;
  final int followersCount;
  final int followingsCount;
  final int hasPhoto;
  final String? homepage;
  final String icq;
  final String joindate;
  final String? location;
  final int options;
  final String? pets;
  final String smoke;
  final int storiesCount;
  final int poemsCount;
  final int illustrationsCount;
  final int audiosCount;
  final int inksCount;
  final int seriesCount;
  final int storiesAndSeriesCount;
  final int audiosAndSeriesCount;
  final int poemsAndSeriesCount;
  final int illustrasAndSeriesCount;
  final int inksAndSeriesCount;
  final int submissionsCount;
  final int userid;
  final String username;
  final String userpic;
  final String usertitle;
  final dynamic favoritesCount;
  final LastUpdate lastUpdate;
  final String joindateApprox;
  final String lastUpdateApprox;
  final int allowfeedback;
  final int disableAllFeedback;
  final List<Lists> lists;
  final Listscontent listscontent;
  final String supportMeService;
  final dynamic supportMeLink;

  Author({
    required this.aim,
    this.bio,
    this.biography,
    required this.commentsCount,
    required this.customtitle,
    required this.drink,
    required this.editorStatus,
    required this.favoriteStoriesCount,
    required this.followedStoriesCount,
    required this.followersCount,
    required this.followingsCount,
    required this.hasPhoto,
    required this.homepage,
    required this.icq,
    required this.joindate,
    this.location,
    required this.options,
    this.pets,
    required this.smoke,
    required this.storiesCount,
    required this.poemsCount,
    required this.illustrationsCount,
    required this.audiosCount,
    required this.inksCount,
    required this.seriesCount,
    required this.storiesAndSeriesCount,
    required this.audiosAndSeriesCount,
    required this.poemsAndSeriesCount,
    required this.illustrasAndSeriesCount,
    required this.inksAndSeriesCount,
    required this.submissionsCount,
    required this.userid,
    required this.username,
    required this.userpic,
    required this.usertitle,
    required this.favoritesCount,
    required this.lastUpdate,
    required this.joindateApprox,
    required this.lastUpdateApprox,
    required this.allowfeedback,
    required this.disableAllFeedback,
    required this.lists,
    required this.listscontent,
    required this.supportMeService,
    required this.supportMeLink,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      aim: json['aim'].toString(),
      bio: json['bio'],
      biography: json['biography'],
      commentsCount: IntUtils.tryParseNull(json['comments_count']),
      customtitle: IntUtils.tryParseNull(json['customtitle']),
      drink: json['drink'] ?? "",
      editorStatus: json['editor_status'] ?? "",
      favoriteStoriesCount: IntUtils.tryParseNull(json['favorite_stories_count']),
      followedStoriesCount: IntUtils.tryParseNull(json['followed_stories_count']),
      followersCount: IntUtils.tryParseNull(json['followers_count']),
      followingsCount: IntUtils.tryParseNull(json['followings_count']),
      hasPhoto: IntUtils.tryParseNull(json['has_photo']),
      homepage: json['homepage'],
      icq: json['icq'].toString(),
      joindate: json['joindate'] ?? "",
      location: json['location'],
      options: IntUtils.tryParseNull(json['options']),
      pets: json['pets'],
      smoke: json['smoke'] ?? "",
      storiesCount: IntUtils.tryParseNull(json['stories_count']),
      poemsCount: IntUtils.tryParseNull(json['poems_count']),
      illustrationsCount: IntUtils.tryParseNull(json['illustrations_count']),
      audiosCount: IntUtils.tryParseNull(json['audios_count']),
      inksCount: IntUtils.tryParseNull(json['inks_count']),
      seriesCount: IntUtils.tryParseNull(json['series_count']),
      storiesAndSeriesCount: IntUtils.tryParseNull(json['stories_and_series_count']),
      audiosAndSeriesCount: IntUtils.tryParseNull(json['audios_and_series_count']),
      poemsAndSeriesCount: IntUtils.tryParseNull(json['poems_and_series_count']),
      illustrasAndSeriesCount: IntUtils.tryParseNull(json['illustras_and_series_count']),
      inksAndSeriesCount: IntUtils.tryParseNull(json['inks_and_series_count']),
      submissionsCount: IntUtils.tryParseNull(json['submissions_count']),
      userid: json['id'] != null ? int.tryParse(json['id']) : json['userid'],
      username: json['username'],
      userpic: json['userpic'],
      usertitle: json['usertitle'] ?? "",
      favoritesCount: json['favorites_count'] ?? 0,
      lastUpdate: json['last_update'] != null
          ? json['last_update'] is Map
              ? LastUpdate.fromJson(json['last_update'])
              : LastUpdate(date: json['last_update'], timezoneType: 0, timezone: '')
          : LastUpdate(date: '', timezoneType: 0, timezone: ''),
      joindateApprox: json['joindate_approx'] ?? '',
      lastUpdateApprox: json['last_update_approx'] ?? '',
      allowfeedback: json['allowfeedback'] ?? 0,
      disableAllFeedback: json['disable_all_feedback'] ?? 0,
      lists: json['lists'] != null ? List<Lists>.from(json['lists'].map((x) => Lists.fromJson(x))) : [],
      listscontent: json['listscontent'] != null && (json['listscontent'] is Map)
          ? Listscontent.fromJson(json['listscontent'])
          : Listscontent(content: {}),
      supportMeService: json['support_me_service'] ?? '',
      supportMeLink: json['support_me_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aim': aim,
      'bio': bio,
      'biography': biography,
      'comments_count': commentsCount,
      'customtitle': customtitle,
      'drink': drink,
      'editor_status': editorStatus,
      'favorite_stories_count': favoriteStoriesCount,
      'followed_stories_count': followedStoriesCount,
      'followers_count': followersCount,
      'followings_count': followingsCount,
      'has_photo': hasPhoto,
      'homepage': homepage,
      'icq': icq,
      'joindate': joindate,
      'location': location,
      'options': options,
      'pets': pets,
      'smoke': smoke,
      'stories_count': storiesCount,
      'poems_count': poemsCount,
      'illustrations_count': illustrationsCount,
      'audios_count': audiosCount,
      'inks_count': inksCount,
      'series_count': seriesCount,
      'stories_and_series_count': storiesAndSeriesCount,
      'audios_and_series_count': audiosAndSeriesCount,
      'poems_and_series_count': poemsAndSeriesCount,
      'illustras_and_series_count': illustrasAndSeriesCount,
      'inks_and_series_count': inksAndSeriesCount,
      'submissions_count': submissionsCount,
      'userid': userid,
      'username': username,
      'userpic': userpic,
      'usertitle': usertitle,
      'favorites_count': favoritesCount,
      'last_update': lastUpdate.toJson(),
      'joindate_approx': joindateApprox,
      'last_update_approx': lastUpdateApprox,
      'allowfeedback': allowfeedback,
      'disable_all_feedback': disableAllFeedback,
      'lists': lists,
      'listscontent': listscontent.toJson(),
      'support_me_service': supportMeService,
      'support_me_link': supportMeLink,
    };
  }
}
