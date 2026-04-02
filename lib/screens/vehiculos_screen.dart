import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/vehiculo_provider.dart';
import '../widgets/app_section_title.dart';
import 'create_vehicle_screen.dart';
import 'vehicle_detail_screen.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final TextEditingController marcaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VehiculoProvider>().cargarVehiculos();
    });
  }

  @override
  void dispose() {
    marcaController.dispose();
    super.dispose();
  }

  Future<void> abrirCrearVehiculo() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateVehicleScreen()),
    );

    if (creado == true && mounted) {
      await context.read<VehiculoProvider>().cargarVehiculos();
    }
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiculoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis vehículos'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        onPressed: abrirCrearVehiculo,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppSectionTitle(
              title: 'Tus vehículos',
              subtitle: 'Consulta, crea y administra tu garage',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: marcaController,
              decoration: InputDecoration(
                labelText: 'Filtrar por marca',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    provider.cargarVehiculos(
                      marca: marcaController.text.trim(),
                    );
                  },
                  icon: const Icon(Icons.tune),
                ),
              ),
              onSubmitted: (value) {
                provider.cargarVehiculos(marca: value.trim());
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        provider.errorMessage,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (provider.vehiculos.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 50,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No hay vehículos registrados',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.cargarVehiculos(
                      marca: marcaController.text.trim(),
                    ),
                    child: ListView.separated(
                      itemCount: provider.vehiculos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final vehiculo = provider.vehiculos[index];

                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: vehiculo.id == null
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VehicleDetailScreen(
                                          vehiculo: vehiculo,
                                        ),
                                      ),
                                    );
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_safeText(vehiculo.marca)} ${_safeText(vehiculo.modelo)}',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Placa: ${_safeText(vehiculo.placa)}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          'Año: ${_safeText(vehiculo.anio)}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}