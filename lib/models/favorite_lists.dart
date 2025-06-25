class Lists {
  final int id;
  final String description;
  final int storiesCount;
  final String? submissionType;
  final String title;
  final String urlname;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final bool isPrivate;
  final bool isDeletable;

  Lists({
    required this.id,
    required this.description,
    required this.storiesCount,
    this.submissionType,
    required this.title,
    required this.urlname,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isPrivate = false,
    this.isDeletable = false,
  });

  factory Lists.fromJson(Map<String, dynamic> json) {
    return Lists(
      id: json['id'],
      description: json['description'],
      storiesCount: json['stories_count'],
      submissionType: json['submission_type'],
      title: json['title'],
      urlname: json['urlname'],
      userId: json['user_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isPrivate: json['is_private'] == 1,
      isDeletable: json['is_deletable'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'stories_count': storiesCount,
      'submission_type': submissionType,
      'title': title,
      'urlname': urlname,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_private': isPrivate,
      'is_deletable': isDeletable,
    };
  }

  Lists copyWith({
    int? id,
    String? description,
    int? storiesCount,
    String? submissionType,
    String? title,
    String? urlname,
    int? userId,
    String? createdAt,
    String? updatedAt,
    bool? isPrivate,
    bool? isDeletable,
  }) {
    return Lists(
      id: id ?? this.id,
      description: description ?? this.description,
      storiesCount: storiesCount ?? this.storiesCount,
      submissionType: submissionType ?? this.submissionType,
      title: title ?? this.title,
      urlname: urlname ?? this.urlname,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPrivate: isPrivate ?? this.isPrivate,
      isDeletable: isDeletable ?? this.isDeletable,
    );
  }
}
