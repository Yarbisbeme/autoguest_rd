import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/noticia_provider.dart';
import '../services/noticia_service.dart';
import 'noticia_detalle_screen.dart';

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  final NoticiaService _noticiaService = NoticiaService();
  final Map<int, String> _imagenesPreview = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<NoticiaProvider>().cargarNoticias();
      _cargarPreviewsFaltantes();
    });
  }

  Future<void> _cargarPreviewsFaltantes() async {
    final noticias = context.read<NoticiaProvider>().noticias;

    for (final noticia in noticias) {
      if (noticia.id == null) continue;

      final id = noticia.id!;

      if (_imagenesPreview.containsKey(id)) continue;
      if (noticia.imagen.trim().isNotEmpty) {
        _imagenesPreview[id] = noticia.imagen;
        continue;
      }

      try {
        final imagen = await _noticiaService.obtenerImagenPreview(id);
        if (!mounted) return;

        setState(() {
          _imagenesPreview[id] = imagen;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _imagenesPreview[id] = '';
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticiaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage.isNotEmpty && provider.noticias.isEmpty
                ? Center(child: Text(provider.errorMessage))
                : provider.noticias.isEmpty
                    ? const Center(child: Text('No hay noticias disponibles'))
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context.read<NoticiaProvider>().cargarNoticias();
                          await _cargarPreviewsFaltantes();
                        },
                        child: ListView.separated(
                          itemCount: provider.noticias.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) {
                            final noticia = provider.noticias[i];
                            final previewRaw = noticia.id != null
                                ? (_imagenesPreview[noticia.id!] ?? noticia.imagen)
                                : noticia.imagen;

                            final imagenUrl = _resolverUrlImagen(previewRaw);

                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: noticia.id == null
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => NoticiaDetalleScreen(
                                              noticiaId: noticia.id!,
                                            ),
                                          ),
                                        );
                                      },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imagenUrl.isNotEmpty)
                                      Image.network(
                                        imagenUrl,
                                        height: 190,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) {
                                          return Container(
                                            height: 190,
                                            width: double.infinity,
                                            color: AppColors.surface,
                                            child: const Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: AppColors.textSecondary,
                                            ),
                                          );
                                        },
                                      )
                                    else
                                      Container(
                                        height: 120,
                                        width: double.infinity,
                                        color: AppColors.surface,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _safeText(noticia.titulo),
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _safeText(
                                              noticia.resumen.isNotEmpty
                                                  ? noticia.resumen
                                                  : noticia.contenido,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.schedule,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  _safeText(noticia.fecha),
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}