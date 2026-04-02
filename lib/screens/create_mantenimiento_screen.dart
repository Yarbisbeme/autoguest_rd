import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/mantenimiento_provider.dart';

class CreateMantenimientoScreen extends StatefulWidget {
  final int vehiculoId;

  const CreateMantenimientoScreen({
    super.key,
    required this.vehiculoId,
  });

  @override
  State<CreateMantenimientoScreen> createState() =>
      _CreateMantenimientoScreenState();
}

class _CreateMantenimientoScreenState
    extends State<CreateMantenimientoScreen> {
  final _formKey = GlobalKey<FormState>();

  final tipoController = TextEditingController();
  final descripcionController = TextEditingController();
  final costoController = TextEditingController();

  List<File> imagenesSeleccionadas = [];

  @override
  void dispose() {
    tipoController.dispose();
    descripcionController.dispose();
    costoController.dispose();
    super.dispose();
  }

  Future<void> seleccionarImagenes() async {
    final picker = ImagePicker();

    final List<XFile> pickedFiles = await picker.pickMultiImage(
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        imagenesSeleccionadas =
            pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> guardarMantenimiento() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<MantenimientoProvider>();

    final success = await provider.crearMantenimiento(
      vehiculoId: widget.vehiculoId,
      tipo: tipoController.text.trim(),
      descripcion: descripcionController.text.trim(),
      costo: costoController.text.trim(),
      fotos: imagenesSeleccionadas,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mantenimiento creado correctamente'),
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
    final provider = context.watch<MantenimientoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear mantenimiento'),
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
                controller: costoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Costo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el costo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: seleccionarImagenes,
                icon: const Icon(Icons.photo_library),
                label: const Text('Seleccionar fotos'),
              ),
              const SizedBox(height: 12),
              if (imagenesSeleccionadas.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imagenesSeleccionadas.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          imagenesSeleccionadas[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isCreating ? null : guardarMantenimiento,
                  child: provider.isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar mantenimiento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}