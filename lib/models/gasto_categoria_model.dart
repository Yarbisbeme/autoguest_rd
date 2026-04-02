class GastoCategoriaModel {
  final int? id;
  final String nombre;
  final Map<String, dynamic> raw;

  GastoCategoriaModel({
    this.id,
    required this.nombre,
    required this.raw,
  });

  factory GastoCategoriaModel.fromJson(Map<String, dynamic> json) {
    return GastoCategoriaModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      nombre: json['nombre']?.toString() ??
          json['descripcion']?.toString() ??
          json['categoria']?.toString() ??
          '',
      raw: json,
    );
  }

  @override
  String toString() => nombre;
}