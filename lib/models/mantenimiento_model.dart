class MantenimientoModel {
  final int? id;
  final int? vehiculoId;
  final String tipo;
  final String descripcion;
  final String costo;
  final String fecha;
  final List<String> fotos;
  final Map<String, dynamic> raw;

  MantenimientoModel({
    this.id,
    this.vehiculoId,
    required this.tipo,
    required this.descripcion,
    required this.costo,
    required this.fecha,
    required this.fotos,
    required this.raw,
  });

  factory MantenimientoModel.fromJson(Map<String, dynamic> json) {
    final fotosJson = json['fotos'];

    List<String> fotos = [];

    if (fotosJson is List) {
      fotos = fotosJson.map((e) => e.toString()).toList();
    }

    return MantenimientoModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      vehiculoId: json['vehiculo_id'] is int
          ? json['vehiculo_id']
          : int.tryParse('${json['vehiculo_id']}'),
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      costo: json['costo']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      fotos: fotos,
      raw: json,
    );
  }
}