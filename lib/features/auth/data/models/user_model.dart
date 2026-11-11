class UserModel {
  final String id;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String? dni;
  final String rol; // 'tendero' | 'cliente' | 'admin'
  final String? tiendaId;
  final bool esPremium; //  CAMPO AGREGADO PARA LA FASE 2
  final String? fotoPerfilUrl;

  UserModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    this.dni,
    required this.rol,
    this.tiendaId,
    this.esPremium = false, // Valor por defecto
    this.fotoPerfilUrl,
  });

  // Getter para mantener compatibilidad con código antiguo que use 'nombre'
  String get nombre => '$nombres $apellidos'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      nombres:
          json['nombres'] as String? ?? json['nombre'] as String? ?? 'Usuario',
      apellidos: json['apellidos'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      dni: json['dni'] as String?,
      rol: json['rol'] as String? ?? 'tendero',
      tiendaId: json['tienda_id'] as String? ?? json['tiendaId'] as String?,
      //  Maneja tanto 'es_premium' (backend) como 'esPremium'
      esPremium: json['es_premium'] ?? json['esPremium'] ?? false,
      fotoPerfilUrl: json['foto_perfil_url'] ?? json['fotoPerfilUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'dni': dni,
      'rol': rol,
      'tienda_id': tiendaId,
      'es_premium': esPremium,
      'foto_perfil_url': fotoPerfilUrl,
    };
  }

  bool get isTendero => rol == 'tendero';
  bool get isCliente => rol == 'cliente';
  bool get isAdmin => rol == 'admin';
}
