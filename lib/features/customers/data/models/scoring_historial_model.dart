class ScoringHistorialModel {
  final String id;
  final int? scoreAnterior;
  final int scoreNuevo;
  final int? cambioScore;
  final String? categoriaAnterior;
  final String categoriaNueva;
  final String motivo;
  final DateTime fechaCalculo;

  ScoringHistorialModel({
    required this.id,
    this.scoreAnterior,
    required this.scoreNuevo,
    this.cambioScore,
    this.categoriaAnterior,
    required this.categoriaNueva,
    required this.motivo,
    required this.fechaCalculo,
  });

  factory ScoringHistorialModel.fromJson(Map<String, dynamic> json) {
    return ScoringHistorialModel(
      id: json['id'] ?? '',
      scoreAnterior: int.tryParse(json['score_anterior']?.toString() ?? ''),
      scoreNuevo: int.tryParse(json['score_nuevo']?.toString() ?? '') ?? 100,
      cambioScore: int.tryParse(json['cambio_score']?.toString() ?? ''),
      categoriaAnterior: json['categoria_anterior'],
      categoriaNueva: json['categoria_nueva'] ?? 'nuevo',
      motivo: json['motivo'] ?? 'Evaluación de crédito',
      // AQUÍ ESTÁ LA MAGIA: .toLocal() convierte de UTC a la hora del celular
      fechaCalculo: json['fecha_calculo'] != null
          ? DateTime.parse(json['fecha_calculo'].toString()).toLocal()
          : DateTime.now(),
    );
  }
}