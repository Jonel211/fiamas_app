import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../../customers/presentation/widgets/edit_credit_limit_bottom_sheet.dart'; // IMPORTANTE: Para editar el limite
import '../widgets/fiado_product_item.dart';

class FinalizarFiadoScreen extends StatefulWidget {
  const FinalizarFiadoScreen({super.key});

  @override
  State<FinalizarFiadoScreen> createState() => _FinalizarFiadoScreenState();
}

class _FinalizarFiadoScreenState extends State<FinalizarFiadoScreen> {
  final _dateController = TextEditingController();
  bool _isSaving = false;
  late ClienteModel _cliente;
  late List<Map<String, dynamic>> _cartItems;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Map<String, dynamic>) {
        _cliente = args['cliente'] as ClienteModel;
        _cartItems = args['cartItems'] as List<Map<String, dynamic>>;
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // NUEVO: Funcion para cancelar el fiado con confirmacion
  Future<void> _cancelarFiado() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Fiado'),
        content: const Text('¿Estás seguro de que deseas cancelar este fiado? Los productos agregados se perderán.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver', style: TextStyle(color: AppColors.inkMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      // Regresamos al inicio
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.summary, (route) => false);
    }
  }

  Future<void> _registrarFiado() async {
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una fecha de pago')));
      return;
    }

    setState(() => _isSaving = true);

    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    final dio = DioClient.create();

    final parts = _dateController.text.split('/');
    final fechaFormateada = "${parts[2]}-${parts[1]}-${parts[0]}";

    final productosJson = _cartItems.map((item) => {
      'producto_id': item['producto_id'],
      'cantidad': item['qty'],
    }).toList();

    try {
      await dio.post('/fiados', data: {
        'cliente_id': _cliente.id,
        'tienda_id': tiendaId,
        'fecha_vencimiento': fechaFormateada,
        'productos': productosJson,
      });

      if (mounted) {
        context.read<ClienteProvider>().cargarResumenCliente(_cliente.id, tiendaId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fiado registrado exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.summary, (route) => false);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      
      // Si el backend rechaza por limite de credito (Error 400)
      if (e.response?.statusCode == 400 && e.response?.data['error'].toString().contains('límite') == true) {
        _mostrarDialogoLimiteExcedido();
      } else {
        // Otro tipo de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar el fiado. Intente de nuevo.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al registrar.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // NUEVO: Dialogo cuando el limite de credito es excedido
  void _mostrarDialogoLimiteExcedido() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Límite excedido'),
        content: Text('El monto de este fiado supera el límite de crédito de ${_cliente.nombreCompleto}. ¿Qué deseas hacer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Solo cierra el dialogo
            child: const Text('Entendido', style: TextStyle(color: AppColors.inkMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el dialogo
              // Abre el panel para editar el limite
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => EditCreditLimitBottomSheet(customer: _cliente),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white),
            child: const Text('Editar límite'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

    return AppHeaderConfig(
      title: 'Finalizar fiado',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Fecha límite de pago', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  hintText: 'Selecciona una fecha',
                  hintStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
                  suffixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.ink),
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.mist)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.mist)),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.mist)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Productos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teal)),
                    const SizedBox(height: 12),
                    ..._cartItems.map(
                      (p) => FiadoProductItem(name: p['name'], price: p['price'] * p['qty']),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total :', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    Text(total.toStringAsFixed(2), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // BOTON FINALIZAR
              ElevatedButton(
                onPressed: _isSaving ? null : _registrarFiado,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isSaving 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Finalizar y Registrar', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),

              // NUEVO: BOTON CANCELAR FIADO (Sutil)
              TextButton(
                onPressed: _isSaving ? null : _cancelarFiado,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Cancelar fiado', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}