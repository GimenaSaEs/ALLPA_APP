import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/allpa_provider.dart';
import '../plan_siembra/plan_siembra_form_screen.dart';
import '../labores/labor_form_screen.dart';
import '../insumos/insumo_form_screen.dart';
import '../cosechas/cosecha_form_screen.dart';
import 'cultivo_form_screen.dart';

class CultivoDetailScreen extends StatefulWidget {
  final int cultivoId;

  const CultivoDetailScreen({super.key, required this.cultivoId});

  @override
  State<CultivoDetailScreen> createState() => _CultivoDetailScreenState();
}

class _CultivoDetailScreenState extends State<CultivoDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmarEliminacion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Cultivo'),
        content: const Text(
          '¿Está seguro de eliminar este cultivo? Se eliminarán también sus labores, insumos y plan de siembra asociados.',
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

    if (confirmar == true && mounted) {
      try {
        await context.read<AllpaProvider>().deleteCultivo(widget.cultivoId);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cultivo eliminado correctamente.'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
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
    final cultivo = prov.cultivos.where((c) => c.id == widget.cultivoId).firstOrNull;

    if (cultivo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del Cultivo')),
        body: const Center(child: Text('Cultivo no encontrado.')),
      );
    }

    final labores = prov.labores.where((l) => l.cultivoId == widget.cultivoId).toList();
    final insumos = prov.insumos.where((i) => i.cultivoId == widget.cultivoId).toList();
    final cosecha = prov.cosechas.where((cos) => cos.cultivoId == widget.cultivoId).firstOrNull;

    // Calcular jornales totales de labores
    final totalJornalesLabores = labores.fold<double>(0.0, (sum, l) => sum + l.jornales);

    return Scaffold(
      appBar: AppBar(
        title: Text('${cultivo.especie} - ${cultivo.variedad ?? "Común"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar cultivo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CultivoFormScreen(cultivo: cultivo),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar cultivo',
            onPressed: () => _confirmarEliminacion(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: const [
            Tab(icon: Icon(Icons.info_outline, size: 20), text: 'Resumen'),
            Tab(icon: Icon(Icons.agriculture, size: 20), text: 'Labores'),
            Tab(icon: Icon(Icons.inventory_2, size: 20), text: 'Insumos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: RESUMEN GENERAL Y PLAN
          _buildResumenTab(context, cultivo, cosecha, totalJornalesLabores),

          // TAB 2: LABORES
          _buildLaboresTab(context, labores),

          // TAB 3: INSUMOS
          _buildInsumosTab(context, insumos),
        ],
      ),
    );
  }

  Widget _buildResumenTab(
    BuildContext context,
    dynamic cultivo,
    dynamic cosecha,
    double totalJornalesLabores,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta Principal del Cultivo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E5DC), width: 1.2),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.eco, size: 30, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cultivo.especie} (${cultivo.variedad ?? "Común"})',
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Terreno: ${cultivo.terrenoNombre ?? "Terreno de Illpe"}',
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cultivo.estado == 'Cosechado'
                            ? AppColors.tertiaryContainer
                            : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cultivo.estado,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cultivo.estado == 'Cosechado'
                              ? const Color(0xFF7A4A00)
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MetricColumn(
                      label: 'Superficie',
                      value: '${cultivo.areaSembradaHa} ha',
                      color: AppColors.secondary,
                    ),
                    _MetricColumn(
                      label: 'Fecha Inicio',
                      value: DateFormatter.toDisplay(cultivo.fechaInicio),
                      color: AppColors.primary,
                    ),
                    _MetricColumn(
                      label: 'Jornales Labores',
                      value: '$totalJornalesLabores',
                      color: AppColors.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // MÓDULO 4: PLAN DE SIEMBRA Y DESFASE
          _buildPlanSiembraCard(context, cultivo),
          const SizedBox(height: 18),

          // MÓDULO 7: COSECHA Y RENDIMIENTO
          _buildCosechaCard(context, cosecha),
          const SizedBox(height: 24),

          // ACCIONES RÁPIDAS
          const Text(
            'REGISTROS RÁPIDOS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LaborFormScreen(cultivoId: widget.cultivoId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.handyman, size: 18),
                  label: const Text('Registrar Labor'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InsumoFormScreen(cultivoId: widget.cultivoId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Registrar Insumo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSiembraCard(BuildContext context, dynamic cultivo) {
    final tienePrevista = cultivo.fechaPrevista != null && cultivo.fechaPrevista.toString().isNotEmpty;
    final tieneReal = cultivo.fechaReal != null && cultivo.fechaReal.toString().isNotEmpty;
    final desfase = cultivo.desfaseDias;

    Color badgeColor = AppColors.primary;
    String badgeText = 'Al día';
    if (desfase != null) {
      if (desfase > 0) {
        badgeColor = AppColors.warning;
        badgeText = 'Desfase de +$desfase días';
      } else if (desfase == 0) {
        badgeColor = AppColors.success;
        badgeText = 'Siembra puntual (0 días)';
      } else {
        badgeColor = AppColors.info;
        badgeText = 'Adelantada ($desfase días)';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E5DC), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Planificación de Siembra',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlanSiembraFormScreen(cultivoId: widget.cultivoId),
                    ),
                  );
                },
                child: Text(tienePrevista || tieneReal ? 'MODIFICAR' : 'CONFIGURAR'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fecha Prevista', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      DateFormatter.toDisplay(cultivo.fechaPrevista),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fecha Efectiva', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      DateFormatter.toDisplay(cultivo.fechaReal),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: badgeColor.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, size: 18, color: badgeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    desfase != null
                        ? 'Indicador de Manejo: $badgeText'
                        : 'Plan sin fechas completas para calcular desfase.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: badgeColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosechaCard(BuildContext context, dynamic cosecha) {
    final tieneCosecha = cosecha != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E5DC), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text(
                    'Registro de Cosecha y Rendimiento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CosechaFormScreen(
                        cultivoId: widget.cultivoId,
                        cosecha: cosecha,
                      ),
                    ),
                  );
                },
                child: Text(tieneCosecha ? 'EDITAR' : 'REGISTRAR'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (tieneCosecha) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricColumn(
                  label: 'Producción Total',
                  value: '${cosecha.produccionKg} kg',
                  color: AppColors.primary,
                ),
                _MetricColumn(
                  label: 'Rendimiento',
                  value: '${cosecha.rendimientoKgHa ?? "--"} kg/ha',
                  color: AppColors.tertiary,
                ),
                _MetricColumn(
                  label: 'Productividad',
                  value: '${cosecha.productividadKgJornal ?? "--"} kg/jornal',
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha de cosecha: ${DateFormatter.toDisplay(cosecha.fecha)} • Área cosechada: ${cosecha.areaHa} ha • Jornales: ${cosecha.jornales}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ] else ...[
            const Text(
              'Aún no se ha registrado la cosecha de este cultivo. Al culminar el ciclo agrícola, registre los kg obtenidos y la superficie para calcular el rendimiento automático.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLaboresTab(BuildContext context, List<dynamic> labores) {
    if (labores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.handyman, size: 60, color: AppColors.outlineVariant),
              const SizedBox(height: 12),
              const Text(
                'No hay labores registradas para este cultivo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registre actividades como preparación del terreno, siembra, riego, abonado, deshierbo, etc.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LaborFormScreen(cultivoId: widget.cultivoId),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('REGISTRAR PRIMERA LABOR'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: labores.length,
        itemBuilder: (context, index) {
          final l = labores[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: const Icon(Icons.agriculture, color: AppColors.primaryDark),
              ),
              title: Text(l.tipo, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Fecha: ${DateFormatter.toDisplay(l.fecha)} • ${l.jornales} jornales familiares\n${l.nota ?? ""}'.trim(),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LaborFormScreen(
                        cultivoId: widget.cultivoId,
                        labor: l,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_labor',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LaborFormScreen(cultivoId: widget.cultivoId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInsumosTab(BuildContext context, List<dynamic> insumos) {
    if (insumos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 60, color: AppColors.outlineVariant),
              const SizedBox(height: 12),
              const Text(
                'No hay insumos registrados para este cultivo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registre semillas, abonos, fertilizantes u otros insumos utilizados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InsumoFormScreen(cultivoId: widget.cultivoId),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('REGISTRAR PRIMER INSUMO'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: insumos.length,
        itemBuilder: (context, index) {
          final ins = insumos[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.secondaryContainer,
                child: const Icon(Icons.science, color: AppColors.secondary),
              ),
              title: Text('${ins.tipo}: ${ins.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Cantidad: ${ins.cantidad} ${ins.unidad} • Fecha: ${DateFormatter.toDisplay(ins.fecha)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InsumoFormScreen(
                        cultivoId: widget.cultivoId,
                        insumo: ins,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_insumo',
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InsumoFormScreen(cultivoId: widget.cultivoId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
