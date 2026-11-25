import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiamas_app/core/constants/app_colors.dart';

import '../../../../core/utils/phone_or_name_input_formatter.dart';

import '../../../../core/widgets/app_header.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../widgets/customer_card.dart';
import '../../../debts/presentation/widgets/register_client_suggestion.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen>
    with RouteAware {
  String _selectedFilter = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  bool _subscribed = false;

  static final _telefonoValido = RegExp(r'^\d{9}$');

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cargarClientesTiendaActual();
    });
  }

  String? _lastLoadedTiendaId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_subscribed) {
      _subscribed = true;
      final route = ModalRoute.of(context);
      if (route != null) routeObserver.subscribe(this, route);
    }

    final tiendaId =
        context.watch<TiendaProvider>().tiendaSeleccionadaId ??
        context.watch<AuthProvider>().user?.tiendaId;
    if (tiendaId != null && tiendaId != _lastLoadedTiendaId) {
      _lastLoadedTiendaId = tiendaId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cargarClientesTiendaActual();
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _onRefresh();
  }

  void _cargarClientesTiendaActual() {
    final tiendaId =
        context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    if (tiendaId != null && mounted) {
      final provider = context.read<ClienteProvider>();
      provider.cargarClientes(tiendaId);
    }
  }

  Future<void> _onRefresh() async {
    final tiendaId =
        context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    if (tiendaId != null) {
      await context.read<ClienteProvider>().cargarClientes(tiendaId);
    }
  }

  String _getStatus(ClienteModel c) {
    if (c.vinculacion.cantidadFiadosMora > 0) return 'Vencido';
    if (c.vinculacion.saldoActual > 0 || c.vinculacion.fiadosActivos > 0) {
      return 'Con deuda';
    }
    return 'Al día';
  }

  String _getExtraInfo(ClienteModel c) {
    final activos = c.vinculacion.fiadosActivos;
    if (activos <= 0) return 'Sin fiados activos';
    if (activos == 1) return '1 fiado activo';
    return '$activos fiados activos';
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${provider.clientes.length} clientes registrados',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppHeaderPillAction(
                    label: 'scoring',
                    backgroundColor: AppColors.teal,
                    onTap: () =>
                        Navigator.of(context)
                            .pushNamed(AppRoutes.scoringRanking),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                          ? AppColors.teal.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.04),
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
                        inputFormatters: [PhoneOrNameInputFormatter()],
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

              if (provider.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Error del servidor: ${provider.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (provider.isLoading && provider.clientes.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (filtrados.isEmpty)
                if (query.isNotEmpty && _telefonoValido.hasMatch(query))
                  RegisterClientSuggestion(
                    phone: query,
                    onTap: () async {
                      await Navigator.of(context)
                          .pushNamed(AppRoutes.newClient, arguments: query);
                      if (!mounted) return;
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No se encontraron clientes.\nEscribe los 9 dígitos del teléfono para registrar uno nuevo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.inkMuted),
                      ),
                    ),
                  )
              else
                ...filtrados.map((cliente) {
                  final status = _getStatus(cliente);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: Key(cliente.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 24),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      //  TODA la lógica va AQUÍ, antes de descartar
                      confirmDismiss: (direction) async {
                        // 1. Confirmación del usuario
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Eliminar cliente'),
                            content: Text(
                              '¿Estás seguro de que deseas eliminar a '
                              '${cliente.nombreCompleto}?\n\n'
                              'Esta acción no se puede deshacer.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.danger,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmar != true) return false; // cancela el swipe

                        // 2. Llamar al backend
                        final tiendaId = context
                                .read<TiendaProvider>()
                                .tiendaSeleccionadaId ??
                            context.read<AuthProvider>().user?.tiendaId;
                        if (tiendaId == null) return false;

                        final provider = context.read<ClienteProvider>();
                        final success = await provider.eliminarCliente(
                          cliente.id,
                          tiendaId,
                        );

                        if (!context.mounted) return false;

                        // 3a. FALLÓ (tiene deudas) → NO descartar, el widget
                        //     vuelve solo a su lugar. Sin error rojo.
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.errorEliminar ??
                                    'No se puede eliminar: el cliente tiene deudas pendientes.',
                              ),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                          return false;
                        }

                        // 3b. ÉXITO → sí se descarta
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cliente eliminado exitosamente'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        return true;
                      },
                      //  Solo remover de la lista local (síncrono, sin await)
                      onDismissed: (_) {
                        context
                            .read<ClienteProvider>()
                            .removerClienteLocal(cliente.id);
                      },
                      child: CustomerCard(
                        id: cliente.id,
                        name: cliente.nombreCompleto,
                        phone: cliente.telefono,
                        imageUrl: cliente.fotoPerfilUrl,
                        status: status,
                        debtAmount: cliente.vinculacion.saldoActual,
                        extraInfo: _getExtraInfo(cliente),
                        onTapProfile: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.customerProfile,
                            arguments: cliente,
                          );
                        },
                        onTapHistory: () {
                          final customerMap = {
                            'id': cliente.id,
                            'name': cliente.nombreCompleto,
                            'phone': cliente.telefono,
                            'imageUrl': cliente.fotoPerfilUrl,
                            'debt': cliente.vinculacion.saldoActual,
                            'creditLimit': cliente.vinculacion.limiteCredito,
                            'status': status,
                            'activeDebts': cliente.vinculacion.fiadosActivos,
                          };
                          Navigator.pushNamed(
                            context,
                            AppRoutes.debtHistory,
                            arguments: customerMap,
                          );
                        },
                      ),
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
          border: Border.all(color: isActive ? AppColors.teal : AppColors.mist),
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