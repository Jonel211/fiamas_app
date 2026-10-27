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

  Map<String, dynamic>? _resumenCliente;
  bool _isLoadingResumen = false;

  List<ClienteModel> get clientes => _clientes;
  List<ClienteModel> get recientes => _recientes;
  List<Debt> get fiadosCliente => _fiadosCliente; 
  bool get isLoading => _isLoading;
  bool get isLoadingRecientes => _isLoadingRecientes;
  bool get isCreating => _isCreating;
  bool get isLoadingFiados => _isLoadingFiados; 
  String? get error => _error;
  Map<String, dynamic>? get resumenCliente => _resumenCliente;
  bool get isLoadingResumen => _isLoadingResumen;

  Future<void> cargarClientes(String tiendaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/clientes', queryParameters: {'tienda_id': tiendaId});
      if (response.data['clientes'] != null) {
        final List<dynamic> data = response.data['clientes'];
        _clientes = data.map((json) => ClienteModel.fromJson(json)).toList();
      } else {
        _clientes = [];
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      _error = (data is Map ? data['error'] : null) ?? 'Error al cargar los clientes';
    } catch (e) {
      _error = 'Error desconocido: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarRecientes(String tiendaId, {int limit = 4}) async {
    _isLoadingRecientes = true;
    notifyListeners();

    try {
      final response = await _dio.get('/clientes/recientes', queryParameters: {'tienda_id': tiendaId, 'limit': limit});
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
      final data = e.response?.data;
      _error = (data is Map ? data['error'] : null) ?? 'Error al crear el cliente';
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
      final response = await _dio.get('/clientes/$clienteId/resumen', queryParameters: {'tienda_id': tiendaId});
      _resumenCliente = response.data;
    } catch (e) {
      _resumenCliente = null;
    } finally {
      _isLoadingResumen = false;
      notifyListeners();
    }
  }

  // ✅ Cargar fiados reales desde el backend
  Future<void> cargarFiadosCliente(String clienteId, String tiendaId) async {
    _isLoadingFiados = true;
    _fiadosCliente = [];
    notifyListeners();

    try {
      final response = await _dio.get('/clientes/$clienteId/fiados', queryParameters: {'tienda_id': tiendaId});
      final List<dynamic> data = response.data['fiados'] ?? [];
      
      _fiadosCliente = data.map((json) {
        // ✅ SOLUCIÓN: Extraemos los datos del cliente que vienen en el JSON
        final clienteData = json['cliente'];
        final nombreCompleto = clienteData != null 
            ? '${clienteData['nombres']} ${clienteData['apellidos']}'.trim()
            : 'Cliente';
        final telefono = clienteData != null ? clienteData['telefono'] ?? '' : '';

        return Debt(
          id: json['id'] ?? '',
          customerName: nombreCompleto, // ✅ Ya no está vacío
          phone: telefono, // ✅ Ya no está vacío
          amount: double.tryParse(json['monto_total']?.toString() ?? '') ?? 0.0,
          status: json['estado'] == 'pagado' ? DebtStatus.pagado : DebtStatus.pendiente,
          dateLabel: json['fecha_creacion'] != null 
              ? 'Creado: ${json['fecha_creacion'].toString().substring(0, 10)}' 
              : 'Sin fecha',
          items: (json['detalles'] as List? ?? []).map((d) {
            return DebtItem(
              productName: d['producto']?['nombre'] ?? 'Producto',
              quantity: double.tryParse(d['cantidad']?.toString() ?? '') ?? 1.0,
              unitPrice: double.tryParse(d['precio_unitario']?.toString() ?? '') ?? 0.0,
            );
          }).toList(),
        );
      }).toList();

    } catch (e) {
      debugPrint('🔥 ERROR AL CARGAR FIADOS: $e'); 
      _fiadosCliente = [];
    } finally {
      _isLoadingFiados = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarLimiteCredito(String clienteId, String tiendaId, double nuevoLimite) async {
    try {
      await _dio.put('/clientes/$clienteId/tiendas/$tiendaId', data: {'limite_credito': nuevoLimite});
      await cargarClientes(tiendaId);
      if (_resumenCliente != null) {
        await cargarResumenCliente(clienteId, tiendaId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  List<ClienteModel> buscarClienteLocal(String query) {
    if (query.isEmpty) return _clientes;
    final queryLower = query.toLowerCase();
    return _clientes.where((cliente) {
      final nombreCompleto = cliente.nombreCompleto.toLowerCase();
      return nombreCompleto.contains(queryLower) || cliente.telefono.contains(query);
    }).toList();
  }
}