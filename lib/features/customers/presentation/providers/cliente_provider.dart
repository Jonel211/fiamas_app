import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/offline/database/database_helper.dart';
import '../../../../core/offline/models/sync_operation.dart';
import '../../../../core/offline/services/connectivity_service.dart';
import '../../../../core/offline/services/sync_service.dart';
import '../../../debts/domain/debt.dart';
import '../../data/models/cliente_model.dart';

class ClienteProvider extends ChangeNotifier {
  final Dio _dio = DioClient.create();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ConnectivityService _connectivity = ConnectivityService();

  List<ClienteModel> _clientes = [];
  List<ClienteModel> _clientesConDeuda = [];
  List<ClienteModel> _recientes = [];
  List<Debt> _fiadosCliente = [];
  bool _isLoading = false;
  bool _isLoadingConDeuda = false;
  bool _isLoadingRecientes = false;
  bool _isCreating = false;
  bool _isLoadingFiados = false;
  String? _error;
  String? _errorConDeuda;
  String? _errorFiados;

  String? _tiendaClientesId;
  String? _tiendaConDeudaId;

  // Nombre y teléfono del cliente cuyos fiados se están viendo.
  String _fiadosNombre = 'Cliente';
  String _fiadosTelefono = '';

  Map<String, dynamic>? _resumenCliente;
  bool _isLoadingResumen = false;
  String? _tiendaIdCargada;

  List<ClienteModel> get clientes => _clientes;
  List<ClienteModel> get clientesConDeuda => _clientesConDeuda;
  List<ClienteModel> get recientes => _recientes;
  List<Debt> get fiadosCliente => _fiadosCliente;
  bool get isLoading => _isLoading;
  bool get isLoadingConDeuda => _isLoadingConDeuda;
  bool get isLoadingRecientes => _isLoadingRecientes;
  bool get isCreating => _isCreating;
  bool get isLoadingFiados => _isLoadingFiados;
  String? get error => _error;
  String? get errorConDeuda => _errorConDeuda;
  String? get errorFiados => _errorFiados;
  Map<String, dynamic>? get resumenCliente => _resumenCliente;
  bool get isLoadingResumen => _isLoadingResumen;
  String? get tiendaIdCargada => _tiendaIdCargada;
  String? get tiendaConDeudaId => _tiendaConDeudaId;

  void limpiarClientes() {
    _clientes = [];
    _clientesConDeuda = [];
    _recientes = [];
    _fiadosCliente = [];
    _resumenCliente = null;
    _tiendaIdCargada = null;
    _tiendaConDeudaId = null;
    _error = null;
    _errorConDeuda = null;
    notifyListeners();
  }

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

