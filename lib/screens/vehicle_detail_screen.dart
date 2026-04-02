import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/vehiculo_model.dart';
import '../providers/vehiculo_provider.dart';
import 'combustibles_screen.dart';
import 'edit_vehicle_screen.dart';
import 'gastos_screen.dart';
import 'gomas_screen.dart';
import 'ingresos_screen.dart';
import 'mantenimientos_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final VehiculoModel vehiculo;

  const VehicleDetailScreen({
    super.key,
    required this.vehiculo,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.vehiculo.id != null) {
      Future.microtask(() {
        context.read<VehiculoProvider>().cargarVehiculoDetalle(
              widget.vehiculo.id!,
            );
      });
    }
  }

  String _safeValue(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  Future<void> _refrescarDetalle() async {
    if (widget.vehiculo.id != null) {
      await context.read<VehiculoProvider>().cargarVehiculoDetalle(
            widget.vehiculo.id!,
          );
    }
  }

  Future<void> _abrirEditar() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditVehicleScreen(vehiculo: widget.vehiculo),
      ),
    );

    if (res == true && mounted) {
      await _refrescarDetalle();
      await context.read<VehiculoProvider>().cargarVehiculos();
    }
  }

  Widget _summaryCard(String title, dynamic value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 10),
              Text(
                '$value',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moduleTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiculoProvider>();
    final detalle = provider.vehiculoDetalle ?? {};

    final vehiculoData = detalle['vehiculo'] is Map<String, dynamic>
        ? detalle['vehiculo'] as Map<String, dynamic>
        : detalle;

    final resumen = detalle['resumen'] is Map<String, dynamic>
        ? detalle['resumen'] as Map<String, dynamic>
        : <String, dynamic>{};

    final tituloVehiculo =
        '${widget.vehiculo.marca} ${widget.vehiculo.modelo}'.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del vehículo'),
        actions: [
          IconButton(
            onPressed: _abrirEditar,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: provider.isDetailLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(provider.errorMessage),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refrescarDetalle,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                width: 74,
                                height: 74,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(
                                  Icons.directions_car,
                                  color: AppColors.primary,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _safeValue(
                                  '${vehiculoData['marca'] ?? widget.vehiculo.marca} '
                                  '${vehiculoData['modelo'] ?? widget.vehiculo.modelo}',
                                ),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    _infoRow('Placa', _safeValue(vehiculoData['placa'] ?? widget.vehiculo.placa)),
                                    _infoRow('Chasis', _safeValue(vehiculoData['chasis'] ?? widget.vehiculo.chasis)),
                                    _infoRow('Marca', _safeValue(vehiculoData['marca'] ?? widget.vehiculo.marca)),
                                    _infoRow('Modelo', _safeValue(vehiculoData['modelo'] ?? widget.vehiculo.modelo)),
                                    _infoRow('Año', _safeValue(vehiculoData['anio'] ?? widget.vehiculo.anio)),
                                    _infoRow('Ruedas', _safeValue(vehiculoData['cantidadRuedas'] ?? widget.vehiculo.cantidadRuedas)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _summaryCard(
                            'Gastos',
                            resumen['totalGastos'] ?? 0,
                            Icons.money_off,
                          ),
                          const SizedBox(width: 12),
                          _summaryCard(
                            'Ingresos',
                            resumen['totalIngresos'] ?? 0,
                            Icons.attach_money,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _summaryCard(
                            'Balance',
                            resumen['balance'] ?? 0,
                            Icons.account_balance_wallet,
                          ),
                          const SizedBox(width: 12),
                          _summaryCard(
                            'Invertido',
                            resumen['totalInvertido'] ?? 0,
                            Icons.savings_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Módulos del vehículo',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _moduleTile(
                        icon: Icons.build,
                        title: 'Mantenimientos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MantenimientosScreen(
                                vehiculoId: widget.vehiculo.id!,
                                vehiculoTitulo: tituloVehiculo,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _moduleTile(
                        icon: Icons.local_gas_station,
                        title: 'Combustible',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CombustiblesScreen(
                                vehiculoId: widget.vehiculo.id!,
                                vehiculoTitulo: tituloVehiculo,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _moduleTile(
                        icon: Icons.money_off,
                        title: 'Gastos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GastosScreen(
                                vehiculoId: widget.vehiculo.id!,
                                vehiculoTitulo: tituloVehiculo,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _moduleTile(
                        icon: Icons.attach_money,
                        title: 'Ingresos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IngresosScreen(
                                vehiculoId: widget.vehiculo.id!,
                                vehiculoTitulo: tituloVehiculo,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _moduleTile(
                        icon: Icons.tire_repair,
                        title: 'Gomas',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GomasScreen(
                                vehiculoId: widget.vehiculo.id!,
                                vehiculoTitulo: tituloVehiculo,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}