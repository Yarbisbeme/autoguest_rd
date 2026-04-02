import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/combustible_provider.dart';
import 'create_combustible_screen.dart';

class CombustiblesScreen extends StatefulWidget {
  final int vehiculoId;
  final String vehiculoTitulo;

  const CombustiblesScreen({
    super.key,
    required this.vehiculoId,
    required this.vehiculoTitulo,
  });

  @override
  State<CombustiblesScreen> createState() => _CombustiblesScreenState();
}

class _CombustiblesScreenState extends State<CombustiblesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CombustibleProvider>().cargarCombustibles(
            vehiculoId: widget.vehiculoId,
          );
    });
  }

  Future<void> abrirCrearCombustible() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCombustibleScreen(
          vehiculoId: widget.vehiculoId,
        ),
      ),
    );

    if (creado == true && mounted) {
      await context.read<CombustibleProvider>().cargarCombustibles(
            vehiculoId: widget.vehiculoId,
          );
    }
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CombustibleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Combustible'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCrearCombustible,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_gas_station),
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

                  if (provider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        provider.errorMessage,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (provider.combustibles.isEmpty) {
                    return const Center(
                      child: Text('No hay registros de combustible'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<CombustibleProvider>()
                        .cargarCombustibles(
                          vehiculoId: widget.vehiculoId,
                        ),
                    child: ListView.separated(
                      itemCount: provider.combustibles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = provider.combustibles[index];

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _safeText(item.tipo),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Cantidad: ${_safeText(item.cantidad)} ${_safeText(item.unidad)}',
                                ),
                                Text('Monto: ${_safeText(item.monto)}'),
                                Text('Fecha: ${_safeText(item.fecha)}'),
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
    );
  }
}