import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/allpa_provider.dart';

class BitacoraScreen extends StatelessWidget {
  const BitacoraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AllpaProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: provider.filtroTerrenoId ?? 0,
                  decoration: const InputDecoration(
                    labelText: 'Terreno',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: 0, child: Text('Todos')),
                    ...provider.terrenos.map(
                      (t) => DropdownMenuItem(
                        value: t.id!,
                        child: Text(t.nombre, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (id) => provider.setBitacoraFilter(
                    terrenoId: id == null || id == 0 ? null : id,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: provider.filtroTipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    isDense: true,
                  ),
                  items:
                      const ['Todos', 'Siembra', 'Labor', 'Insumo', 'Cosecha']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (type) => provider.setBitacoraFilter(tipo: type),
                ),
              ),
              IconButton(
                tooltip: 'Copiar bitácora como CSV',
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: provider.exportBitacoraCsv()),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitácora CSV copiada al portapapeles.'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_all_outlined),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.bitacora.isEmpty
              ? const Center(
                  child: Text('Todavía no hay registros en la bitácora.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                  itemCount: provider.bitacora.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = provider.bitacora[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(
                            _iconFor(item.tipoRegistro),
                            color: AppColors.primaryDark,
                          ),
                        ),
                        title: Text(item.titulo),
                        subtitle: Text(
                          '${item.cultivoEspecie} · ${item.terrenoNombre}\n${item.fecha}\n${item.detalle}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _iconFor(String type) => switch (type) {
    'Siembra' => Icons.grass,
    'Labor' => Icons.handyman,
    'Insumo' => Icons.inventory_2,
    'Cosecha' => Icons.agriculture,
    _ => Icons.event_note,
  };
}
