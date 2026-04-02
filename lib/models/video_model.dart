class VideoModel {
  final int? id;
  final String titulo;
  final String descripcion;
  final String url;
  final String fecha;
  final String imagen;
  final Map<String, dynamic> raw;

  VideoModel({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.url,
    required this.fecha,
    required this.imagen,
    required this.raw,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ??
          json['resumen']?.toString() ??
          '',
      url: json['url']?.toString() ??
          json['video']?.toString() ??
          json['enlace']?.toString() ??
          '',
      fecha: json['fecha']?.toString() ?? '',
      imagen: json['imagen']?.toString() ??
          json['foto']?.toString() ??
          json['thumbnail']?.toString() ??
          '',
      raw: json,
    );
  }
}