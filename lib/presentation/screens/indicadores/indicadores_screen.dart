import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/allpa_provider.dart';

class IndicadoresScreen extends StatelessWidget {
  const IndicadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AllpaProvider>();
    final summary = provider.resumenIndicadores;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicadores de campaña'),
        actions: [
          IconButton(
            tooltip: 'Copiar indicadores como CSV',
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: provider.exportIndicadoresCsv()),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Indicadores CSV copiados.')),
              );
            },
            icon: const Icon(Icons.copy_all_outlined),
          ),
        ],
      ),
      body: summary == null
          ? const Center(
              child: Text(
                'Registra terrenos y cultivos para calcular indicadores.',
              ),
            )
          : RefreshIndicator(
              onRefresh: provider.refreshAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Resumen general',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  _MetricTile(
                    label: 'Superficie de terrenos',
                    value:
                        '${summary.totalSuperficieTerrenosHa.toStringAsFixed(2)} ha',
                    icon: Icons.landscape,
                  ),
                  _MetricTile(
                    label: 'Superficie sembrada',
                    value:
                        '${summary.totalSuperficieSembradaHa.toStringAsFixed(2)} ha (${summary.porcentajeSuperficieSembradaGlobal.toStringAsFixed(1)}%)',
                    icon: Icons.grass,
                  ),
                  _MetricTile(
                    label: 'Semilla registrada',
                    value:
                        '${summary.totalSemillaKgGlobal.toStringAsFixed(1)} kg',
                    icon: Icons.spa,
                  ),
                  _MetricTile(
                    label: 'Jornales familiares',
                    value: summary.totalJornalesFamiliaresGlobal
                        .toStringAsFixed(1),
                    icon: Icons.groups,
                  ),
                  _MetricTile(
                    label: 'Producción registrada',
                    value:
                        '${summary.totalProduccionKgGlobal.toStringAsFixed(1)} kg',
                    icon: Icons.agriculture,
                  ),
                  _MetricTile(
                    label: 'Rendimiento promedio',
                    value:
                        '${summary.promedioRendimientoKgHa.toStringAsFixed(1)} kg/ha',
                    icon: Icons.insights,
                  ),
                  _MetricTile(
                    label: 'Desfase medio de siembra',
                    value:
                        '${summary.promedioDesfaseSiembraDias.toStringAsFixed(1)} días',
                    icon: Icons.event,
                  ),
                  _MetricTile(
                    label: 'Completitud de registros',
                    value:
                        '${summary.porcentajeRegistrosCompletosPromedio.toStringAsFixed(1)}%',
                    icon: Icons.fact_check,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Por cultivo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (provider.indicadoresCultivos.isEmpty)
                    const Text('No hay cultivos con indicadores disponibles.')
                  else
                    ...provider.indicadoresCultivos.map(
                      (item) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.especie} · ${item.variedad}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${item.terrenoNombre} · ${item.areaSembradaHa.toStringAsFixed(2)} ha sembradas',
                              ),
                              Text(
                                'Semilla: ${item.totalSemillaKg.toStringAsFixed(1)} kg · Jornales: ${item.jornalesFamiliaresTotal.toStringAsFixed(1)}',
                              ),
                              Text(
                                item.tieneCosecha
                                    ? 'Producción: ${item.produccionTotalKg.toStringAsFixed(1)} kg · Rendimiento: ${item.rendimientoKgHa?.toStringAsFixed(1) ?? '—'} kg/ha'
                                    : 'Cosecha aún no registrada',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryContainer,
        child: Icon(icon, color: AppColors.primaryDark),
      ),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
