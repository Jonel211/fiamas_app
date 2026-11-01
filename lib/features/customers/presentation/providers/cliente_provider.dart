import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/models/cliente_model.dart';
import '../../../debts/domain/debt.dart';

class ClienteProvider extends ChangeNotifier {
  final Dio _dio = DioClient.create();

  List<ClienteModel> _clientes = [];
  List<ClienteModel> _recientes = [];
  List<Debt> _fiadosCliente = [];
  bool _isLoading = false;
  bool _isLoadingRecientes = false;
  bool _isCreating = false;
  bool _isLoadingFiados = false;
  String? _error;
  String? _errorFiados;

  // Última tienda pedida: evita que una respuesta tardía de otra tienda
  // reemplace la lista actual.
  String? _tiendaClientesId;

  // Nombre y teléfono del cliente cuyos fiados se están viendo.
  String _fiadosNombre = 'Cliente';
  String _fiadosTelefono = '';

  Map<String, dynamic>? _resumenCliente;
  bool _isLoadingResumen = false;
  String? _tiendaIdCargada;

  List<ClienteModel> get clientes => _clientes;
  List<ClienteModel> get recientes => _recientes;
  List<Debt> get fiadosCliente => _fiadosCliente;
  bool get isLoading => _isLoading;
  bool get isLoadingRecientes => _isLoadingRecientes;
  bool get isCreating => _isCreating;
  bool get isLoadingFiados => _isLoadingFiados;
  String? get error => _error;
  String? get errorFiados => _errorFiados;
  Map<String, dynamic>? get resumenCliente => _resumenCliente;
  bool get isLoadingResumen => _isLoadingResumen;
  String? get tiendaIdCargada => _tiendaIdCargada;

  void limpiarClientes() {
    _clientes = [];
    _recientes = [];
    _fiadosCliente = [];
    _resumenCliente = null;
    _tiendaIdCargada = null;
    _error = null;
    notifyListeners();
  }

