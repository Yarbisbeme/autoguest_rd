import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/noticia_provider.dart';

class NoticiaDetalleScreen extends StatefulWidget {
  final int noticiaId;

  const NoticiaDetalleScreen({
    super.key,
    required this.noticiaId,
  });

  @override
  State<NoticiaDetalleScreen> createState() => _NoticiaDetalleScreenState();
}

class _NoticiaDetalleScreenState extends State<NoticiaDetalleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NoticiaProvider>().cargarDetalle(widget.noticiaId);
    });
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  String _resolverUrlImagen(String imagen) {
    final img = imagen.trim();

    if (img.isEmpty) return '';

    if (img.startsWith('http://') || img.startsWith('https://')) {
      return img;
    }

    if (img.startsWith('/')) {
      return 'https://taller-itla.ia3x.com$img';
    }

    return img;
  }

  String _limpiarHtmlBasico(String html) {
    if (html.trim().isEmpty) return '';

    var texto = html;

    texto = texto.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    texto = texto.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    texto = texto.replaceAll(RegExp(r'<[^>]*>'), '');
    texto = texto.replaceAll('&nbsp;', ' ');
    texto = texto.replaceAll('&amp;', '&');
    texto = texto.replaceAll('&quot;', '"');
    texto = texto.replaceAll('&#039;', "'");
    texto = texto.replaceAll('&lt;', '<');
    texto = texto.replaceAll('&gt;', '>');

    return texto.trim();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticiaProvider>();
    final noticia = provider.noticiaDetalle;

    final imagenUrl = noticia == null ? '' : _resolverUrlImagen(noticia.imagen);

    if (noticia != null) {
      print('IMAGEN RAW NOTICIA: ${noticia.imagen}');
      print('IMAGEN URL RESUELTA: $imagenUrl');
      print('RAW NOTICIA DETALLE: ${jsonEncode(noticia.raw)}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de noticia'),
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
              : noticia == null
                  ? const Center(
                      child: Text('No se pudo cargar la noticia'),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<NoticiaProvider>().cargarDetalle(
                                widget.noticiaId,
                              ),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (imagenUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.network(
                                imagenUrl,
                                height: 240,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, error, __) {
                                  print('ERROR CARGANDO IMAGEN: $error');
                                  return Container(
                                    height: 240,
                                    color: AppColors.surface,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 54,
                                          color: AppColors.textSecondary,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'No se pudo cargar la imagen',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (imagenUrl.isNotEmpty)
                            const SizedBox(height: 18),
                          Text(
                            _safeText(noticia.titulo),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _safeText(noticia.fecha),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Text(
                                _limpiarHtmlBasico(
                                  noticia.contenido.isNotEmpty
                                      ? noticia.contenido
                                      : noticia.resumen,
                                ),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}