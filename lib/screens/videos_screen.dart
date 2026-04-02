import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../providers/video_provider.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VideoProvider>().cargarVideos();
    });
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  String _resolverThumbnail(dynamic imagen, dynamic url) {
    final img = (imagen ?? '').toString().trim();
    final videoUrl = (url ?? '').toString().trim();

    if (img.isNotEmpty) return img;

    final youtubeId = _extraerYoutubeId(videoUrl);
    if (youtubeId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
    }

    return '';
  }

  String _extraerYoutubeId(String url) {
    if (url.isEmpty) return '';

    final regExpList = [
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})'),
    ];

    for (final exp in regExpList) {
      final match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1) ?? '';
      }
    }

    return '';
  }

  Future<void> _abrirVideo(String url) async {
    final texto = url.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este video no tiene enlace disponible')),
      );
      return;
    }

    final uri = texto.startsWith('http://') || texto.startsWith('https://')
        ? Uri.parse(texto)
        : Uri.parse('https://$texto');

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el video')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage.isNotEmpty && provider.videos.isEmpty
                ? Center(child: Text(provider.errorMessage))
                : provider.videos.isEmpty
                    ? const Center(child: Text('No hay videos disponibles'))
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<VideoProvider>().cargarVideos(),
                        child: ListView.separated(
                          itemCount: provider.videos.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) {
                            final video = provider.videos[i];
                            final thumbnail =
                                _resolverThumbnail(video.imagen, video.url);

                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => _abrirVideo(video.url),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (thumbnail.isNotEmpty)
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.network(
                                            thumbnail,
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
                                                  size: 50,
                                                  color: AppColors.textSecondary,
                                                ),
                                              );
                                            },
                                          ),
                                          Container(
                                            width: 62,
                                            height: 62,
                                            decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius:
                                                  BorderRadius.circular(31),
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 38,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Container(
                                        height: 120,
                                        width: double.infinity,
                                        color: AppColors.surface,
                                        child: const Center(
                                          child: Icon(
                                            Icons.ondemand_video,
                                            size: 50,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _safeText(video.titulo),
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _safeText(video.descripcion),
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
                                                Icons.play_circle_outline,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Tocar para reproducir',
                                                style: TextStyle(
                                                  color: Colors.grey.shade400,
                                                ),
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