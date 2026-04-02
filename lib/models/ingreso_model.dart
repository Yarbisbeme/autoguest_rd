class IngresoModel {
  final int? id;
  final int? vehiculoId;
  final String concepto;
  final String monto;
  final String fecha;
  final Map<String, dynamic> raw;

  IngresoModel({
    this.id,
    this.vehiculoId,
    required this.concepto,
    required this.monto,
    required this.fecha,
    required this.raw,
  });

  factory IngresoModel.fromJson(Map<String, dynamic> json) {
    return IngresoModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      vehiculoId: json['vehiculo_id'] is int
          ? json['vehiculo_id']
          : int.tryParse('${json['vehiculo_id']}'),
      concepto: json['concepto']?.toString() ??
          json['descripcion']?.toString() ??
          '',
      monto: json['monto']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      raw: json,
    );
  }
}