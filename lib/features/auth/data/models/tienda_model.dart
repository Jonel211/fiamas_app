class TiendaModel {
  final String id;
  final String nombre;
  final String? direccion;
  final String? ruc;
  final String? telefono;
  final bool activo;
  final String? qrToken; // <-- NUEVO CAMPO

  TiendaModel({
    required this.id,
    required this.nombre,
    this.direccion,
    this.ruc,
    this.telefono,
    required this.activo,
    this.qrToken, // <-- NUEVO CAMPO
  });

  factory TiendaModel.fromJson(Map<String, dynamic> json) {
    return TiendaModel(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'],
      ruc: json['ruc'],
      telefono: json['telefono'],
      activo: json['activo'] ?? true,
      qrToken: json['qr_token'], // <-- SE EXTRAE DEL JSON
    );
  }
}