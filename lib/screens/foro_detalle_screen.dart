import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/foro_provider.dart';

class ForoDetalleScreen extends StatefulWidget {
  final int temaId;

  const ForoDetalleScreen({
    super.key,
    required this.temaId,
  });

  @override
  State<ForoDetalleScreen> createState() => _ForoDetalleScreenState();
}

class _ForoDetalleScreenState extends State<ForoDetalleScreen> {
  final respuestaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ForoProvider>().cargarDetalle(id: widget.temaId);
    });
  }

  @override
  void dispose() {
    respuestaController.dispose();
    super.dispose();
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  Future<void> _publicarRespuesta() async {
    final contenido = respuestaController.text.trim();

    if (contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese una respuesta')),
      );
      return;
    }

    final provider = context.read<ForoProvider>();

    final ok = await provider.responderTema(
      temaId: widget.temaId,
      contenido: contenido,
    );

    if (!mounted) return;

    if (ok) {
      respuestaController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respuesta publicada')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForoProvider>();
    final detalle = provider.temaDetalle;

    final respuestas = detalle != null && detalle['respuestas'] is List
        ? List<dynamic>.from(detalle['respuestas'])
        : <dynamic>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del tema'),
      ),
      body: provider.isLoading && detalle == null
          ? const Center(child: CircularProgressIndicator())
          : detalle == null
              ? Center(
                  child: Text(
                    provider.errorMessage.isNotEmpty
                        ? provider.errorMessage
                        : 'No se pudo cargar el tema',
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>
                            context.read<ForoProvider>().cargarDetalle(
                                  id: widget.temaId,
                                ),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _safeText(detalle['titulo']),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _safeText(detalle['descripcion']),
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _chip('Vehículo: ${_safeText(detalle['vehiculo'])}'),
                                        _chip('Fecha: ${_safeText(detalle['fecha'])}'),
                                        _chip('Respuestas: ${_safeText(detalle['totalRespuestas'])}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Respuestas',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (respuestas.isEmpty)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'No hay respuestas todavía',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ...respuestas.map((r) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  child: ListTile(
                                    title: Text(
                                      _safeText(r['contenido']),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        '${_safeText(r['autor'])} · ${_safeText(r['fecha'])}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        border: Border(
                          top: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: respuestaController,
                              minLines: 1,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Escribe una respuesta...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IconButton(
                              onPressed: provider.isSubmitting
                                  ? null
                                  : _publicarRespuesta,
                              icon: provider.isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Icon(Icons.send, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}