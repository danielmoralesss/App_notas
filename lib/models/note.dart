import '../utils/constants.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final int colorValue;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.colorValue,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? title,
    String? content,
    int? colorValue,
    String? categoryId,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      colorValue: colorValue ?? this.colorValue,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'colorValue': colorValue,
        'categoryId': categoryId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static Note fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: (json['title'] as String?) ?? '',
        content: (json['content'] as String?) ?? '',
        colorValue: (json['colorValue'] as int?) ?? kDefaultColorValue,
        categoryId: (json['categoryId'] as String?) ?? kDefaultCategoryId,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