  // ───────────── Utilidades ─────────────
  static double _toDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static String _mensajeError(DioException e, String porDefecto) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) return data['error'].toString();
    return porDefecto;
  }

  // ───────────── Clientes ─────────────
  Future<void> cargarClientes(String tiendaId) async {
    if (_tiendaIdCargada != tiendaId) {
      _clientes = [];
      _recientes = [];
    }
    _tiendaClientesId = tiendaId;
    _tiendaIdCargada = tiendaId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _dio.get('/clientes', queryParameters: {'tienda_id': tiendaId});

      // Si mientras tanto se pidió otra tienda, ignora esta respuesta
      if (_tiendaClientesId != tiendaId) return;

      if (response.data['clientes'] != null) {
        final List<dynamic> data = response.data['clientes'];
        _clientes = data.map((json) => ClienteModel.fromJson(json)).toList();
      } else {
        _clientes = [];
      }
    } on DioException catch (e) {
      if (_tiendaClientesId == tiendaId) {
        _error = _mensajeError(e, 'Error al cargar los clientes');
        _clientes = [];
      }
    } catch (e) {
      if (_tiendaClientesId == tiendaId) {
        _error = 'Error desconocido: $e';
        _clientes = [];
      }
    } finally {
      if (_tiendaClientesId == tiendaId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> cargarRecientes(String tiendaId, {int limit = 4}) async {
    _isLoadingRecientes = true;
    notifyListeners();

    try {
      final response = await _dio.get('/clientes/recientes',
          queryParameters: {'tienda_id': tiendaId, 'limit': limit});
      final List<dynamic> data = response.data['clientes'] ?? [];
      _recientes = data.map((json) => ClienteModel.fromJson(json)).toList();
    } catch (_) {
      _recientes = [];
    } finally {
      _isLoadingRecientes = false;
      notifyListeners();
    }
  }

  Future<bool> crearCliente({
    required String nombres,
    required String apellidos,
    required String telefono,
    required double limiteCredito,
    required String tiendaId,
    String? direccion,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      await _dio.post('/clientes', data: {
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': telefono,
        'limite_credito': limiteCredito,
        'tienda_id': tiendaId,
        'direccion': direccion,
      });

      await cargarClientes(tiendaId);
      await cargarRecientes(tiendaId);
      return true;
    } on DioException catch (e) {
      _error = _mensajeError(e, 'Error al crear el cliente');
      return false;
    } catch (e) {
      _error = 'Error desconocido: $e';
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> cargarResumenCliente(String clienteId, String tiendaId) async {
    _isLoadingResumen = true;
    _resumenCliente = null;
    notifyListeners();

    try {
      final response = await _dio.get('/clientes/$clienteId/resumen',
          queryParameters: {'tienda_id': tiendaId});
      _resumenCliente = response.data;
    } catch (e) {
      _resumenCliente = null;
    } finally {
      _isLoadingResumen = false;
      notifyListeners();
    }
  }

  // ───────────── Fiados del cliente ─────────────
  Future<void> cargarFiadosCliente(
    String clienteId,
    String tiendaId, {
    String? nombre,
    String? telefono,
  }) async {
    if (nombre != null && nombre.trim().isNotEmpty) _fiadosNombre = nombre;
    if (telefono != null) _fiadosTelefono = telefono;

    _isLoadingFiados = true;
    _errorFiados = null;
    _fiadosCliente = [];
    notifyListeners();

    try {
      final response = await _dio.get('/clientes/$clienteId/fiados',
          queryParameters: {'tienda_id': tiendaId});

      debugPrint(
          '>>> FIADOS cliente=$clienteId tienda=$tiendaId total=${response.data['total']}');

      final List<dynamic> data = response.data['fiados'] ?? [];

      _fiadosCliente = data.map<Debt>((json) {
        final estadoString = json['estado']?.toString() ?? 'pendiente';
        DebtStatus estadoEnum = DebtStatus.pendiente;
        if (estadoString == 'pagado') {
          estadoEnum = DebtStatus.pagado;
        } else if (estadoString == 'parcial') {
          estadoEnum = DebtStatus.parcial;
        }

        final fecha = json['fecha_creacion']?.toString();
        final fechaLabel = (fecha != null && fecha.length >= 10)
            ? 'Creado: ${fecha.substring(0, 10)}'
            : 'Sin fecha';

        final detalles = (json['detalles'] as List?) ?? [];

        return Debt(
          id: (json['id'] ?? '').toString(),
          customerName: _fiadosNombre,
          phone: _fiadosTelefono,
          amount: _toDouble(json['monto_total']),
          paidAmount: _toDouble(json['monto_pagado']),
          status: estadoEnum,
          dateLabel: fechaLabel,
          items: detalles.map<DebtItem>((d) {
            return DebtItem(
              productName: (d['producto']?['nombre'] ?? 'Producto').toString(),
              quantity: _toDouble(d['cantidad'], 1.0),
              unitPrice: _toDouble(d['precio_unitario']),
            );
          }).toList(),
        );
      }).toList();
    } on DioException catch (e) {
      debugPrint(
          'ERROR AL CARGAR FIADOS: status=${e.response?.statusCode} body=${e.response?.data}');
      _errorFiados = _mensajeError(e, 'No se pudieron cargar los fiados.');
      _fiadosCliente = [];
    } catch (e) {
      debugPrint('ERROR AL CARGAR FIADOS (parseo): $e');
      _errorFiados = 'Error al leer los fiados: $e';
      _fiadosCliente = [];
    } finally {
      _isLoadingFiados = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarLimiteCredito(
      String clienteId, String tiendaId, double nuevoLimite) async {
    try {
      await _dio.put('/clientes/$clienteId/tiendas/$tiendaId',
          data: {'limite_credito': nuevoLimite});
      await cargarClientes(tiendaId);
      if (_resumenCliente != null) {
        await cargarResumenCliente(clienteId, tiendaId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registrarPago({
    required String fiadoId,
    required double monto,
    required String metodoPago,
    String? referencia,
    required String tiendaId,
    required String clienteId,
  }) async {
    try {
      await _dio.post('/pagos', data: {
        'fiado_id': fiadoId,
        'monto': monto,
        'metodo_pago': metodoPago,
        'referencia': (referencia == null || referencia.trim().isEmpty)
            ? null
            : referencia,
      });

      await cargarFiadosCliente(clienteId, tiendaId);
      await cargarResumenCliente(clienteId, tiendaId);
      await cargarClientes(tiendaId);

      return true;
    } on DioException catch (e) {
      debugPrint(
          'ERROR AL REGISTRAR PAGO: status=${e.response?.statusCode} body=${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('ERROR AL REGISTRAR PAGO: $e');
      return false;
    }
  }

  List<ClienteModel> buscarClienteLocal(String query) {
    if (query.isEmpty) return _clientes;
    final queryLower = query.toLowerCase();
    return _clientes.where((cliente) {
      final nombreCompleto = cliente.nombreCompleto.toLowerCase();
      return nombreCompleto.contains(queryLower) ||
          cliente.telefono.contains(query);
    }).toList();
  }
}