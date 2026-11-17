import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/allpa_provider.dart';
import '../cultivos/cultivo_form_screen.dart';
import '../cultivos/cultivo_detail_screen.dart';
import 'terreno_form_screen.dart';

class TerrenoDetailScreen extends StatelessWidget {
  final int terrenoId;

  const TerrenoDetailScreen({super.key, required this.terrenoId});

  Future<void> _confirmarEliminacion(BuildContext context) async {
    final prov = context.read<AllpaProvider>();
    final cultivos = prov.cultivos.where((c) => c.terrenoId == terrenoId).toList();

    if (cultivos.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 48),
          title: const Text('No se puede eliminar'),
          content: Text(
            'El terreno tiene ${cultivos.length} cultivo(s) asociado(s). Por regla de integridad de datos, primero debe gestionar o eliminar dichos cultivos.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ENTENDIDO'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Terreno'),
        content: const Text(
          '¿Está seguro de que desea eliminar este terreno? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      try {
        await prov.deleteTerreno(terrenoId);
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terreno eliminado correctamente.'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AllpaProvider>();
    final terreno = prov.terrenos.where((t) => t.id == terrenoId).firstOrNull;

    if (terreno == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del Terreno')),
        body: const Center(child: Text('Terreno no encontrado.')),
      );
    }

    final cultivos = prov.cultivos.where((c) => c.terrenoId == terrenoId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(terreno.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar terreno',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TerrenoFormScreen(terreno: terreno),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar terreno',
            onPressed: () => _confirmarEliminacion(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ficha técnica del terreno
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E5DC), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.landscape, size: 32, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              terreno.nombre,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              terreno.ubicacion ?? 'Illpe, sector sin especificar',
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricBox(
                        title: 'Superficie Total',
                        value: '${terreno.areaHa.toStringAsFixed(2)} ha',
                        color: AppColors.primary,
                      ),
                      _MetricBox(
                        title: 'Área Sembrada',
                        value: '${terreno.areaSembradaTotal.toStringAsFixed(2)} ha',
                        color: AppColors.tertiary,
                      ),
                      _MetricBox(
                        title: 'Área Libre',
                        value: '${(terreno.areaHa - terreno.areaSembradaTotal).clamp(0.0, terreno.areaHa).toStringAsFixed(2)} ha',
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección de cultivos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CULTIVOS EN ESTE TERRENO',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CultivoFormScreen(terrenoId: terrenoId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('AGREGAR CULTIVO'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (cultivos.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.grass, size: 48, color: AppColors.outlineVariant),
                    const SizedBox(height: 10),
                    const Text(
                      'No hay cultivos sembrados en este terreno',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Puedes registrar papa, maíz, cebada, trigo u otro cultivo.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CultivoFormScreen(terrenoId: terrenoId),
                          ),
                        );
                      },
                      child: const Text('SEMBRAR NUEVO CULTIVO'),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cultivos.length,
                itemBuilder: (context, index) {
                  final c = cultivos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.eco, color: AppColors.primaryDark),
                      ),
                      title: Text(
                        '${c.especie} (${c.variedad ?? "Variedad común"})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        'Superficie: ${c.areaSembradaHa} ha • Estado: ${c.estado}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CultivoDetailScreen(cultivoId: c.id!),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricBox({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
