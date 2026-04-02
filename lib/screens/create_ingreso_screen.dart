import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ingreso_provider.dart';

class CreateIngresoScreen extends StatefulWidget {
  final int vehiculoId;

  const CreateIngresoScreen({
    super.key,
    required this.vehiculoId,
  });

  @override
  State<CreateIngresoScreen> createState() => _CreateIngresoScreenState();
}

class _CreateIngresoScreenState extends State<CreateIngresoScreen> {
  final _formKey = GlobalKey<FormState>();

  final conceptoController = TextEditingController();
  final montoController = TextEditingController();

  @override
  void dispose() {
    conceptoController.dispose();
    montoController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<IngresoProvider>();

    final ok = await provider.crearIngreso(
      vehiculoId: widget.vehiculoId,
      concepto: conceptoController.text.trim(),
      monto: montoController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IngresoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ingreso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: conceptoController,
                decoration: const InputDecoration(
                  labelText: 'Concepto',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese el concepto' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese el monto' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: provider.isCreating ? null : guardar,
                child: provider.isCreating
                    ? const CircularProgressIndicator()
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}