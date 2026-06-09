import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/notes_repo.dart';
import '../models/category.dart';
import '../models/note.dart';
import '../utils/constants.dart';
import '../widgets/color_picker.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? editing;
  final List<NoteCategory> categories;
  final String initialCategoryId;

  const NoteFormScreen({
    super.key,
    this.editing,
    required this.categories,
    required this.initialCategoryId,
  });

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _repo = NotesRepo();
  final _title = TextEditingController();
  final _content = TextEditingController();

  int _colorValue = kDefaultColorValue;
  late String _categoryId;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _categoryId = widget.initialCategoryId;
    if (e != null) {
      _title.text = e.title;
      _content.text = e.content;
      _colorValue = e.colorValue;
      _categoryId = e.categoryId;
    }
    if (!widget.categories.any((c) => c.id == _categoryId)) {
      _categoryId = kDefaultCategoryId;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio.')),
      );
      return;
    }

    final now = DateTime.now();
    final old = widget.editing;
    final note = Note(
      id: old?.id ?? const Uuid().v4(),
      title: title,
      content: _content.text.trim(),
      colorValue: _colorValue,
      categoryId: _categoryId,
      createdAt: old?.createdAt ?? now,
      updatedAt: now,
    );

    await _repo.upsert(note);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bg = Color(_colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar nota' : 'Nueva nota'),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        color: bg.withOpacity(0.42),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.93),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: bg.withOpacity(0.85), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      hintText: 'Ej. Lista de compras',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _content,
                    maxLines: 7,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Contenido',
                      hintText: 'Escribe aquí los detalles de la nota...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _categoryId,
                    decoration: const InputDecoration(labelText: 'Carpeta'),
                    items: widget.categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Row(
                              children: [
                                Icon(Icons.folder_rounded,
                                    color: Color(c.colorValue), size: 18),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _categoryId = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Color de la nota',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  NoteColorPicker(
                    selected: _colorValue,
                    onSelected: (v) => setState(() => _colorValue = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _save,
                    child: Text(_isEditing ? 'Guardar cambios' : 'Crear nota'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