  Future<void> cargarClientes(String tiendaId) async {
    if (_tiendaIdCargada != tiendaId) {
      _clientes = [];
      _recientes = [];
    }
    _tiendaClientesId = tiendaId;
    _tiendaIdCargada = tiendaId;
    _isLoading = true;
    _error = null;

    Future.microtask(() {
      if (_tiendaClientesId == tiendaId) notifyListeners();
    });

    try {
      final isConnected = await _connectivity.isConnected();
      if (isConnected) {
        final response = await _dio.get(
          '/clientes',
          queryParameters: {'tienda_id': tiendaId},
        );
        if (_tiendaClientesId != tiendaId) return;

        if (response.data['clientes'] != null) {
          final List<dynamic> data = response.data['clientes'];
          _clientes = data.map((json) => ClienteModel.fromJson(json)).toList();

          await _dbHelper.saveClientes(
            tiendaId,
            _clientes
                .map((c) => {
                      'id': c.id,
                      'tienda_id': tiendaId,
                      'telefono': c.telefono,
                      'nombres': c.nombres,
                      'apellidos': c.apellidos,
                      'direccion': c.direccion ?? '',
                      'foto_perfil_url': c.fotoPerfilUrl ?? '',
                      'creado_en': c.creadoEn?.toIso8601String() ??
                          DateTime.now().toIso8601String(),
                      'limite_credito': c.vinculacion.limiteCredito,
                      'saldo_actual': c.vinculacion.saldoActual,
                    })
                .toList(),
          );
        } else {
          _clientes = [];
        }
      } else {
        await _cargarDesdeCache(tiendaId);
      }
    } on DioException catch (e) {
      if (_tiendaClientesId == tiendaId) {
        await _cargarDesdeCache(tiendaId);
        if (_clientes.isEmpty) {
          _error = _mensajeError(e, 'Error de conexión.');
        }
      }
    } catch (e) {
      if (_tiendaClientesId == tiendaId) {
        await _cargarDesdeCache(tiendaId);
        if (_clientes.isEmpty) {
          _error = 'Error: $e';
        }
      }
    } finally {
      if (_tiendaClientesId == tiendaId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _cargarDesdeCache(String tiendaId) async {
    try {
      final cached = await _dbHelper.getClientes(tiendaId);
      _clientes = cached
          .map(
            (c) => ClienteModel(
              id: c['id'],
              telefono: c['telefono'],
              nombres: c['nombres'],
              apellidos: c['apellidos'],
              direccion: c['direccion'],
              fotoPerfilUrl: c['foto_perfil_url'],
              creadoEn: DateTime.tryParse(c['creado_en']),
              vinculacion: VinculacionModel(
                id: c['id'],
                limiteCredito: c['limite_credito'] ?? 500.0,
                saldoActual: c['saldo_actual'] ?? 0.0,
                scorePagador: 100,
                categoriaPagador: 'nuevo',
                totalFiados: 0,
                totalPagos: 0,
                cantidadFiadosMora: 0,
              ),
            ),
          )
          .toList();
    } catch (_) {
      _clientes = [];
    }
  }

  Future<void> cargarClientesConDeuda(String tiendaId) async {
    if (_tiendaConDeudaId != tiendaId) {
      _clientesConDeuda = [];
    }
    _tiendaConDeudaId = tiendaId;
    _isLoadingConDeuda = true;
    _errorConDeuda = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        '/clientes',
        queryParameters: {
          'tienda_id': tiendaId,
          'con_deuda': true,
          'orden': 'saldo_desc',
        },
      );

      if (_tiendaConDeudaId != tiendaId) return;

      final List<dynamic> data = response.data['clientes'] ?? [];
      _clientesConDeuda =
          data.map((json) => ClienteModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (_tiendaConDeudaId == tiendaId) {
        _errorConDeuda = _mensajeError(
          e,
          'Error al cargar los clientes con deuda',
        );
        _clientesConDeuda = [];
      }
    } catch (e) {
      if (_tiendaConDeudaId == tiendaId) {
        _errorConDeuda = 'Error desconocido: $e';
        _clientesConDeuda = [];
      }
    } finally {
      if (_tiendaConDeudaId == tiendaId) {
        _isLoadingConDeuda = false;
        notifyListeners();
      }
    }
  }

  Future<void> cargarRecientes(String tiendaId, {int limit = 4}) async {
    _isLoadingRecientes = true;
    Future.microtask(() => notifyListeners());
    try {
      final response = await _dio.get(
        '/clientes/recientes',
        queryParameters: {'tienda_id': tiendaId, 'limit': limit},
      );
      _recientes = (response.data['clientes'] ?? [])
          .map<ClienteModel>((json) => ClienteModel.fromJson(json))
          .toList();
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
      final isConnected = await _connectivity.isConnected();

      if (isConnected) {
        try {
          await _dio.post(
            '/clientes',
            data: {
              'nombres': nombres,
              'apellidos': apellidos,
              'telefono': telefono,
              'limite_credito': limiteCredito,
              'tienda_id': tiendaId,
              'direccion': direccion,
            },
          );
          await cargarClientes(tiendaId);
          await cargarRecientes(tiendaId);
          _isCreating = false;
          notifyListeners();
          return true;
        } catch (_) {
          // Si falla la red, caemos a offline
          return await _crearClienteOffline(
            nombres,
            apellidos,
            telefono,
            limiteCredito,
            tiendaId,
            direccion,
          );
        }
      } else {
        return await _crearClienteOffline(
          nombres,
          apellidos,
          telefono,
          limiteCredito,
          tiendaId,
          direccion,
        );
      }
    } catch (e) {
      _error = 'Error: $e';
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _crearClienteOffline(
    String nombres,
    String apellidos,
    String telefono,
    double limiteCredito,
    String tiendaId,
    String? direccion,
  ) async {
    try {
      final tempId = 'temp_cli_${DateTime.now().millisecondsSinceEpoch}';

      final nuevoCliente = ClienteModel(
        id: tempId,
        telefono: telefono,
        nombres: nombres,
        apellidos: apellidos,
        direccion: direccion,
        fotoPerfilUrl: null,
        creadoEn: DateTime.now(),
        vinculacion: VinculacionModel(
          id: tempId,
          limiteCredito: limiteCredito,
          saldoActual: 0.0,
          scorePagador: 100,
          categoriaPagador: 'nuevo',
          totalFiados: 0,
          totalPagos: 0,
          cantidadFiadosMora: 0,
        ),
      );

      _clientes.add(nuevoCliente);

      try {
        await _dbHelper.saveClientes(
          tiendaId,
          _clientes
              .map((c) => {
                    'id': c.id,
                    'tienda_id': tiendaId,
                    'telefono': c.telefono,
                    'nombres': c.nombres,
                    'apellidos': c.apellidos,
                    'direccion': c.direccion ?? '',
                    'foto_perfil_url': c.fotoPerfilUrl ?? '',
                    'creado_en': c.creadoEn?.toIso8601String() ??
                        DateTime.now().toIso8601String(),
                    'limite_credito': c.vinculacion.limiteCredito,
                    'saldo_actual': c.vinculacion.saldoActual,
                  })
              .toList(),
        );
      } catch (_) {}

      try {
        await SyncService().addToQueue(
          SyncOperation(
            type: 'create_client',
            entity: 'cliente',
            entityId: tempId,
            payload: {
              'nombres': nombres,
              'apellidos': apellidos,
              'telefono': telefono,
              'limite_credito': limiteCredito,
              'tienda_id': tiendaId,
              'direccion': direccion,
            },
          ),
        );
      } catch (_) {}

      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear cliente local: $e';
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarResumenCliente(String clienteId, String tiendaId) async {
    _isLoadingResumen = true;
    _resumenCliente = null;
    notifyListeners();
    try {
      final response = await _dio.get(
        '/clientes/$clienteId/resumen',
        queryParameters: {'tienda_id': tiendaId},
      );
      _resumenCliente = response.data;
    } catch (_) {
      _resumenCliente = null;
    } finally {
      _isLoadingResumen = false;
      notifyListeners();
    }
  }

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
    Future.microtask(() => notifyListeners());

    try {
      // Primero intentamos cargar desde cache (offline-first)
      await _cargarFiadosDesdeCache(clienteId);

      final isConnected = await _connectivity.isConnected();
      if (isConnected) {
        try {
          final response = await _dio.get(
            '/clientes/$clienteId/fiados',
            queryParameters: {'tienda_id': tiendaId},
          );
          final data = response.data['fiados'] ?? [];

          if (data.isNotEmpty) {
            _parseAndSetFiados(data);
          }
        } catch (_) {
          // Si falla la red, nos quedamos con lo que había en cache
        }
      }
    } catch (e) {
      _errorFiados = 'Error al cargar los fiados: $e';
    } finally {
      _isLoadingFiados = false;
      notifyListeners();
    }
  }

  Future<void> _cargarFiadosDesdeCache(String clienteId) async {
    try {
      final cached = await _dbHelper.getFiados();
      final misFiados =
          cached.where((f) => f['cliente_id'] == clienteId).toList();

      if (misFiados.isNotEmpty) {
        _fiadosCliente = misFiados.map<Debt>((json) {
          final estadoString = json['estado']?.toString() ?? 'pendiente';
          final DebtStatus estadoEnum = estadoString == 'pagado'
              ? DebtStatus.pagado
              : (estadoString == 'parcial'
                  ? DebtStatus.parcial
                  : DebtStatus.pendiente);
          final fecha =
              json['fecha_fiado']?.toString() ?? json['creado_en']?.toString();
          final fechaLabel = (fecha != null && fecha.length >= 10)
              ? 'Creado: ${fecha.substring(0, 10)}'
              : 'Sin fecha';

          return Debt(
            id: (json['id'] ?? '').toString(),
            customerName: _fiadosNombre,
            phone: _fiadosTelefono,
            amount: _toDouble(json['monto_total']),
            paidAmount: _toDouble(json['monto_pagado']),
            status: estadoEnum,
            dateLabel: fechaLabel,
            items: const [],
          );
        }).toList();
      } else {
        _fiadosCliente = [];
      }
    } catch (_) {
      _fiadosCliente = [];
    }
  }

  void _parseAndSetFiados(List<dynamic> data) {
    _fiadosCliente = data.map<Debt>((json) {
      final estadoString = json['estado']?.toString() ?? 'pendiente';
      final DebtStatus estadoEnum = estadoString == 'pagado'
          ? DebtStatus.pagado
          : (estadoString == 'parcial'
              ? DebtStatus.parcial
              : DebtStatus.pendiente);
      final fecha =
          json['fecha_creacion']?.toString() ?? json['fecha_fiado']?.toString();
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
        items: detalles
            .map<DebtItem>(
              (d) => DebtItem(
                productName:
                    (d['producto']?['nombre'] ?? 'Producto').toString(),
                quantity: _toDouble(d['cantidad'], 1.0),
                unitPrice: _toDouble(d['precio_unitario']),
              ),
            )
            .toList(),
      );
    }).toList();
  }

  Future<bool> actualizarLimiteCredito(
    String clienteId,
    String tiendaId,
    double nuevoLimite,
  ) async {
    try {
      await _dio.put(
        '/clientes/$clienteId/tiendas/$tiendaId',
        data: {'limite_credito': nuevoLimite},
      );
      await cargarClientes(tiendaId);
      if (_resumenCliente != null) {
        await cargarResumenCliente(clienteId, tiendaId);
      }
      return true;
    } catch (_) {
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
      await _dio.post(
        '/pagos',
        data: {
          'fiado_id': fiadoId,
          'monto': monto,
          'metodo_pago': metodoPago,
          'referencia':
              (referencia == null || referencia.trim().isEmpty) ? null : referencia,
        },
      );
      await cargarFiadosCliente(clienteId, tiendaId);
      await cargarResumenCliente(clienteId, tiendaId);
      await cargarClientes(tiendaId);
      return true;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  List<ClienteModel> buscarClienteLocal(String query) {
    if (query.isEmpty) return _clientes;
    final queryLower = query.toLowerCase();
    return _clientes
        .where(
          (cliente) =>
              cliente.nombreCompleto.toLowerCase().contains(queryLower) ||
              cliente.telefono.contains(query),
        )
        .toList();
  }
}