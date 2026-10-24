class UserModel {
  final String id;
  final String nombre;
  final String rol; // 'tendero' | 'cliente'
  final String? tiendaId;
  

  UserModel({
    required this.id,
    required this.nombre,
    required this.rol,
    this.tiendaId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
      tiendaId: json['tienda_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'rol': rol, 'tienda_id': tiendaId};
  }

  bool get isTendero => rol == 'tendero';
  bool get isCliente => rol == 'cliente';
}
