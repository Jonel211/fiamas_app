class Category {
  final String id;
  final String tiendaId;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final String? color;
  final bool activo;

  Category({
    required this.id, required this.tiendaId, required this.nombre,
    this.descripcion, this.icono, this.color, this.activo = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '', tiendaId: json['tienda_id'] ?? '', nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'], icono: json['icono'], color: json['color'], activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'tienda_id': tiendaId, 'nombre': nombre, 'descripcion': descripcion,
      'icono': icono, 'color': color, 'activo': activo,
    };
  }

  //  PARA SQLITE
  Map<String, dynamic> toMap() {
    return {
      'id': id, 'tienda_id': tiendaId, 'nombre': nombre, 'descripcion': descripcion ?? '',
      'icono': icono ?? '', 'color': color ?? '', 'activo': activo ? 1 : 0,
    };
  }

  //  DESDE SQLITE
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'], tiendaId: map['tienda_id'], nombre: map['nombre'],
      descripcion: map['descripcion'], icono: map['icono'], color: map['color'],
      activo: (map['activo'] as int) == 1,
    );
  }
}