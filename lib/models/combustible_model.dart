class CombustibleModel {
  final int? id;
  final int? vehiculoId;
  final String tipo;
  final String cantidad;
  final String unidad;
  final String monto;
  final String fecha;
  final Map<String, dynamic> raw;

  CombustibleModel({
    this.id,
    this.vehiculoId,
    required this.tipo,
    required this.cantidad,
    required this.unidad,
    required this.monto,
    required this.fecha,
    required this.raw,
  });

  factory CombustibleModel.fromJson(Map<String, dynamic> json) {
    return CombustibleModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      vehiculoId: json['vehiculo_id'] is int
          ? json['vehiculo_id']
          : int.tryParse('${json['vehiculo_id']}'),
      tipo: json['tipo']?.toString() ?? '',
      cantidad: json['cantidad']?.toString() ?? '',
      unidad: json['unidad']?.toString() ?? '',
      monto: json['monto']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      raw: json,
    );
  }
}