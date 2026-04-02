class CatalogoModel {
  final int? id;
  final String marca;
  final String modelo;
  final String anio;
  final String precio;
  final String descripcion;
  final String imagen;
  final Map<String, dynamic> raw;

  CatalogoModel({
    this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.precio,
    required this.descripcion,
    required this.imagen,
    required this.raw,
  });

  factory CatalogoModel.fromJson(Map<String, dynamic> json) {
    return CatalogoModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      anio: json['anio']?.toString() ?? '',
      precio: json['precio']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ??
          json['resumen']?.toString() ??
          '',
      imagen: json['imagen']?.toString() ??
          json['foto']?.toString() ??
          json['url_imagen']?.toString() ??
          '',
      raw: json,
    );
  }
}