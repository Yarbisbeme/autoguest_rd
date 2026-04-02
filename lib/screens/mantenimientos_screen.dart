import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mantenimiento_provider.dart';
import 'create_mantenimiento_screen.dart';

class MantenimientosScreen extends StatefulWidget {
  final int vehiculoId;
  final String vehiculoTitulo;

  const MantenimientosScreen({
    super.key,
    required this.vehiculoId,
    required this.vehiculoTitulo,
  });

  @override
  State<MantenimientosScreen> createState() => _MantenimientosScreenState();
}

class _MantenimientosScreenState extends State<MantenimientosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MantenimientoProvider>().cargarMantenimientos(
            vehiculoId: widget.vehiculoId,
          );
    });
  }

  Future<void> abrirCrearMantenimiento() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMantenimientoScreen(
          vehiculoId: widget.vehiculoId,
        ),
      ),
    );

    if (creado == true && mounted) {
      await context.read<MantenimientoProvider>().cargarMantenimientos(
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
    final provider = context.watch<MantenimientoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimientos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCrearMantenimiento,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_car),
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

                  if (provider.mantenimientos.isEmpty) {
                    return const Center(
                      child: Text('No hay mantenimientos registrados'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<MantenimientoProvider>()
                        .cargarMantenimientos(
                          vehiculoId: widget.vehiculoId,
                        ),
                    child: ListView.separated(
                      itemCount: provider.mantenimientos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = provider.mantenimientos[index];

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
                                Text('Descripción: ${_safeText(item.descripcion)}'),
                                Text('Costo: ${_safeText(item.costo)}'),
                                Text('Fecha: ${_safeText(item.fecha)}'),
                                const SizedBox(height: 8),
                                if (item.fotos.isNotEmpty) ...[
                                  const Text(
                                    'Fotos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 90,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: item.fotos.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, fotoIndex) {
                                        final foto = item.fotos[fotoIndex];

                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            foto,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) => Container(
                                              width: 90,
                                              height: 90,
                                              color: Colors.grey.shade300,
                                              child: const Icon(Icons.image),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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