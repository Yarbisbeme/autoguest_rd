import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/perfil_provider.dart';
import '../providers/vehiculo_provider.dart';
import 'catalogo_screen.dart';
import 'foro_screen.dart';
import 'login_screen.dart';
import 'noticias_screen.dart';
import 'perfil_screen.dart';
import 'vehiculos_screen.dart';
import 'videos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<PerfilProvider>().cargarPerfil();
      await context.read<VehiculoProvider>().cargarVehiculos();
    });
  }

  Future<void> _cerrarSesion() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;

    context.read<PerfilProvider>().limpiar();
    context.read<VehiculoProvider>().limpiar();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _refrescar() async {
    await context.read<PerfilProvider>().cargarPerfil();
    await context.read<VehiculoProvider>().cargarVehiculos();
  }

  @override
  Widget build(BuildContext context) {
    final perfilProvider = context.watch<PerfilProvider>();
    final vehiculoProvider = context.watch<VehiculoProvider>();

    final nombre = perfilProvider.perfil?.nombre ?? 'Usuario';
    final correo = perfilProvider.perfil?.correo ?? '-';
    final totalVehiculos = vehiculoProvider.vehiculos.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoGest RD'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilScreen()),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refrescar,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.card,
                      AppColors.primary.withOpacity(0.20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: perfilProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primary.withOpacity(0.18),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bienvenido de vuelta',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nombre,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  correo,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: 'Vehículos',
                      value: '$totalVehiculos',
                      icon: Icons.directions_car,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      title: 'Perfil',
                      value: 'Activo',
                      icon: Icons.verified_user_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Accesos rápidos',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _quickCard(
                    'Vehículos',
                    Icons.directions_car,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VehiculosScreen(),
                      ),
                    ),
                  ),
                  _quickCard(
                    'Foro',
                    Icons.forum,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForoScreen(),
                      ),
                    ),
                  ),
                  _quickCard(
                    'Noticias',
                    Icons.article,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NoticiasScreen(),
                      ),
                    ),
                  ),
                  _quickCard(
                    'Videos',
                    Icons.ondemand_video,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VideosScreen(),
                      ),
                    ),
                  ),
                  _quickCard(
                    'Catálogo',
                    Icons.list_alt,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CatalogoScreen(),
                      ),
                    ),
                  ),
                  _quickCard(
                    'Perfil',
                    Icons.person_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerfilScreen(),
                      ),
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

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}