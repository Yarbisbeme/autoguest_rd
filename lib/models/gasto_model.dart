class GastoModel {
  final int? id;
  final int? vehiculoId;
  final int? categoriaId;
  final String categoriaNombre;
  final String descripcion;
  final String monto;
  final String fecha;
  final Map<String, dynamic> raw;

  GastoModel({
    this.id,
    this.vehiculoId,
    this.categoriaId,
    required this.categoriaNombre,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.raw,
  });

  factory GastoModel.fromJson(Map<String, dynamic> json) {
    return GastoModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      vehiculoId: json['vehiculo_id'] is int
          ? json['vehiculo_id']
          : int.tryParse('${json['vehiculo_id']}'),
      categoriaId: json['categoria_id'] is int
          ? json['categoria_id']
          : int.tryParse('${json['categoria_id']}'),
      categoriaNombre: json['categoria_nombre']?.toString() ??
          json['categoria']?.toString() ??
          '',
      descripcion: json['descripcion']?.toString() ??
          json['concepto']?.toString() ??
          '',
      monto: json['monto']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      raw: json,
    );
  }
}