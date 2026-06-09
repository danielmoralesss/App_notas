import '../utils/constants.dart';

class NoteCategory {
  final String id;
  final String name;
  final int colorValue;
  final DateTime createdAt;

  const NoteCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
  });

  NoteCategory copyWith({String? name, int? colorValue}) {
    return NoteCategory(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'createdAt': createdAt.toIso8601String(),
      };

  static NoteCategory fromJson(Map<String, dynamic> json) => NoteCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        colorValue: (json['colorValue'] as int?) ?? kDefaultColorValue,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static NoteCategory defaultCategory() => NoteCategory(
        id: kDefaultCategoryId,
        name: 'General',
        colorValue: AppColors.azulUnison.value,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
}
