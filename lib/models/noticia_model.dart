class NoticiaModel {
  final int? id;
  final String titulo;
  final String resumen;
  final String contenido;
  final String fecha;
  final String imagen;
  final Map<String, dynamic> raw;

  NoticiaModel({
    this.id,
    required this.titulo,
    required this.resumen,
    required this.contenido,
    required this.fecha,
    required this.imagen,
    required this.raw,
  });

  static String _extraerImagenDesdeContenido(String contenido) {
    if (contenido.trim().isEmpty) return '';

    final dataOrigFileRegex = RegExp(r'data-orig-file="([^"]+)"');
    final srcRegex = RegExp(r'<img[^>]+src="([^"]+)"');

    final matchDataOrigFile = dataOrigFileRegex.firstMatch(contenido);
    if (matchDataOrigFile != null && matchDataOrigFile.groupCount >= 1) {
      return matchDataOrigFile.group(1)?.replaceAll('&amp;', '&') ?? '';
    }

    final matchSrc = srcRegex.firstMatch(contenido);
    if (matchSrc != null && matchSrc.groupCount >= 1) {
      return matchSrc.group(1)?.replaceAll('&amp;', '&') ?? '';
    }

    return '';
  }

  factory NoticiaModel.fromJson(Map<String, dynamic> json) {
    final contenido = json['contenido']?.toString() ??
        json['detalle']?.toString() ??
        '';

    final imagenDirecta = json['imagen']?.toString() ??
        json['foto']?.toString() ??
        json['url_imagen']?.toString() ??
        '';

    final imagenFinal = imagenDirecta.trim().isNotEmpty
        ? imagenDirecta
        : _extraerImagenDesdeContenido(contenido);

    return NoticiaModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      titulo: json['titulo']?.toString() ?? '',
      resumen: json['resumen']?.toString() ??
          json['descripcion']?.toString() ??
          '',
      contenido: contenido,
      fecha: json['fecha']?.toString() ?? '',
      imagen: imagenFinal,
      raw: json,
    );
  }
}