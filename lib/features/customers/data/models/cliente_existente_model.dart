class ClienteExistenteModel {
  final bool existe;
  final bool yaVinculado;
  final bool activo;
  final String? clienteId;
  final String nombres;
  final String apellidos;
  final String? fotoPerfilUrl;

  const ClienteExistenteModel({
    required this.existe,
    required this.yaVinculado,
    required this.activo,
    this.clienteId,
    this.nombres = '',
    this.apellidos = '',
    this.fotoPerfilUrl,
  });

  factory ClienteExistenteModel.fromJson(Map<String, dynamic> json) {
    final cliente = json['cliente'];
    final data = cliente is Map
        ? Map<String, dynamic>.from(cliente)
        : const <String, dynamic>{};

    return ClienteExistenteModel(
      existe: json['existe'] == true,
      yaVinculado: json['ya_vinculado'] == true,
      activo: json['activo'] != false,
      clienteId: data['id']?.toString(),
      nombres: (data['nombres'] ?? '').toString(),
      apellidos: (data['apellidos'] ?? '').toString(),
      fotoPerfilUrl: data['foto_perfil_url']?.toString(),
    );
  }

  String get nombreCompleto => '$nombres $apellidos'.trim();
}
