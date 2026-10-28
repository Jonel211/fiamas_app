import 'tienda_model.dart';

class TenderoModel {
  final String id;
  final String dni;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String? fotoUrl;
  final List<TiendaModel> tiendas;

  TenderoModel({
    required this.id,
    required this.dni,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    this.fotoUrl,
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
      fotoUrl: json['foto_perfil_url'],
      tiendas: tiendasList,
    );
  }
}