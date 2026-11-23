import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/offline/database/database_helper.dart';
import '../../../../core/offline/models/sync_operation.dart';
import '../../../../core/offline/services/connectivity_service.dart';
import '../../../../core/offline/services/sync_service.dart';
import '../../../debts/domain/debt.dart';
import '../../data/models/cliente_existente_model.dart';
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
  bool _isVerifying = false;
  bool _isLinking = false;
  bool _isLoadingFiados = false;
  bool _isLoadingResumen = false;

  String? _error;
  String? _errorConDeuda;
  String? _errorFiados;
  String? _errorVerificacion;
  String? _errorVinculacion;

  String? _tiendaClientesId;
  String? _tiendaConDeudaId;
  String? _tiendaIdCargada;

  String _fiadosNombre = 'Cliente';
  String _fiadosTelefono = '';

  Map<String, dynamic>? _resumenCliente;

  List<ClienteModel> get clientes => _clientes;
  List<ClienteModel> get clientesConDeuda => _clientesConDeuda;
  List<ClienteModel> get recientes => _recientes;
  List<Debt> get fiadosCliente => _fiadosCliente;

  List<Debt> get fiadosParaTotales =>
      _fiadosCliente.where((d) => !d.isCancelled).toList();

  double get totalFiadoCliente =>
      fiadosParaTotales.fold(0.0, (sum, d) => sum + d.amount);

  double get totalPagadoCliente =>
      fiadosParaTotales.fold(0.0, (sum, d) => sum + d.paidAmount);

  double get saldoPendienteCliente => totalFiadoCliente - totalPagadoCliente;

  bool get isLoading => _isLoading;
  bool get isLoadingConDeuda => _isLoadingConDeuda;
  bool get isLoadingRecientes => _isLoadingRecientes;
  bool get isCreating => _isCreating;
  bool get isVerifying => _isVerifying;
  bool get isLinking => _isLinking;
  bool get isLoadingFiados => _isLoadingFiados;
  bool get isLoadingResumen => _isLoadingResumen;

  String? get error => _error;
  String? get errorConDeuda => _errorConDeuda;
  String? get errorFiados => _errorFiados;
  String? get errorVerificacion => _errorVerificacion;
  String? get errorVinculacion => _errorVinculacion;

  Map<String, dynamic>? get resumenCliente => _resumenCliente;
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
    _errorVerificacion = null;
    _errorVinculacion = null;

    notifyListeners();
  }

  static double _toDouble(dynamic value, [double fallback = 0.0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? fallback;
  }

  static String _mensajeError(DioException e, String porDefecto) {
    final data = e.response?.data;

    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }

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
      if (_tiendaClientesId == tiendaId) {
        notifyListeners();
      }
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
                .map(
                  (c) => {
                    'id': c.id,
                    'tienda_id': tiendaId,
                    'telefono': c.telefono,
                    'nombres': c.nombres,
                    'apellidos': c.apellidos,
                    'direccion': c.direccion ?? '',
                    'foto_perfil_url': c.fotoPerfilUrl ?? '',
                    'creado_en':
                        c.creadoEn?.toIso8601String() ??
                        DateTime.now().toIso8601String(),
                    'limite_credito': c.vinculacion.limiteCredito,
                    'saldo_actual': c.vinculacion.saldoActual,
                  },
                )
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

      _clientesConDeuda = data
          .map((json) => ClienteModel.fromJson(json))
          .toList();
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

  Future<ClienteExistenteModel?> verificarTelefono(
    String telefono,
    String tiendaId,
  ) async {
    _isVerifying = true;
    _errorVerificacion = null;

    notifyListeners();

    try {
      final response = await _dio.get(
        '/clientes/verificar-telefono',
        queryParameters: {'telefono': telefono, 'tienda_id': tiendaId},
      );

      final data = response.data;

      if (data is Map) {
        return ClienteExistenteModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      _errorVerificacion = 'No se pudo verificar el teléfono.';
      return null;
    } on DioException catch (e) {
      _errorVerificacion = e.response == null
          ? 'Sin conexión. Reintenta.'
          : _mensajeError(e, 'No se pudo verificar el teléfono.');
      return null;
    } catch (_) {
      _errorVerificacion = 'No se pudo verificar el teléfono.';
      return null;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  Future<bool> vincularCliente({
    required String clienteId,
    required String tiendaId,
    required double limiteCredito,
  }) async {
    if (_isLinking) return false;

    _isLinking = true;
    _errorVinculacion = null;

    notifyListeners();

    try {
      await _dio.post(
        '/clientes/$clienteId/vincular',
        data: {'tienda_id': tiendaId, 'limite_credito': limiteCredito},
      );

      await cargarClientes(tiendaId);
      await cargarRecientes(tiendaId);

      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code']?.toString() : null;

      switch (e.response?.statusCode) {
        case 409:
          _errorVinculacion = code == 'YA_VINCULADO'
              ? 'Ya es cliente de tu tienda.'
              : _mensajeError(e, 'El cliente ya está vinculado.');
          break;
        case 403:
          _errorVinculacion = 'Este cliente no está disponible.';
          break;
        case 400:
          _errorVinculacion = _mensajeError(
            e,
            'El límite de crédito no es válido.',
          );
          break;
        case 404:
          _errorVinculacion = _mensajeError(
            e,
            'No se encontró el cliente o la tienda.',
          );
          break;
        default:
          _errorVinculacion = e.response == null
              ? 'Sin conexión. Reintenta.'
              : _mensajeError(e, 'No se pudo vincular al cliente.');
      }

      return false;
    } catch (_) {
      _errorVinculacion = 'No se pudo vincular al cliente.';
      return false;
    } finally {
      _isLinking = false;
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
          final response = await _dio.post(
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

          if (response.statusCode == 200 || response.statusCode == 201) {
            await cargarClientes(tiendaId);
            await cargarRecientes(tiendaId);

            _isCreating = false;
            notifyListeners();

            return true;
          }

          _error = 'No se pudo registrar el cliente.';
          _isCreating = false;
          notifyListeners();

          return false;
        } on DioException catch (e) {
          // Solo se crea offline cuando no hubo respuesta del servidor.
          if (e.response != null) {
            _error = _mensajeError(e, 'No se pudo registrar el cliente.');
            _isCreating = false;
            notifyListeners();

            return false;
          }

          return await _crearClienteOffline(
            nombres,
            apellidos,
            telefono,
            limiteCredito,
            tiendaId,
            direccion,
          );
        }
      }

      return await _crearClienteOffline(
        nombres,
        apellidos,
        telefono,
        limiteCredito,
        tiendaId,
        direccion,
      );
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
              .map(
                (c) => {
                  'id': c.id,
                  'tienda_id': tiendaId,
                  'telefono': c.telefono,
                  'nombres': c.nombres,
                  'apellidos': c.apellidos,
                  'direccion': c.direccion ?? '',
                  'foto_perfil_url': c.fotoPerfilUrl ?? '',
                  'creado_en':
                      c.creadoEn?.toIso8601String() ??
                      DateTime.now().toIso8601String(),
                  'limite_credito': c.vinculacion.limiteCredito,
                  'saldo_actual': c.vinculacion.saldoActual,
                },
              )
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
    if (nombre != null && nombre.trim().isNotEmpty) {
      _fiadosNombre = nombre;
    }

    if (telefono != null) {
      _fiadosTelefono = telefono;
    }

    _isLoadingFiados = true;
    _errorFiados = null;

    Future.microtask(() => notifyListeners());

    try {
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
        } catch (_) {}
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

      final misFiados = cached
          .where((f) => f['cliente_id'] == clienteId)
          .toList();

      if (misFiados.isNotEmpty) {
        _fiadosCliente = misFiados.map<Debt>((json) {
          final estadoString = json['estado']?.toString() ?? 'pendiente';

          final DebtStatus estadoEnum = estadoString == 'pagado'
              ? DebtStatus.pagado
              : estadoString == 'parcial'
              ? DebtStatus.parcial
              : DebtStatus.pendiente;

          final fecha =
              json['fecha_fiado']?.toString() ?? json['creado_en']?.toString();

          final fechaLabel = fecha != null && fecha.length >= 10
              ? 'Creado: ${fecha.substring(0, 10)}'
              : 'Sin fecha';

          String? fechaPago;

          final pagos = json['pagos'] as List?;

          if (pagos != null && pagos.isNotEmpty) {
            fechaPago = pagos.last['fecha_pago']?.toString();
          }

          return Debt(
            id: (json['id'] ?? '').toString(),
            customerName: _fiadosNombre,
            phone: _fiadosTelefono,
            amount: _toDouble(json['monto_total']),
            paidAmount: _toDouble(json['monto_pagado']),
            status: estadoEnum,
            dateLabel: fechaLabel,
            dueDate: json['fecha_vencimiento']?.toString(),
            paidDate: estadoString == 'pagado' ? fechaPago : null,
            items: const [],
            isCancelled: estadoString == 'cancelado',
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
          : estadoString == 'parcial'
          ? DebtStatus.parcial
          : DebtStatus.pendiente;

      final fecha =
          json['fecha_creacion']?.toString() ?? json['fecha_fiado']?.toString();

      final fechaLabel = fecha != null && fecha.length >= 10
          ? 'Creado: ${fecha.substring(0, 10)}'
          : 'Sin fecha';

      final detalles = (json['detalles'] as List?) ?? [];

      String? fechaPago;

      final pagos = json['pagos'] as List?;

      if (pagos != null && pagos.isNotEmpty) {
        fechaPago = pagos.last['fecha_pago']?.toString();
      }

      return Debt(
        id: (json['id'] ?? '').toString(),
        customerName: _fiadosNombre,
        phone: _fiadosTelefono,
        amount: _toDouble(json['monto_total']),
        paidAmount: _toDouble(json['monto_pagado']),
        status: estadoEnum,
        dateLabel: fechaLabel,
        dueDate: json['fecha_vencimiento']?.toString(),
        paidDate: estadoString == 'pagado' ? fechaPago : null,
        items: detalles
            .map<DebtItem>(
              (d) => DebtItem(
                productName: (d['producto']?['nombre'] ?? 'Producto')
                    .toString(),
                quantity: _toDouble(d['cantidad'], 1.0),
                unitPrice: _toDouble(d['precio_unitario']),
                unit: (d['producto']?['unidad_medida'] ?? d['unidad_medida'])
                    ?.toString(),
              ),
            )
            .toList(),
        isCancelled: estadoString == 'cancelado',
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
          'referencia': referencia == null || referencia.trim().isEmpty
              ? null
              : referencia,
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
