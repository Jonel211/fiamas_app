import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';
import 'package:fiamas_app/core/utils/image_url.dart';
import 'package:fiamas_app/core/widgets/app_avatar.dart';
import 'package:fiamas_app/core/widgets/app_header_config.dart';
import 'package:fiamas_app/core/widgets/image_zoom_screen.dart'; 
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../widgets/edit_credit_limit_bottom_sheet.dart';

class CustomerProfileScreen extends StatefulWidget {
  final ClienteModel customer;

  const CustomerProfileScreen({super.key, required this.customer});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
          context.read<AuthProvider>().user?.tiendaId;
      if (tiendaId != null) {
        context.read<ClienteProvider>().cargarResumenCliente(widget.customer.id, tiendaId);
        context.read<ClienteProvider>().cargarFiadosCliente(
          widget.customer.id,
          tiendaId,
          nombre: widget.customer.nombreCompleto,
          telefono: widget.customer.telefono,
        );
      }
    });
  }

  String _getFormattedDate(DateTime? date) {
    if (date == null) return 'Cliente registrado';
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final month = months[date.month - 1];
    return 'Cliente desde $month ${date.year}';
  }

  //  NUEVO: Abre la foto del cliente en pantalla completa con zoom
  void _abrirZoomImagen(BuildContext context, String? photoUrl, String nombreCliente) {
    final url = resolveImageUrl(photoUrl);
    if (url == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageZoomScreen(imageUrl: url),
      ),
    );
  }

  Future<void> _launchCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el marcador')));
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final fullPhone = cleanPhone.length == 9 ? '51$cleanPhone' : cleanPhone;
    final Uri url = Uri.parse('https://wa.me/$fullPhone');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp')));
    }
  }

  Future<void> _launchMaps(String? address) async {
    if (address == null || address.trim().isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este cliente no tiene una dirección registrada')));
      return;
    }
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el mapa')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final resumen = provider.resumenCliente;

    final name = widget.customer.nombreCompleto;
    final phone = widget.customer.telefono;
    final address = widget.customer.direccion;

    final detalleTienda = (resumen != null && resumen['detalle_por_tienda'] != null && (resumen['detalle_por_tienda'] as List).isNotEmpty)
        ? resumen['detalle_por_tienda'][0] as Map<String, dynamic>
        : null;

    final creditLimit = double.tryParse(detalleTienda?['limite_credito']?.toString() ?? '') ?? widget.customer.vinculacion.limiteCredito;
    final totalFiado = provider.totalFiadoCliente;
    final totalPagado = provider.totalPagadoCliente;
    final debt = provider.saldoPendienteCliente;
    final score = int.tryParse(detalleTienda?['score_pagador']?.toString() ?? '') ?? widget.customer.vinculacion.scorePagador;
    final categoria = (detalleTienda?['categoria_pagador'] as String?) ?? widget.customer.vinculacion.categoriaPagador;

    final nivel = nivelScore(score, categoria);
    final badgeText = nivel.etiqueta;
    final badgeColor = nivel.color;
    final fechaTexto = _getFormattedDate(widget.customer.creadoEn);
    // Si el resumen ya cargó, manda su valor (aunque sea null) para no
    // resucitar una foto borrada con el modelo recibido por navegación.
    final resumenCliente = resumen?['cliente'];
    final String? photoUrl;
    if (resumenCliente is Map &&
        resumenCliente.containsKey('foto_perfil_url')) {
      photoUrl = resumenCliente['foto_perfil_url'] as String?;
    } else if (resumen != null && resumen.containsKey('foto_perfil_url')) {
      photoUrl = resumen['foto_perfil_url'] as String?;
    } else {
      photoUrl = widget.customer.fotoPerfilUrl;
    }

    final tieneFoto = resolveImageUrl(photoUrl) != null;
    final used = debt;
    final available = creditLimit - used;
    final usagePercent = creditLimit > 0 ? (used / creditLimit * 100).clamp(0.0, 100.0) : 0.0;

    return AppHeaderConfig(
      title: 'Perfil Del Cliente',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: provider.isLoadingResumen
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // TARJETA SUPERIOR: Avatar + Nombre + Score + Badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            children: [
                              //  ZOOM: La foto del cliente ahora es clicable
                              GestureDetector(
                                onTap: tieneFoto ? () => _abrirZoomImagen(context, photoUrl, name) : null,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    AppAvatar.cliente(
                                      imageUrl: photoUrl,
                                      name: name,
                                      size: 90,
                                      fontSize: 36,
                                    ),
                                    // Ícono de lupa en la esquina (solo si hay foto)
                                    if (tieneFoto)
                                      Positioned(
                                        right: -2,
                                        bottom: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.55),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                          child: const Icon(
                                            Icons.zoom_in_rounded,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink), textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              Text(fechaTexto, style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                              const SizedBox(height: 12),

                              // BOTÓN DEL SCORE CLICABLE
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/scoring-history',
                                    arguments: {
                                      'id': widget.customer.id, // <-- ¡AQUÍ ESTÁ LA CORRECCIÓN!
                                      'name': name,
                                      'score': score,
                                      'categoria': categoria,
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                                      const SizedBox(width: 6),
                                      Text('Score $score', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                            child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // BOTONES DE ACCIÓN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionCircleButton(icon: Icons.phone, label: 'Llamar', onTap: () => _launchCall(phone)),
                        _ActionCircleButton(icon: Icons.chat_bubble_outline, label: 'WhatsApp', onTap: () => _launchWhatsApp(phone)),
                        _ActionCircleButton(icon: Icons.location_on_outlined, label: 'Dirección', onTap: () => _launchMaps(address)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // TARJETA DE TELÉFONO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, color: AppColors.teal, size: 20),
                              const SizedBox(width: 8),
                              const Text('Teléfono', style: TextStyle(fontSize: 14, color: AppColors.inkMuted)),
                            ],
                          ),
                          Text(
                            phone,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TARJETA TEAL: SALDO ACTUAL PENDIENTE
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SALDO ACTUAL PENDIENTE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text('S/ ${debt.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
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

                    // TARJETA BLANCA: LÍMITE DE CRÉDITO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Límite de crédito', style: TextStyle(fontSize: 14, color: AppColors.inkMuted)),
                              Row(
                                children: [
                                  Text('S/ ${creditLimit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => EditCreditLimitBottomSheet(customer: widget.customer),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.1), shape: BoxShape.circle),
                                      child: const Icon(Icons.edit, color: AppColors.teal, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: usagePercent / 100,
                              backgroundColor: AppColors.skyBlue.withValues(alpha: 0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Usado: S/ ${used.toStringAsFixed(2)} (${usagePercent.toInt()}%)', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                              Text('Disponible: S/ ${available.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

// WIDGET: Botón circular de acción (Llamar, WhatsApp, etc.)
class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.skyBlue.withValues(alpha: 0.4), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.teal, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}