import 'package:lit_reader/models/submission.dart';

class ReadHistory {
  final String url;
  final Submission submission;
  final DateTime? lastReadDate;

  ReadHistory({
    required this.url,
    required this.submission,
    this.lastReadDate,
  });

  factory ReadHistory.fromJson(Map<String, dynamic> json) {
    return ReadHistory(
      url: json['url'],
      submission: Submission.fromJson(json['submission'] as Map<String, dynamic>),
      lastReadDate: json['lastReadDate'] != null ? DateTime.parse(json['lastReadDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'submission': submission.toJson(),
      'lastReadDate': lastReadDate?.toLocal().toString() ?? DateTime.now().toLocal().toString(),
    };
  }
}
