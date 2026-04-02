class GomaModel {
  final int? id;
  final int? vehiculoId;
  final String posicion;
  final String estado;
  final int? eje;
  final int? totalPinchazos;
  final String descripcion;
  final Map<String, dynamic> raw;

  GomaModel({
    this.id,
    this.vehiculoId,
    required this.posicion,
    required this.estado,
    this.eje,
    this.totalPinchazos,
    required this.descripcion,
    required this.raw,
  });

  factory GomaModel.fromJson(Map<String, dynamic> json) {
    return GomaModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      vehiculoId: json['vehiculo_id'] is int
          ? json['vehiculo_id']
          : int.tryParse('${json['vehiculo_id']}'),
      posicion: json['posicion']?.toString() ?? 'Sin posición',
      estado: json['estado']?.toString() ?? 'Sin estado',
      eje: json['eje'] is int ? json['eje'] : int.tryParse('${json['eje']}'),
      totalPinchazos: json['totalPinchazos'] is int
          ? json['totalPinchazos']
          : int.tryParse('${json['totalPinchazos']}'),
      descripcion: json['descripcion']?.toString() ?? '',
      raw: json,
    );
  }
}