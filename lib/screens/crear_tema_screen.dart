import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehiculo_model.dart';
import '../providers/foro_provider.dart';
import '../providers/vehiculo_provider.dart';

class CrearTemaScreen extends StatefulWidget {
  const CrearTemaScreen({super.key});

  @override
  State<CrearTemaScreen> createState() => _CrearTemaScreenState();
}

class _CrearTemaScreenState extends State<CrearTemaScreen> {
  final _formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();

  VehiculoModel? vehiculoSeleccionado;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final vehiculoProvider = context.read<VehiculoProvider>();

      if (vehiculoProvider.vehiculos.isEmpty) {
        await vehiculoProvider.cargarVehiculos();
      }
    });
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (vehiculoSeleccionado?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un vehículo')),
      );
      return;
    }

    final provider = context.read<ForoProvider>();

    final ok = await provider.crearTema(
      vehiculoId: vehiculoSeleccionado!.id!,
      titulo: tituloController.text.trim(),
      descripcion: descripcionController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tema creado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foroProvider = context.watch<ForoProvider>();
    final vehiculoProvider = context.watch<VehiculoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo tema')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: vehiculoProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<VehiculoModel>(
                      value: vehiculoSeleccionado,
                      items: vehiculoProvider.vehiculos
                          .map(
                            (v) => DropdownMenuItem<VehiculoModel>(
                              value: v,
                              child: Text('${v.marca} ${v.modelo} - ${v.placa}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          vehiculoSeleccionado = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Vehículo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (_) {
                        if (vehiculoSeleccionado == null) {
                          return 'Seleccione un vehículo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Ingrese título' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Ingrese descripción'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: foroProvider.isLoading ? null : _guardar,
                        child: foroProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Publicar'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}