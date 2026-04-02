import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/perfil_provider.dart';
import '../providers/vehiculo_provider.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PerfilProvider>().cargarPerfil();
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

  Future<void> _seleccionarYSubirFoto() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;
    if (!mounted) return;

    final provider = context.read<PerfilProvider>();

    final ok = await provider.cambiarFotoPerfil(
      foto: File(pickedFile.path),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Foto de perfil actualizada correctamente' : provider.errorMessage,
        ),
      ),
    );
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String fotoUrl) {
    if (fotoUrl.trim().isEmpty) {
      return const CircleAvatar(
        radius: 44,
        backgroundColor: AppColors.card,
        child: Icon(Icons.person, size: 42, color: AppColors.primary),
      );
    }

    return CircleAvatar(
      radius: 44,
      backgroundImage: NetworkImage(fotoUrl),
      onBackgroundImageError: (_, __) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerfilProvider>();
    final perfil = provider.perfil;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage.isNotEmpty && perfil == null
              ? Center(child: Text(provider.errorMessage))
              : RefreshIndicator(
                  onRefresh: () => context.read<PerfilProvider>().cargarPerfil(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            children: [
                              _buildAvatar(perfil?.fotoUrl ?? ''),
                              const SizedBox(height: 14),
                              Text(
                                _safeText(perfil?.nombre),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _safeText(perfil?.correo),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: provider.isUpdatingPhoto
                                    ? null
                                    : _seleccionarYSubirFoto,
                                icon: provider.isUpdatingPhoto
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Icon(Icons.photo_camera),
                                label: Text(
                                  provider.isUpdatingPhoto
                                      ? 'Subiendo...'
                                      : 'Cambiar foto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildInfoCard(
                        'Matrícula',
                        _safeText(perfil?.matricula),
                        Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        'Correo',
                        _safeText(perfil?.correo),
                        Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _cerrarSesion,
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                ),
    );
  }
}