import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/modal_bottom_sheet_layout.dart';
import '../../../customers/data/models/cliente_existente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';

class VincularClienteSheet extends StatefulWidget {
  final ClienteExistenteModel cliente;
  final String tiendaId;

  const VincularClienteSheet({
    super.key,
    required this.cliente,
    required this.tiendaId,
  });

  @override
  State<VincularClienteSheet> createState() => _VincularClienteSheetState();
}

class _VincularClienteSheetState extends State<VincularClienteSheet> {
  final _limitController = TextEditingController(text: '500.00');
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  double? get _limite {
    final text = _limitController.text.replaceAll(',', '.').trim();
    return double.tryParse(text);
  }

  bool get _limiteValido {
    final limite = _limite;
    return limite != null && limite > 0 && limite <= 10000;
  }

  String? get _limiteError {
    if (_limitController.text.trim().isEmpty) {
      return 'Ingresa un límite de crédito';
    }
    if (!_limiteValido) {
      return 'El límite debe ser mayor a 0 y hasta S/ 10,000';
    }
    return null;
  }

  Future<void> _vincular() async {
    if (_submitting || !_limiteValido) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    final provider = context.read<ClienteProvider>();
    final success = await provider.vincularCliente(
      clienteId: widget.cliente.clienteId ?? '',
      tiendaId: widget.tiendaId,
      limiteCredito: _limite!,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _submitting = false;
      _error = provider.errorVinculacion ?? 'No se pudo vincular al cliente.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLinking = context.watch<ClienteProvider>().isLinking;
    final isBusy = _submitting || isLinking;

    return ModalBottomSheetLayout(
      title: 'Este cliente ya está en Fiamas',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: AppAvatar.cliente(
              imageUrl: widget.cliente.fotoPerfilUrl,
              name: widget.cliente.nombreCompleto,
              size: 56,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.cliente.nombreCompleto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vincula a este cliente a tu tienda para empezar a fiarle.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Límite de crédito',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _limitController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '500.00',
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  widthFactor: 1.0,
                  child: Text(
                    'S/',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              errorText: _limiteError,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.mist),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.mist),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.teal),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isBusy || !_limiteValido ? null : _vincular,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.5),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isBusy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Vincular',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: isBusy ? null : () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
