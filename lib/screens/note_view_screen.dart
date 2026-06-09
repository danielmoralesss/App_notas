import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/note.dart';
import '../utils/constants.dart';
import '../utils/date_format.dart';

class NoteViewScreen extends StatelessWidget {
  final Note note;
  final NoteCategory category;

  const NoteViewScreen({
    super.key,
    required this.note,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Color(note.colorValue);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de nota')),
      body: Container(
        color: bg.withOpacity(0.42),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.folder_rounded, color: Color(category.colorValue)),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Creada: ${formatDate(note.createdAt)}\nActualizada: ${formatDate(note.updatedAt)}',
                    style: const TextStyle(color: AppColors.muted, height: 1.45),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    note.content.isEmpty ? '(Sin contenido)' : note.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
