import 'package:lit_reader/models/author.dart';
import 'package:lit_reader/models/search_meta.dart';

class SearchResultMembers {
  final Meta? meta;
  final List<Author> data;

  SearchResultMembers({
    this.meta,
    required this.data,
  });

  factory SearchResultMembers.fromJson(Map<String, dynamic> json) {
    return SearchResultMembers(
      meta: Meta.fromJson(json['meta']),
      data: List<Author>.from(json['data'].map((x) => Author.fromJson(x))),
    );
  }

  factory SearchResultMembers.empty() {
    return SearchResultMembers(
      meta: null,
      data: [],
    );
  }
}
