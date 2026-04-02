import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gasto_categoria_model.dart';
import '../providers/gasto_provider.dart';

class CreateGastoScreen extends StatefulWidget {
  final int vehiculoId;

  const CreateGastoScreen({
    super.key,
    required this.vehiculoId,
  });

  @override
  State<CreateGastoScreen> createState() => _CreateGastoScreenState();
}

class _CreateGastoScreenState extends State<CreateGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final descripcionController = TextEditingController();
  final montoController = TextEditingController();

  GastoCategoriaModel? categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GastoProvider>().cargarCategorias();
    });
  }

  @override
  void dispose() {
    descripcionController.dispose();
    montoController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (categoriaSeleccionada?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una categoría')),
      );
      return;
    }

    final provider = context.read<GastoProvider>();

    final ok = await provider.crearGasto(
      vehiculoId: widget.vehiculoId,
      categoriaId: categoriaSeleccionada!.id!,
      descripcion: descripcionController.text.trim(),
      monto: montoController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto registrado correctamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GastoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar gasto'),
      ),
      body: SafeArea(
        child: provider.isLoadingCategorias
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    DropdownButtonFormField<GastoCategoriaModel>(
                      value: categoriaSeleccionada,
                      items: provider.categorias
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          categoriaSeleccionada = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      validator: (_) {
                        if (categoriaSeleccionada == null) {
                          return 'Seleccione una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descripcionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese la descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: montoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el monto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isCreating ? null : guardar,
                        child: provider.isCreating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar gasto'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}