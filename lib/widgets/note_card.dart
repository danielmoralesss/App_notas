import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/note.dart';
import '../utils/constants.dart';
import '../utils/date_format.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final NoteCategory category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Color(note.colorValue);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(22),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content.isEmpty ? '(Sin contenido)' : note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Color(category.colorValue).withOpacity(0.55),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_rounded,
                            size: 15, color: Color(category.colorValue)),
                        const SizedBox(width: 5),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatDate(note.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withOpacity(0.58),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
