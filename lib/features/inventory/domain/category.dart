class Category {
  final String id;
  final String tiendaId;
  final String nombre;
  final String? descripcion;
  final String? icono; 
  final String? color; 
  final bool activo;

  Category({
    required this.id,
    required this.tiendaId,
    required this.nombre,
    this.descripcion,
    this.icono,
    this.color,
    this.activo = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      tiendaId: json['tienda_id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      icono: json['icono'], 
      color: json['color'], 
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tienda_id': tiendaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono, 
      'color': color, 
      'activo': activo,
    };
  }
}
