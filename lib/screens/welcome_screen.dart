import 'package:flutter/material.dart';

import '../utils/constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goNotes(BuildContext context) {
    Navigator.pushNamed(context, '/notes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.azulOscuroUnison,
              AppColors.azulUnison,
              Color(0xFF062D55),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset('assets/images/ESCUDO-COLOR.png', height: 110),
                      const SizedBox(height: 18),
                      const Text(
                        'UniNotas Carpetas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Organiza tus ideas por carpetas, colores y contenido local.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.muted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Daniel Morales\nDilan Bañuelos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.doradoUnison,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => _goNotes(context),
                  icon: const Icon(Icons.folder_rounded),
                  label: const Text(
                    'Entrar a mis notas',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => _goNotes(context),
                  child: const Text(
                    'También puedes tocar aquí para continuar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
