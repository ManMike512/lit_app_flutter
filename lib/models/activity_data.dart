// import 'package:lit_reader/models/author.dart';
// import 'package:lit_reader/models/categoryInfo.dart';
import 'package:lit_reader/models/submission.dart';
// import 'package:lit_reader/models/tag.dart';

class ActivityData {
  final String id;
  final String action;
  final int when;
  final Who who;
  final Submission what;

  ActivityData({
    required this.id,
    required this.action,
    required this.when,
    required this.who,
    required this.what,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      id: json['id'],
      action: json['action'],
      when: json['when'],
      who: Who.fromJson(json['who']),
      what: Submission.fromJson(json['what']),
    );
  }
}

class Who {
  final int userid;
  final String username;
  final String userpic;

  Who({
    required this.userid,
    required this.username,
    required this.userpic,
  });

  factory Who.fromJson(Map<String, dynamic> json) {
    return Who(
      userid: json['userid'],
      username: json['username'],
      userpic: json['userpic'],
    );
  }
}

// class What {
//   final int allowVote;
//   final int allowDownload;
//   final Author author;
//   final String authorname;
//   final CategoryInfo categoryInfo;
//   final int category;
//   final int commentCount;
//   final int contestWinner;
//   final String dateApprove;
//   final String description;
//   final int enableComments;
//   final int favoriteCount;
//   final int id;
//   final bool isHot;
//   final bool isNew;
//   final int language;
//   final int newlanguage;
//   final double rateAll;
//   final int readingListsCount;
//   final List<Tag> tags;
//   final String title;
//   final String type;
//   final String url;
//   final int viewCount;
//   final bool writersPick;
//   final String status;

//   What({
//     required this.allowVote,
//     required this.allowDownload,
//     required this.author,
//     required this.authorname,
//     required this.categoryInfo,
//     required this.category,
//     required this.commentCount,
//     required this.contestWinner,
//     required this.dateApprove,
//     required this.description,
//     required this.enableComments,
//     required this.favoriteCount,
//     required this.id,
//     required this.isHot,
//     required this.isNew,
//     required this.language,
//     required this.newlanguage,
//     required this.rateAll,
//     required this.readingListsCount,
//     required this.tags,
//     required this.title,
//     required this.type,
//     required this.url,
//     required this.viewCount,
//     required this.writersPick,
//     required this.status,
//   });

//   factory What.fromJson(Map<String, dynamic> json) {
//     return What(
//       allowVote: json['allow_vote'],
//       allowDownload: json['allow_download'],
//       author: Author.fromJson(json['author']),
//       authorname: json['authorname'],
//       categoryInfo: CategoryInfo.fromJson(json['category_info']),
//       category: json['category'],
//       commentCount: json['comment_count'],
//       contestWinner: json['contest_winner'],
//       dateApprove: json['date_approve'],
//       description: json['description'],
//       enableComments: json['enable_comments'],
//       favoriteCount: json['favorite_count'],
//       id: json['id'],
//       isHot: json['is_hot'],
//       isNew: json['is_new'],
//       language: json['language'],
//       newlanguage: json['newlanguage'],
//       rateAll: json['rate_all'].toDouble(),
//       readingListsCount: json['reading_lists_count'],
//       tags: List<Tag>.from(json['tags'].map((x) => Tag.fromJson(x))),
//       title: json['title'],
//       type: json['type'],
//       url: json['url'],
//       viewCount: json['view_count'],
//       writersPick: json['writers_pick'],
//       status: json['status'],
//     );
//   }
// }
