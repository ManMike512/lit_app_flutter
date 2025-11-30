import 'package:lit_reader/models/page.dart';
import 'package:lit_reader/models/submission.dart';

class StoryDownload {
  final String url;
  final Submission submission;
  final List<StoryPage> pages;
  final DateTime? lastReadDate;

  StoryDownload({
    required this.url,
    required this.submission,
    required this.pages,
    this.lastReadDate,
  });

  factory StoryDownload.fromJson(Map<String, dynamic> json) {
    return StoryDownload(
      url: json['url'],
      submission: Submission.fromJson(json['submission'] as Map<String, dynamic>),
      pages: List<StoryPage>.from(json["pages"].map((x) => StoryPage.fromJson(x))),
      lastReadDate: json['lastReadDate'] != null ? DateTime.parse(json['lastReadDate']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'submission': submission.toJson(),
      'pages': List<dynamic>.from(pages.map((x) => x.toJson())),
      'lastReadDate': lastReadDate?.toLocal().toString() ?? DateTime.now().toLocal().toString(),
    };
  }
}
