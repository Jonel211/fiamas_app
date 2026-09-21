class TiendaModel {
  final String id;
  final String nombre;
  final String? direccion;
  final String? logoUrl;
  final bool activo;

  TiendaModel({
    required this.id,
    required this.nombre,
    this.direccion,
    this.logoUrl,
    required this.activo,
  });

  factory TiendaModel.fromJson(Map<String, dynamic> json) {
    return TiendaModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      direccion: json['direccion'],
      logoUrl: json['logo_url'],
      activo: json['activo'] ?? true,
    );
  }
}
