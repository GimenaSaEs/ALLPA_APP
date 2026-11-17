import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../providers/allpa_provider.dart';
import 'bitacora/bitacora_screen.dart';
import 'cultivos/cultivos_list_screen.dart';
import 'indicadores/indicadores_screen.dart';
import 'perfil/perfil_screen.dart';
import 'terrenos/terrenos_list_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _DashboardOverview(
        onNavigate: (index) => setState(() => _selectedIndex = index),
      ),
      const TerrenosListScreen(),
      const CultivosListScreen(),
      const BitacoraScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'ALLPA'
              : ['Inicio', 'Terrenos', 'Cultivos', 'Bitácora'][_selectedIndex],
        ),
        actions: [
          IconButton(
            tooltip: 'Mi perfil',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfilScreen()),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.landscape_outlined),
            selectedIcon: Icon(Icons.landscape),
            label: 'Terrenos',
          ),
          NavigationDestination(
            icon: Icon(Icons.grass_outlined),
            selectedIcon: Icon(Icons.grass),
            label: 'Cultivos',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Bitácora',
          ),
        ],
      ),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AllpaProvider>();
    final summary = provider.resumenIndicadores;
    final farmer = provider.agricultor;

    return RefreshIndicator(
      onRefresh: provider.refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.eco, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'ALLPA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Bienvenido${farmer == null ? '' : ', ${farmer.nombre}'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gestión de cultivos agrícolas',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                const Chip(
                  avatar: Icon(
                    Icons.offline_pin,
                    size: 18,
                    color: AppColors.primaryDark,
                  ),
                  label: Text('Datos almacenados en este dispositivo'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Resumen de campaña',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.landscape,
                  label: 'Terrenos',
                  value: '${provider.terrenos.length}',
                ),
              ),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.grass,
                  label: 'Cultivos',
                  value: '${provider.cultivos.length}',
                ),
              ),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.agriculture,
                  label: 'Sembrado',
                  value:
                      '${summary?.totalSuperficieSembradaHa.toStringAsFixed(1) ?? '0.0'} ha',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Accesos rápidos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.landscape,
            title: 'Administrar terrenos',
            subtitle: 'Registra y consulta parcelas',
            onTap: () => onNavigate(1),
          ),
          _ActionTile(
            icon: Icons.grass,
            title: 'Administrar cultivos',
            subtitle: 'Cultivo, siembra, labores e insumos',
            onTap: () => onNavigate(2),
          ),
          _ActionTile(
            icon: Icons.menu_book,
            title: 'Bitácora agrícola',
            subtitle: 'Consulta actividades registradas',
            onTap: () => onNavigate(3),
          ),
          _ActionTile(
            icon: Icons.insights,
            title: 'Indicadores',
            subtitle: 'Resumen de recursos y producción',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IndicadoresScreen()),
            ),
          ),
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryContainer,
        child: Icon(icon, color: AppColors.primaryDark),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
