import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/combustible_provider.dart';

class CreateCombustibleScreen extends StatefulWidget {
  final int vehiculoId;

  const CreateCombustibleScreen({
    super.key,
    required this.vehiculoId,
  });

  @override
  State<CreateCombustibleScreen> createState() =>
      _CreateCombustibleScreenState();
}

class _CreateCombustibleScreenState extends State<CreateCombustibleScreen> {
  final _formKey = GlobalKey<FormState>();

  final tipoController = TextEditingController();
  final cantidadController = TextEditingController();
  final unidadController = TextEditingController(text: 'galones');
  final montoController = TextEditingController();

  @override
  void dispose() {
    tipoController.dispose();
    cantidadController.dispose();
    unidadController.dispose();
    montoController.dispose();
    super.dispose();
  }

  Future<void> guardarCombustible() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CombustibleProvider>();

    final success = await provider.crearCombustible(
      vehiculoId: widget.vehiculoId,
      tipo: tipoController.text.trim(),
      cantidad: cantidadController.text.trim(),
      unidad: unidadController.text.trim(),
      monto: montoController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro de combustible creado correctamente'),
        ),
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
    final provider = context.watch<CombustibleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar combustible'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el tipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la cantidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: unidadController,
                decoration: const InputDecoration(
                  labelText: 'Unidad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la unidad';
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
                  onPressed: provider.isCreating ? null : guardarCombustible,
                  child: provider.isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar combustible'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}