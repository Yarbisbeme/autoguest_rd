import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ingreso_provider.dart';
import 'create_ingreso_screen.dart';

class IngresosScreen extends StatefulWidget {
  final int vehiculoId;
  final String vehiculoTitulo;

  const IngresosScreen({
    super.key,
    required this.vehiculoId,
    required this.vehiculoTitulo,
  });

  @override
  State<IngresosScreen> createState() => _IngresosScreenState();
}

class _IngresosScreenState extends State<IngresosScreen> {
  bool _huboCambios = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<IngresoProvider>().cargarIngresos(
            vehiculoId: widget.vehiculoId,
          );
    });
  }

  Future<void> abrirCrear() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateIngresoScreen(
          vehiculoId: widget.vehiculoId,
        ),
      ),
    );

    if (res == true && mounted) {
      _huboCambios = true;

      await context.read<IngresoProvider>().cargarIngresos(
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
    final provider = context.watch<IngresoProvider>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Ingresos')),
        floatingActionButton: FloatingActionButton(
          onPressed: abrirCrear,
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.ingresos.isEmpty
                  ? const Center(child: Text('No hay ingresos registrados'))
                  : ListView.builder(
                      itemCount: provider.ingresos.length,
                      itemBuilder: (_, i) {
                        final ingreso = provider.ingresos[i];

                        return Card(
                          child: ListTile(
                            title: Text(_safeText(ingreso.concepto)),
                            subtitle: Text('Fecha: ${_safeText(ingreso.fecha)}'),
                            trailing: Text(
                              _safeText(ingreso.monto),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}