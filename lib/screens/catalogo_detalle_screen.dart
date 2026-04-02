import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catalogo_provider.dart';

class CatalogoDetalleScreen extends StatefulWidget {
  final int itemId;

  const CatalogoDetalleScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<CatalogoDetalleScreen> createState() => _CatalogoDetalleScreenState();
}

class _CatalogoDetalleScreenState extends State<CatalogoDetalleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CatalogoProvider>().cargarDetalle(widget.itemId);
    });
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogoProvider>();
    final item = provider.detalle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle catálogo'),
      ),
      body: provider.isDetailLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      provider.errorMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : item == null
                  ? const Center(
                      child: Text('No se pudo cargar el detalle'),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (item.imagen.trim().isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.imagen,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 220,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                        if (item.imagen.trim().isNotEmpty)
                          const SizedBox(height: 16),
                        Text(
                          '${_safeText(item.marca)} ${_safeText(item.modelo)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Año: ${_safeText(item.anio)}'),
                        const SizedBox(height: 6),
                        Text('Precio: ${_safeText(item.precio)}'),
                        const SizedBox(height: 16),
                        Text(
                          _safeText(item.descripcion),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
    );
  }
}