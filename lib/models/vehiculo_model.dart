class VehiculoModel {
  final int? id;
  final String placa;
  final String chasis;
  final String marca;
  final String modelo;
  final int? anio;
  final int? cantidadRuedas;
  final String foto;
  final Map<String, dynamic> raw;

  VehiculoModel({
    this.id,
    required this.placa,
    required this.chasis,
    required this.marca,
    required this.modelo,
    this.anio,
    this.cantidadRuedas,
    required this.foto,
    required this.raw,
  });

  factory VehiculoModel.fromJson(Map<String, dynamic> json) {
    return VehiculoModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      placa: json['placa']?.toString() ?? '',
      chasis: json['chasis']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      anio: json['anio'] is int ? json['anio'] : int.tryParse('${json['anio']}'),
      cantidadRuedas: json['cantidadRuedas'] is int
          ? json['cantidadRuedas']
          : int.tryParse('${json['cantidadRuedas']}'),
      foto: json['foto']?.toString() ?? '',
      raw: json,
    );
  }
}