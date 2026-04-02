import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/vehiculo_provider.dart';

class CreateVehicleScreen extends StatefulWidget {
  const CreateVehicleScreen({super.key});

  @override
  State<CreateVehicleScreen> createState() => _CreateVehicleScreenState();
}

class _CreateVehicleScreenState extends State<CreateVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final placaController = TextEditingController();
  final chasisController = TextEditingController();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final anioController = TextEditingController();
  final cantidadRuedasController = TextEditingController();

  File? imagenSeleccionada;

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
        imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<void> guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VehiculoProvider>();

    final success = await provider.crearVehiculo(
      placa: placaController.text.trim(),
      chasis: chasisController.text.trim(),
      marca: marcaController.text.trim(),
      modelo: modeloController.text.trim(),
      anio: anioController.text.trim(),
      cantidadRuedas: cantidadRuedasController.text.trim(),
      foto: imagenSeleccionada,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo creado correctamente')),
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
    final provider = context.watch<VehiculoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear vehículo'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: seleccionarImagen,
                child: Container(
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: imagenSeleccionada != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(
                            imagenSeleccionada!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 42),
                            SizedBox(height: 10),
                            Text('Seleccionar foto del vehículo'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: placaController,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la placa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: chasisController,
                decoration: const InputDecoration(
                  labelText: 'Chasis',
                  prefixIcon: Icon(Icons.qr_code),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el chasis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la marca';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  prefixIcon: Icon(Icons.directions_car_filled_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el modelo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: anioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el año';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: cantidadRuedasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de ruedas',
                  prefixIcon: Icon(Icons.tire_repair),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la cantidad de ruedas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: provider.isCreating ? null : guardarVehiculo,
                child: provider.isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Guardar vehículo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}