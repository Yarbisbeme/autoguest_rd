import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/vehiculo_model.dart';
import '../providers/vehiculo_provider.dart';

class EditVehicleScreen extends StatefulWidget {
  final VehiculoModel vehiculo;

  const EditVehicleScreen({
    super.key,
    required this.vehiculo,
  });

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController placaController;
  late final TextEditingController chasisController;
  late final TextEditingController marcaController;
  late final TextEditingController modeloController;
  late final TextEditingController anioController;
  late final TextEditingController cantidadRuedasController;

  File? nuevaImagen;

  @override
  void initState() {
    super.initState();

    print('ID VEHICULO EN EDIT SCREEN: ${widget.vehiculo.id}');
    print('RAW VEHICULO EN EDIT SCREEN: ${widget.vehiculo.raw}');

    placaController = TextEditingController(text: widget.vehiculo.placa);
    chasisController = TextEditingController(text: widget.vehiculo.chasis);
    marcaController = TextEditingController(text: widget.vehiculo.marca);
    modeloController = TextEditingController(text: widget.vehiculo.modelo);
    anioController = TextEditingController(
      text: widget.vehiculo.anio?.toString() ?? '',
    );
    cantidadRuedasController = TextEditingController(
      text: widget.vehiculo.cantidadRuedas?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    placaController.dispose();
    chasisController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    anioController.dispose();
    cantidadRuedasController.dispose();
    super.dispose();
  }

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        nuevaImagen = File(pickedFile.path);
      });
    }
  }

  Future<void> guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.vehiculo.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este vehículo no tiene ID válido para editar'),
        ),
      );
      return;
    }

    final provider = context.read<VehiculoProvider>();

    final ok = await provider.editarVehiculo(
      id: widget.vehiculo.id!,
      placa: placaController.text.trim(),
      chasis: chasisController.text.trim(),
      marca: marcaController.text.trim(),
      modelo: modeloController.text.trim(),
      anio: anioController.text.trim(),
      cantidadRuedas: cantidadRuedasController.text.trim(),
    );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
      return;
    }

    if (nuevaImagen != null) {
      final okFoto = await provider.cambiarFotoVehiculo(
        vehiculoId: widget.vehiculo.id!,
        foto: nuevaImagen!,
      );

      if (!mounted) return;

      if (!okFoto) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage)),
        );
        return;
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehículo actualizado correctamente')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiculoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar vehículo'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ID del vehículo: ${widget.vehiculo.id ?? 'No disponible'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: seleccionarImagen,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: nuevaImagen != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            nuevaImagen!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40),
                            SizedBox(height: 8),
                            Text('Seleccionar nueva foto'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: placaController,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la placa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: chasisController,
                decoration: const InputDecoration(
                  labelText: 'Chasis',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el chasis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la marca';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el modelo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: anioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el año';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cantidadRuedasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de ruedas',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la cantidad de ruedas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isUpdating ? null : guardarCambios,
                  child: provider.isUpdating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}