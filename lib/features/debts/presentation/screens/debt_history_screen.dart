import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../domain/debt.dart';
import 'debt_detail_multiple_screen.dart';

class DebtHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> customer;

  const DebtHistoryScreen({super.key, required this.customer});

  @override
  State<DebtHistoryScreen> createState() => _DebtHistoryScreenState();
}

class _DebtHistoryScreenState extends State<DebtHistoryScreen> {
  String _selectedFilter = 'Todos';
  bool _isInit = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedDebtIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cargarFiados();
      });
    }
  }

  void _cargarFiados() {
    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    final clienteId = widget.customer['id'];
    if (tiendaId != null && clienteId != null) {
      context.read<ClienteProvider>().cargarFiadosCliente(
        clienteId,
        tiendaId,
        nombre: widget.customer['name']?.toString(),
        telefono: widget.customer['phone']?.toString(),
      );
    }
  }

  bool _esVigente(Debt d) => d.isActive && !d.isOverdue;
  bool _esVencido(Debt d) => d.isOverdue;

  void _pruneSelection(List<Debt> fiados) {
    final selectableIds = fiados.where((d) => d.isSelectable).map((d) => d.id).toSet();
    _selectedDebtIds.removeWhere((id) => !selectableIds.contains(id));
  }

  void _setFilter(String label) {
    final fiados = context.read<ClienteProvider>().fiadosCliente;
    setState(() {
      _selectedFilter = label;
      _pruneSelection(fiados);
    });
  }

  void _enterSelectionMode() {
    final fiados = context.read<ClienteProvider>().fiadosCliente;
    if (!fiados.any((d) => d.isSelectable)) {
      _mostrarSinFiadosPendientes();
      return;
    }
    setState(() {
      _isSelectionMode = true;
      _pruneSelection(fiados);
    });
  }

  void _mostrarSinFiadosPendientes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay fiados pendientes para cobrar')),
    );
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedDebtIds.clear();
    });
  }

  void _toggleSelection(Debt debt) {
    if (!debt.isSelectable) return;
    setState(() {
      if (!_selectedDebtIds.remove(debt.id)) {
        _selectedDebtIds.add(debt.id);
      }
    });
  }

  String _formatearFechaLimite(String fechaIso) {
    try {
      final date = DateTime.parse(fechaIso);
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return fechaIso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final clienteId = widget.customer['id'] as String;

    ClienteModel? clienteCompleto;
    for (final c in provider.clientes) {
      if (c.id == clienteId) {
        clienteCompleto = c;
        break;
      }
    }

    final name = clienteCompleto?.nombreCompleto ?? (widget.customer['name']?.toString() ?? 'Cliente');
    final phone = clienteCompleto?.telefono ?? (widget.customer['phone']?.toString() ?? '');
    final debtAmount = provider.saldoPendienteCliente;
    final score = clienteCompleto?.vinculacion.scorePagador ?? 100;
    final categoria = clienteCompleto?.vinculacion.categoriaPagador ?? 'nuevo';

    final initial = name.trim().isNotEmpty ? name.trim().split(' ').last[0].toUpperCase() : 'C';
    final nivel = nivelScore(score, categoria);
    final badgeText = nivel.etiqueta;
    final badgeColor = nivel.color;
    final photoUrl = clienteCompleto?.fotoPerfilUrl ?? (widget.customer['imageUrl'] as String?);
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    final fiados = provider.fiadosCliente;

    final fiadosFiltrados = fiados.where((d) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Vigentes') return _esVigente(d);
      if (_selectedFilter == 'Pagados') return d.status == DebtStatus.pagado;
      if (_selectedFilter == 'Vencidos') return _esVencido(d);
      return true;
    }).toList();

    final totalFiado = provider.totalFiadoCliente;
    final totalPagado = provider.totalPagadoCliente;
    final tieneDeudasPendientes = fiados.any((d) => d.isSelectable);

    final selectedDebts = fiados.where((d) => d.isSelectable && _selectedDebtIds.contains(d.id)).toList();
    final hasSelection = selectedDebts.isNotEmpty;
    final selectedTotal = selectedDebts.fold<double>(0.0, (sum, debt) => sum + debt.remainingAmount);

    return AppHeaderConfig(
      title: _isSelectionMode ? '${selectedDebts.length} seleccionado${selectedDebts.length == 1 ? '' : 's'}' : 'Historial de Cliente',
      centerTitle: true,
      showBack: !_isSelectionMode,
      leading: _isSelectionMode
          ? TextButton(
              onPressed: _exitSelectionMode,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      actions: _isSelectionMode
          ? [
              IconButton(
                icon: Icon(Icons.check_circle, color: hasSelection ? Colors.white : Colors.white54),
                onPressed: hasSelection ? _goToDetail : null,
              ),
            ]
          : const [],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (clienteCompleto != null) {
                        Navigator.pushNamed(context, AppRoutes.customerProfile, arguments: clienteCompleto);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.teal,
                            backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                            onBackgroundImageError: hasPhoto ? (_, _) {} : null,
                            child: hasPhoto ? null : Text(initial, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
                                const SizedBox(height: 4),
                                Text(phone, style: TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                                child: Text('Score $score', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                                child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SALDO ACTUAL PENDIENTE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text('S/ ${debtAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total fiado', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text('S/ ${totalFiado.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total pagado', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text('S/ ${totalPagado.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterHeaderDelegate(
                extent: 56,
                backgroundColor: AppColors.background,
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildFilterChip('Todos', fiados.length, _selectedFilter == 'Todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Vigentes', fiados.where(_esVigente).length, _selectedFilter == 'Vigentes'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pagados', fiados.where((d) => d.status == DebtStatus.pagado).length, _selectedFilter == 'Pagados'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Vencidos', fiados.where(_esVencido).length, _selectedFilter == 'Vencidos'),
                    ],
                  ),
                ),
              ),
            ),
            if (provider.isLoadingFiados)
              const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
            else if (provider.errorFiados != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(provider.errorFiados!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)))),
              )
            else if (fiadosFiltrados.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Este cliente no tiene fiados registrados.', style: TextStyle(color: AppColors.inkMuted, fontSize: 15))),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) => _buildDebtCard(fiadosFiltrados[index]), childCount: fiadosFiltrados.length),
                ),
              ),
          ],
        ),
        bottomNavigationBar: (_isSelectionMode && hasSelection)
            ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2))]),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _goToDetail,
                      icon: const Icon(Icons.account_balance_wallet, size: 20),
                      label: Text('Cobrar S/ ${selectedTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ),
              )
            : null,
        floatingActionButton: (!_isSelectionMode && tieneDeudasPendientes)
            ? FloatingActionButton.extended(
                onPressed: _enterSelectionMode,
                backgroundColor: AppColors.teal,
                icon: const Icon(Icons.checklist, color: Colors.white),
                label: const Text('Seleccionar fiados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              )
            : null,
      ),
    );
    }

  Widget _buildFilterChip(String label, int count, bool isActive) {
    return GestureDetector(
      onTap: () => _setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.teal : AppColors.mist),
        ),
        child: Text('$label ($count)', style: TextStyle(color: isActive ? Colors.white : AppColors.ink, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

     Widget _buildDebtCard(Debt debt) {
    final pagado = debt.status == DebtStatus.pagado;
    final parcial = debt.status == DebtStatus.parcial;
    final vencido = debt.isOverdue;
    final selectable = debt.isSelectable;
    final isSelected = selectable && _selectedDebtIds.contains(debt.id);

    final etiqueta = pagado
        ? 'PAGADO'
        : (vencido ? 'VENCIDO' : (parcial ? 'PARCIAL' : 'PENDIENTE'));
    final color = pagado
        ? AppColors.success
        : (vencido
            ? AppColors.danger
            : (parcial ? AppColors.parcial : AppColors.gold));
    final chipBackground = (!vencido && parcial)
        ? AppColors.parcialSoft
        : color.withValues(alpha: 0.15);

    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(debt);
        } else {
          _openDebtDetail(debt);
        }
      },
      child: Opacity(
        opacity: (_isSelectionMode && !selectable) ? 0.55 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSelectionMode) ...[
                Container(
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.teal : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: !selectable
                          ? AppColors.mist
                          : (isSelected ? AppColors.teal : AppColors.mist),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'S/ ${debt.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: chipBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            etiqueta,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      debt.items.map((item) => item.productName).join(', '),
                      style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    //  LÓGICA ACTUALIZADA: Pagado vs Vencimiento
                    if (pagado &&
                        debt.paidDate != null &&
                        debt.paidDate!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pagado: ${_formatearFechaLimite(debt.paidDate!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color:
                                  AppColors.success, // Verde para confirmación
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ] else if (!pagado &&
                        debt.dueDate != null &&
                        debt.dueDate!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            vencido
                                ? Icons.event_busy_outlined
                                : Icons.event_outlined,
                            size: 14,
                            color: vencido ? AppColors.danger : AppColors.gold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${vencido ? 'Vencido' : 'Vence'}: ${_formatearFechaLimite(debt.dueDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: vencido
                                  ? AppColors.danger
                                  : AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          debt.dateLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        if (!pagado)
                          Text(
                            'Resta S/ ${debt.remainingAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: vencido
                                  ? AppColors.danger
                                  : AppColors.gold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDebtDetail(Debt debt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DebtDetailMultipleScreen(
          customer: {
            'id': widget.customer['id'],
            'name': debt.customerName,
            'phone': debt.phone,
            'imageUrl': widget.customer['imageUrl'],
          },
          debts: [debt],
        ),
      ),
    );
    if (!mounted) return;
    _cargarFiados();
  }

  void _goToDetail() {
    final fiados = context.read<ClienteProvider>().fiadosCliente;
    final selectedDebts = fiados.where((d) => d.isSelectable && _selectedDebtIds.contains(d.id)).toList();

    if (selectedDebts.isEmpty) {
      _mostrarSinFiadosPendientes();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DebtDetailMultipleScreen(
          customer: widget.customer,
          debts: selectedDebts,
          isCollectFlow: true,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      _cargarFiados();
    });
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double extent;
  final Color backgroundColor;
  final Widget child;

  const _FilterHeaderDelegate({required this.extent, required this.backgroundColor, required this.child});

  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(height: extent, color: backgroundColor, child: Center(child: child));
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => true;
}