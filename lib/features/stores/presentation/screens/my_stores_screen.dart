import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../data/tienda_repository.dart';
import '../../data/models/tienda_model.dart';
import 'new_store_screen.dart';
import '../../../../core/services/session_service.dart';

class MyStoresScreen extends StatefulWidget {
  const MyStoresScreen({super.key});

  @override
  State<MyStoresScreen> createState() => _MyStoresScreenState();
}

class _MyStoresScreenState extends State<MyStoresScreen> {
  final _repository = TiendaRepository();

  List<TiendaModel> _tiendas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarTiendas();
  }

  Future<void> _cargarTiendas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.obtenerMisTiendas();

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final tiendasJson = (data['data']?['tiendas'] ?? []) as List<dynamic>;
      setState(() {
        _tiendas = tiendasJson
            .map((t) => TiendaModel.fromJson(t as Map<String, dynamic>))
            .where((t) => t.activo) // solo activas
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Error al cargar tiendas';
        _isLoading = false;
      });
    }
  }

  Future<void> _irANuevaTienda() async {
    final creada = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const NewStoreScreen()));
    if (creada == true) {
      _cargarTiendas(); // Recargar si creó una nueva
    }
  }

 Future<void> _seleccionarTienda(TiendaModel tienda) async {
    await SessionService.saveTiendaActual(id: tienda.id, nombre: tienda.nombre);
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.summary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Título
              const Text(
                'Mis Tiendas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Elige la tienda que quieres gestionar',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 30),

              // Contenido
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0E7C7B),
                        ),
                      )
                    : _errorMessage != null
                    ? _buildError()
                    : _buildListaTiendas(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _cargarTiendas,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildListaTiendas() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        // Tarjetas de tiendas existentes
        ..._tiendas.map((tienda) => _buildTiendaCard(tienda)),

        // Botón "+ Nueva Tienda"
        _buildNuevaTiendaCard(),
      ],
    );
  }

  Widget _buildTiendaCard(TiendaModel tienda) {
    return GestureDetector(
      onTap: () => _seleccionarTienda(tienda),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront,
                size: 36,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tienda.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tienda.direccion ?? 'Sin ubicación',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNuevaTiendaCard() {
    return GestureDetector(
      onTap: _irANuevaTienda,
      child: Container(
        width: 110,
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: const Icon(Icons.add, size: 32, color: Color(0xFF0E7C7B)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nueva Tienda',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
