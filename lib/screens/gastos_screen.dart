import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gasto_provider.dart';
import 'create_gasto_screen.dart';

class GastosScreen extends StatefulWidget {
  final int vehiculoId;
  final String vehiculoTitulo;

  const GastosScreen({
    super.key,
    required this.vehiculoId,
    required this.vehiculoTitulo,
  });

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  bool _huboCambios = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<GastoProvider>();

      await provider.cargarCategorias();
      await provider.cargarGastos(
        vehiculoId: widget.vehiculoId,
      );
    });
  }

  Future<void> abrirCrear() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateGastoScreen(
          vehiculoId: widget.vehiculoId,
        ),
      ),
    );

    if (res == true && mounted) {
      _huboCambios = true;

      final provider = context.read<GastoProvider>();

      await provider.cargarCategorias();
      await provider.cargarGastos(
        vehiculoId: widget.vehiculoId,
      );
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, _huboCambios);
    return false;
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GastoProvider>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gastos'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: abrirCrear,
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.money_off),
                  title: Text(widget.vehiculoTitulo),
                  subtitle: Text('Vehículo ID: ${widget.vehiculoId}'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (provider.errorMessage.isNotEmpty &&
                        provider.gastos.isEmpty) {
                      return Center(
                        child: Text(
                          provider.errorMessage,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (provider.gastos.isEmpty) {
                      return const Center(
                        child: Text('No hay gastos registrados'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<GastoProvider>().cargarCategorias();
                        await context.read<GastoProvider>().cargarGastos(
                              vehiculoId: widget.vehiculoId,
                            );
                      },
                      child: ListView.separated(
                        itemCount: provider.gastos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final gasto = provider.gastos[i];

                          final nombreCategoria =
                              provider.obtenerNombreCategoria(
                            gasto.categoriaId,
                            gasto.categoriaNombre,
                          );

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombreCategoria,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Descripción: ${_safeText(gasto.descripcion)}',
                                  ),
                                  Text(
                                    'Monto: ${_safeText(gasto.monto)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Fecha: ${_safeText(gasto.fecha)}',
                                  ),
                                ],
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
      ),
    );
  }
}