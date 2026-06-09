import 'package:hive/hive.dart';

import '../models/category.dart';
import '../models/note.dart';
import '../utils/constants.dart';

class NotesRepo {
  static const String boxName = 'notes_box';
  static const String keyNotes = 'notes';
  static const String keyCategories = 'categories';

  Future<Box> _box() async => Hive.openBox(boxName);

  Future<List<Note>> getAll() async {
    final box = await _box();
    final raw = (box.get(keyNotes) as List?) ?? [];
    final notes = raw
        .map((e) => Note.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<void> saveAll(List<Note> notes) async {
    final box = await _box();
    await box.put(keyNotes, notes.map((n) => n.toJson()).toList());
  }

  Future<void> upsert(Note note) async {
    final notes = await getAll();
    final idx = notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      notes[idx] = note;
    } else {
      notes.add(note);
    }
    await saveAll(notes);
  }

  Future<void> delete(String id) async {
    final notes = await getAll();
    notes.removeWhere((n) => n.id == id);
    await saveAll(notes);
  }

  Future<List<NoteCategory>> getCategories() async {
    final box = await _box();
    final raw = (box.get(keyCategories) as List?) ?? [];
    final categories = raw
        .map((e) => NoteCategory.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    if (!categories.any((c) => c.id == kDefaultCategoryId)) {
      categories.insert(0, NoteCategory.defaultCategory());
    }

    categories.sort((a, b) {
      if (a.id == kDefaultCategoryId) return -1;
      if (b.id == kDefaultCategoryId) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });
    return categories;
  }

  Future<void> saveCategories(List<NoteCategory> categories) async {
    final box = await _box();
    final normalized = categories
        .where((c) => c.name.trim().isNotEmpty)
        .toList(growable: false);
    await box.put(keyCategories, normalized.map((c) => c.toJson()).toList());
  }

  Future<void> upsertCategory(NoteCategory category) async {
    final categories = await getCategories();
    final idx = categories.indexWhere((c) => c.id == category.id);
    if (idx >= 0) {
      categories[idx] = category;
    } else {
      categories.add(category);
    }
    await saveCategories(categories);
  }

  Future<void> deleteCategory(String id) async {
    if (id == kDefaultCategoryId) return;

    final categories = await getCategories();
    categories.removeWhere((c) => c.id == id);
    await saveCategories(categories);

    final notes = await getAll();
    final migrated = notes
        .map((n) => n.categoryId == id
            ? n.copyWith(categoryId: kDefaultCategoryId, updatedAt: DateTime.now())
            : n)
        .toList();
    await saveAll(migrated);
  }
}
