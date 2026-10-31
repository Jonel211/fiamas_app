import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiamas_app/core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../widgets/customer_card.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _selectedFilter = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarClientesTiendaActual();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarClientesTiendaActual();
  }

  void _cargarClientesTiendaActual() {
    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    if (tiendaId != null && mounted) {
      final provider = context.read<ClienteProvider>();
      if (provider.tiendaIdCargada != tiendaId) {
        provider.cargarClientes(tiendaId);
      }
    }
  }

  Future<void> _onRefresh() async {
    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    if (tiendaId != null) {
      await context.read<ClienteProvider>().cargarClientes(tiendaId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getStatus(ClienteModel c) {
    if (c.vinculacion.saldoActual <= 0) return 'Al día';
    if (c.vinculacion.cantidadFiadosMora > 0) return 'Vencido';
    return 'Con deuda';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final query = _searchController.text.toLowerCase();

    final filtrados = provider.clientes.where((c) {
      final coincideBusqueda =
          c.nombreCompleto.toLowerCase().contains(query) ||
          c.telefono.contains(query);
      final status = _getStatus(c);
      final coincideFiltro =
          _selectedFilter == 'Todos' || _selectedFilter == status;
      return coincideBusqueda && coincideFiltro;
    }).toList();

    return Container(
      color: AppColors.background,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.teal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clientes',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${provider.clientes.length} clientes registrados',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isSearchFocused ? AppColors.teal : AppColors.mist,
                  width: _isSearchFocused ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isSearchFocused
                        ? AppColors.teal.withOpacity(0.15)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: _isSearchFocused ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: _isSearchFocused
                        ? AppColors.teal
                        : AppColors.inkMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o teléfono',
                        hintStyle: TextStyle(
                          color: AppColors.inkMuted,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _searchController.clear()),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.inkMuted,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Al día', dotColor: AppColors.success),
                  const SizedBox(width: 8),
                  _buildFilterChip('Con deuda', dotColor: AppColors.gold),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vencido', dotColor: AppColors.danger),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filtrados.isEmpty)
              const Center(
                child: Text(
                  'No se encontraron clientes',
                  style: TextStyle(color: AppColors.inkMuted),
                ),
              )
            else
              ...filtrados.map((cliente) {
                final status = _getStatus(cliente);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomerCard(
                    id: cliente.id,
                    name: cliente.nombreCompleto,
                    phone: cliente.telefono,
                    status: status,
                    debtAmount: cliente.vinculacion.saldoActual,
                    extraInfo: status == 'Al día'
                        ? 'Sin fiados activos'
                        : '${cliente.vinculacion.totalFiados} fiados activos',
                    // TOCAR EL CÍRCULO: Va al Perfil
                    onTapProfile: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.customerProfile,
                        arguments: cliente,
                      );
                    },
                    // TOCAR EL RESTO: Va al Historial (usando el Map que espera la ruta)
                    onTapHistory: () {
                      final customerMap = {
                        'id': cliente.id,
                        'name': cliente.nombreCompleto,
                        'phone': cliente.telefono,
                        'debt': cliente.vinculacion.saldoActual,
                        'creditLimit': cliente.vinculacion.limiteCredito,
                        'status': status,
                        'activeDebts': cliente.vinculacion.totalFiados,
                      };
                      Navigator.pushNamed(
                        context,
                        AppRoutes.debtHistory,
                        arguments: customerMap,
                      );
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildFilterChip(String label, {Color? dotColor}) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.teal : AppColors.mist,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}