import 'tienda_model.dart';

class TenderoModel {
  final String id;
  final String dni;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String? fotoUrl;
  final List<TiendaModel> tiendas;
  final bool isPremium;

  TenderoModel({
    required this.id,
    required this.dni,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    this.fotoUrl,
    required this.tiendas,
    this.isPremium = false,
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
      fotoUrl: _firstNonEmpty(json, const [
        'foto_perfil_url',
        'foto_perfil',
        'foto_url',
        'foto',
        'avatar_url',
        'imagen_url',
        'profile_image',
        'profileImage',
        'photo_url',
      ]),
      tiendas: tiendasList,
      isPremium: json['es_premium'] == true,
    );
  }

  static String? _firstNonEmpty(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
