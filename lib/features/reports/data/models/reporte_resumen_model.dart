class ChartDataModel {
  final String dia;
  final double monto;

  ChartDataModel({required this.dia, required this.monto});

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      dia: json['dia']?.toString() ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

List<Map<String, dynamic>> _listaDeMapas(dynamic v) {
  if (v is! List) return [];
  return v
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

class ReporteResumenModel {
  final String? version; // null = el servidor tiene la versión vieja
  final int totalFiados;
  final double montoTotalFiado;
  final double porCobrar;
  final int clientesPendientes;
  final int totalCobros;
  final double montoTotalCobrado;
  final int totalClientes;
  final int totalProductos;
  final List<Map<String, dynamic>> topProductos;
  final List<ChartDataModel> chartData;
  final List<Map<String, dynamic>> listaFiados;
  final List<Map<String, dynamic>> listaCobros;

  ReporteResumenModel({
    required this.version,
    required this.totalFiados,
    required this.montoTotalFiado,
    required this.porCobrar,
    required this.clientesPendientes,
    required this.totalCobros,
    required this.montoTotalCobrado,
    required this.totalClientes,
    required this.totalProductos,
    required this.topProductos,
    required this.chartData,
    required this.listaFiados,
    required this.listaCobros,
  });

  factory ReporteResumenModel.fromJson(Map<String, dynamic> json) {
    return ReporteResumenModel(
      version: json['version']?.toString(),
      totalFiados: (json['totalFiados'] as num?)?.toInt() ?? 0,
      montoTotalFiado: (json['montoTotalFiado'] as num?)?.toDouble() ?? 0.0,
      porCobrar: (json['porCobrar'] as num?)?.toDouble() ?? 0.0,
      clientesPendientes: (json['clientesPendientes'] as num?)?.toInt() ?? 0,
      totalCobros: (json['totalCobros'] as num?)?.toInt() ?? 0,
      montoTotalCobrado: (json['montoTotalCobrado'] as num?)?.toDouble() ?? 0.0,
      totalClientes: (json['totalClientes'] as num?)?.toInt() ?? 0,
      totalProductos: (json['totalProductos'] as num?)?.toInt() ?? 0,
      topProductos: _listaDeMapas(json['topProductos']),
      chartData: _listaDeMapas(json['chartData'])
          .map((e) => ChartDataModel.fromJson(e))
          .toList(),
      listaFiados: _listaDeMapas(json['listaFiados']),
      listaCobros: _listaDeMapas(json['listaCobros']),
    );
  }
}