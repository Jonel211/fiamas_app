import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/step_progress_bar.dart';
import 'new_debt_scan_screen.dart';

class NewDebtCustomerScreen extends StatefulWidget {
  const NewDebtCustomerScreen({super.key});

  @override
  State<NewDebtCustomerScreen> createState() => _NewDebtCustomerScreenState();
}

class _NewDebtCustomerScreenState extends State<NewDebtCustomerScreen> {
  final _searchController = TextEditingController();
  String? _selectedCustomer;

  // TODO: reemplazar por datos reales desde CustomersRepository
  static const _recentCustomers = [
    ('Ricardo Mendoza', '987 123 456'),
    ('Lucía García', '955 666 777'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goNext() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewDebtScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text('Nuevo Fiado',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 16),
              const StepProgressBar(currentStep: 1),
              const SizedBox(height: 24),
              Text('Datos del fiadero',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 18)),
              const SizedBox(height: 2),
              Text('¿A quién le vas a fiar?',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20, color: AppColors.inkMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Busca por nombre o teléfono...',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // TODO: abrir formulario para registrar nuevo fiadero
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.mist, style: BorderStyle.solid, width: 1.4),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.mist,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_add_alt_1_outlined,
                            color: AppColors.ink, size: 20),
                      ),
                      const SizedBox(height: 8),
                      const Text('Registrar nuevo fiadero',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.ink)),
                      const SizedBox(height: 2),
                      const Text('NOMBRE Y TELÉFONO',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.4,
                              color: AppColors.inkMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('RECIENTES',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: AppColors.inkMuted)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    for (final customer in _recentCustomers)
                      _RecentCustomerTile(
                        name: customer.$1,
                        phone: customer.$2,
                        selected: _selectedCustomer == customer.$1,
                        onTap: () =>
                            setState(() => _selectedCustomer = customer.$1),
                      ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _goNext,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Siguiente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentCustomerTile extends StatelessWidget {
  const _RecentCustomerTile({
    required this.name,
    required this.phone,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String phone;
  final bool selected;
  final VoidCallback onTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.mist,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.mist,
              child: Text(_initials,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.ink)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink)),
                  Text(phone,
                      style:
                          const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}