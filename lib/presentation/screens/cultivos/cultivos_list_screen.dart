import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/allpa_provider.dart';
import 'cultivo_detail_screen.dart';
import 'cultivo_form_screen.dart';

class CultivosListScreen extends StatelessWidget {
  const CultivosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AllpaProvider>();
    final cultivos = provider.cultivos;
    return Scaffold(
      body: cultivos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.grass, size: 64, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text(
                      'Aún no hay cultivos registrados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.terrenos.isEmpty
                          ? 'Primero registra un terreno para agregar un cultivo.'
                          : 'Registra un cultivo para iniciar su seguimiento.',
                      textAlign: TextAlign.center,
                    ),
                    if (provider.terrenos.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _nuevoCultivo(context),
                        icon: const Icon(Icons.add),
                        label: const Text('REGISTRAR CULTIVO'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
              itemCount: cultivos.length,
              itemBuilder: (context, index) {
                final cultivo = cultivos[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(Icons.grass, color: AppColors.primaryDark),
                    ),
                    title: Text(
                      '${cultivo.especie}${cultivo.variedad == null ? '' : ' · ${cultivo.variedad}'}',
                    ),
                    subtitle: Text(
                      '${cultivo.terrenoNombre ?? 'Terreno'} · ${cultivo.areaSembradaHa} ha · ${cultivo.estado}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CultivoDetailScreen(cultivoId: cultivo.id!),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: provider.terrenos.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _nuevoCultivo(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo cultivo'),
            ),
    );
  }

  void _nuevoCultivo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CultivoFormScreen()),
    );
  }
}
