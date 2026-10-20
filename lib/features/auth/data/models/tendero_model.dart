class TiendaModel {
  final String id;
  final String nombre;
  final String? direccion;
  final String? ruc;
  final String? telefono;

  TiendaModel({
    required this.id,
    required this.nombre,
    this.direccion,
    this.ruc,
    this.telefono,
  });

  factory TiendaModel.fromJson(Map<String, dynamic> json) {
    return TiendaModel(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'],
      ruc: json['ruc'],
      telefono: json['telefono'],
    );
  }
}

class TenderoModel {
  final String id;
  final String dni;
  final String nombres;
  final String apellidos;
  final String telefono;
  final List<TiendaModel> tiendas;

  TenderoModel({
    required this.id,
    required this.dni,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.tiendas,
  });

  String get fullName => '$nombres $apellidos'.trim();

  factory TenderoModel.fromJson(Map<String, dynamic> json) {
    List<TiendaModel> tiendasList = [];
    if (json['tiendas'] != null) {
      tiendasList = (json['tiendas'] as List)
          .map((t) => TiendaModel.fromJson(t))
          .toList();
    }

    return TenderoModel(
      id: json['id'].toString(),
      dni: json['dni'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      telefono: json['telefono'] ?? '',
      tiendas: tiendasList,
    );
  }
}
