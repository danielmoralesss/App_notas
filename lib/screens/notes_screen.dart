import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/notes_repo.dart';
import '../models/category.dart';
import '../models/note.dart';
import '../utils/constants.dart';
import '../widgets/note_card.dart';
import 'note_form_screen.dart';
import 'note_view_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _repo = NotesRepo();
  final _search = TextEditingController();

  List<Note> _notes = [];
  List<NoteCategory> _categories = [];
  String _selectedCategoryId = 'all';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final notes = await _repo.getAll();
    final categories = await _repo.getCategories();
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _categories = categories;
      if (_selectedCategoryId != 'all' &&
          !_categories.any((c) => c.id == _selectedCategoryId)) {
        _selectedCategoryId = 'all';
      }
    });
  }

  NoteCategory _categoryFor(String id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => NoteCategory.defaultCategory(),
    );
  }

  List<Note> get _visibleNotes {
    var list = _notes;
    if (_selectedCategoryId != 'all') {
      list = list.where((n) => n.categoryId == _selectedCategoryId).toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.content.toLowerCase().contains(q) ||
              _categoryFor(n.categoryId).name.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  int _countFor(String categoryId) {
    if (categoryId == 'all') return _notes.length;
    return _notes.where((n) => n.categoryId == categoryId).length;
  }

  Future<void> _openCreate() async {
    final initial = _selectedCategoryId == 'all'
        ? kDefaultCategoryId
        : _selectedCategoryId;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormScreen(
          categories: _categories,
          initialCategoryId: initial,
        ),
      ),
    );
    if (changed == true) await _load();
  }

  Future<void> _openEdit(Note note) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormScreen(
          editing: note,
          categories: _categories,
          initialCategoryId: note.categoryId,
        ),
      ),
    );
    if (changed == true) await _load();
  }

  Future<void> _openView(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteViewScreen(
          note: note,
          category: _categoryFor(note.categoryId),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text('¿Seguro que deseas eliminar "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _repo.delete(note.id);
      await _load();
    }
  }

  Future<void> _showCategoryDialog({NoteCategory? editing}) async {
    final controller = TextEditingController(text: editing?.name ?? '');
    int colorValue = editing?.colorValue ?? AppColors.azulUnison.value;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(editing == null ? 'Nueva carpeta' : 'Editar carpeta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la carpeta *',
                  hintText: 'Ej. Escuela, Trabajo, Personal',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Color', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  AppColors.azulUnison.value,
                  AppColors.doradoUnison.value,
                  0xFF2E7D32,
                  0xFF6A1B9A,
                  0xFFC62828,
                ].map((v) {
                  final selected = colorValue == v;
                  return GestureDetector(
                    onTap: () => setDialogState(() => colorValue = v),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(v),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.black : Colors.black26,
                          width: selected ? 3 : 1,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    final name = controller.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de la carpeta es obligatorio.')),
      );
      return;
    }

    final category = editing == null
        ? NoteCategory(
            id: const Uuid().v4(),
            name: name,
            colorValue: colorValue,
            createdAt: DateTime.now(),
          )
        : editing.copyWith(name: name, colorValue: colorValue);

    await _repo.upsertCategory(category);
    await _load();
  }

  Future<void> _confirmDeleteCategory(NoteCategory category) async {
    if (category.id == kDefaultCategoryId) return;

    final count = _countFor(category.id);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar carpeta'),
        content: Text(
          count == 0
              ? '¿Eliminar la carpeta "${category.name}"?'
              : 'La carpeta "${category.name}" tiene $count nota(s). Si la eliminas, esas notas se moverán a General.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _repo.deleteCategory(category.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = _visibleNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis notas'),
        actions: [
          IconButton(
            tooltip: 'Ir al inicio',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nota'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.azulOscuroUnison,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Organización por carpetas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_notes.length} nota(s) • ${_categories.length} carpeta(s)',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _search,
                    onChanged: (value) => setState(() {
                      _query = value;
                    }),
                    decoration: InputDecoration(
                      hintText: 'Buscar notas o carpetas...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _search.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 84,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'Todas',
                    count: _countFor('all'),
                    color: AppColors.ink,
                    selected: _selectedCategoryId == 'all',
                    onTap: () => setState(() => _selectedCategoryId = 'all'),
                  ),
                  ..._categories.map(
                    (c) => _CategoryChip(
                      label: c.name,
                      count: _countFor(c.id),
                      color: Color(c.colorValue),
                      selected: _selectedCategoryId == c.id,
                      onTap: () => setState(() => _selectedCategoryId = c.id),
                      onLongPress: c.id == kDefaultCategoryId
                          ? null
                          : () => _showCategoryOptions(c),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.create_new_folder_rounded),
                      label: const Text('Nueva carpeta'),
                      onPressed: () => _showCategoryDialog(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notes.isEmpty
                  ? _EmptyState(
                      hasNotes: _notes.isNotEmpty,
                      onCreate: _openCreate,
                      onCreateCategory: () => _showCategoryDialog(),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final note = notes[i];
                        return NoteCard(
                          note: note,
                          category: _categoryFor(note.categoryId),
                          onTap: () => _openView(note),
                          onEdit: () => _openEdit(note),
                          onDelete: () => _confirmDelete(note),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryOptions(NoteCategory category) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.folder_rounded, color: Color(category.colorValue)),
              title: Text(category.name),
              subtitle: Text('${_countFor(category.id)} nota(s)'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Editar carpeta'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: const Text('Eliminar carpeta'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (action == 'edit') {
      await _showCategoryDialog(editing: category);
    } else if (action == 'delete') {
      await _confirmDeleteCategory(category);
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CategoryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: ChoiceChip(
          selected: selected,
          onSelected: (_) => onTap(),
          avatar: Icon(
            Icons.folder_rounded,
            size: 18,
            color: selected ? Colors.white : color,
          ),
          selectedColor: color,
          label: Text('$label ($count)'),
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide(color: color.withOpacity(0.45)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasNotes;
  final VoidCallback onCreate;
  final VoidCallback onCreateCategory;

  const _EmptyState({
    required this.hasNotes,
    required this.onCreate,
    required this.onCreateCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.note_alt_outlined, size: 76, color: AppColors.azulUnison),
            const SizedBox(height: 16),
            Text(
              hasNotes ? 'No hay resultados con ese filtro.' : 'Aún no tienes notas.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea carpetas para separar escuela, trabajo, pendientes o ideas personales.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.35),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear nota'),
            ),
            TextButton.icon(
              onPressed: onCreateCategory,
              icon: const Icon(Icons.create_new_folder_rounded),
              label: const Text('Crear carpeta'),
            ),
          ],
        ),
      ),
    );
  }
}
