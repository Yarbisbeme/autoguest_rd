import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goma_model.dart';
import '../providers/goma_provider.dart';

class GomasScreen extends StatefulWidget {
  final int vehiculoId;
  final String vehiculoTitulo;

  const GomasScreen({
    super.key,
    required this.vehiculoId,
    required this.vehiculoTitulo,
  });

  @override
  State<GomasScreen> createState() => _GomasScreenState();
}

class _GomasScreenState extends State<GomasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GomaProvider>().cargarGomas(widget.vehiculoId);
    });
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  Future<void> _mostrarDialogoActualizarEstado(GomaModel goma) async {
    if (goma.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta goma no tiene ID en la respuesta de la API, por eso no se puede actualizar.',
          ),
        ),
      );
      return;
    }

    String estadoSeleccionado =
        goma.estado.isNotEmpty ? goma.estado : 'Buena';

    final estados = [
      'Nueva',
      'Buena',
      'Regular',
      'Desgastada',
      'Pinchada',
      'Cambiada',
    ];

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Actualizar estado'),
              content: DropdownButtonFormField<String>(
                value: estados.contains(estadoSeleccionado)
                    ? estadoSeleccionado
                    : estados.first,
                items: estados
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setStateDialog(() {
                      estadoSeleccionado = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true) return;
    if (!mounted) return;

    final provider = context.read<GomaProvider>();

    final ok = await provider.actualizarEstadoGoma(
      vehiculoId: widget.vehiculoId,
      gomaId: goma.id!,
      estado: estadoSeleccionado,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Estado actualizado correctamente' : provider.errorMessage,
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoPinchazo(GomaModel goma) async {
    if (goma.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta goma no tiene ID en la respuesta de la API, por eso no se puede registrar pinchazo.',
          ),
        ),
      );
      return;
    }

    final descripcionController = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar pinchazo'),
          content: TextField(
            controller: descripcionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) return;

    final descripcion = descripcionController.text.trim();

    if (descripcion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe ingresar una descripción'),
        ),
      );
      return;
    }

    if (!mounted) return;

    final provider = context.read<GomaProvider>();

    final ok = await provider.registrarPinchazo(
      vehiculoId: widget.vehiculoId,
      gomaId: goma.id!,
      descripcion: descripcion,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Pinchazo registrado correctamente' : provider.errorMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GomaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gomas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.tire_repair),
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

                  if (provider.errorMessage.isNotEmpty &&
                      provider.gomas.isEmpty) {
                    return Center(
                      child: Text(
                        provider.errorMessage,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (provider.gomas.isEmpty) {
                    return const Center(
                      child: Text('No hay gomas registradas'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<GomaProvider>().cargarGomas(widget.vehiculoId),
                    child: ListView.separated(
                      itemCount: provider.gomas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final goma = provider.gomas[i];

                        print('RAW GOMA: ${goma.raw}');
                        print('ID GOMA: ${goma.id}');

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                              Text(
                                _safeText(goma.posicion),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Estado: ${_safeText(goma.estado)}'),
                              Text('Eje: ${_safeText(goma.eje)}'),
                              Text('Total pinchazos: ${_safeText(goma.totalPinchazos)}'),
                              if (goma.descripcion.isNotEmpty)
                                Text('Descripción: ${_safeText(goma.descripcion)}'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: provider.isUpdating
                                        ? null
                                        : () => _mostrarDialogoActualizarEstado(goma),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Actualizar estado'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: provider.isUpdating
                                        ? null
                                        : () => _mostrarDialogoPinchazo(goma),
                                    icon: const Icon(Icons.warning_amber),
                                    label: const Text('Registrar pinchazo'),
                                  ),
                                ],
                              ),
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