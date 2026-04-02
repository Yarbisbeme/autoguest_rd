class PerfilModel {
  final int? id;
  final String nombre;
  final String matricula;
  final String correo;
  final String fotoUrl;
  final Map<String, dynamic> raw;

  PerfilModel({
    this.id,
    required this.nombre,
    required this.matricula,
    required this.correo,
    required this.fotoUrl,
    required this.raw,
  });

  factory PerfilModel.fromJson(Map<String, dynamic> json) {
    return PerfilModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      nombre: json['nombre']?.toString() ?? '',
      matricula: json['matricula']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      fotoUrl: json['fotoUrl']?.toString() ??
          json['foto']?.toString() ??
          json['imagen']?.toString() ??
          '',
      raw: json,
    );
  }
}