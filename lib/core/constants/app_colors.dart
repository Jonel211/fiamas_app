import 'package:flutter/material.dart';

/// Paleta oficial Fiamas (según el diseño en Figma).
class AppColors {
  AppColors._();

  // ── Paleta principal del diseño ──────────────────────────────
  /// Color de marca. Paneles, acentos y navegación activa.
  static const Color teal = Color(0xFF1D9492);

  /// Acento de acción: botones destacados, badges, saldos pendientes.
  static const Color gold = Color(0xFFE0AA3D);

  /// Fondo suave teal: chips, etiquetas y superficies de marca.
  static const Color tealSoft = Color(0xFFE3F3F2);

  /// Azul claro: fondos suaves, chips, estados informativos.
  static const Color skyBlue = Color(0xFFB1D8F7);

  /// Blanco puro.
  static const Color ivory = Color(0xFFFFFFFF);

  /// Fondo alterno de pantallas internas.
  static const Color background = Color(0xFFF8FAFC);

  // ── Se conservan para no romper pantallas existentes ─────────
  /// Texto principal / "negro" del sistema.
  static const Color ink = Color(0xFF12172A);

  /// Bordes de inputs y separadores. Nunca como texto.
  static const Color mist = Color(0xFFE4E2DB);

  static const Color inkMuted = Color(0xFF5B6072); // texto secundario
  static const Color surface = Colors.white; // tarjetas
  static const Color danger = Color(0xFFB3452C); // errores

  // NUEVOS COLORES para pantallas de clientes
  /// Verde para estados exitosos (pagado, al día).
  static const Color success = Color(0xFF22C55E);

  /// Morado para avatares y acentos.
  static const Color purple = Color(0xFF8B5CF6);
  // Estados (avisos, notificaciones y formularios)
  /// Fondo suave para elementos en rojo (errores, urgencias).
  static const Color dangerSoft = Color(0xFFFDECEC);

  /// Advertencias: límite de crédito, vencimientos.
  static const Color warning = Color(0xFFD98A1B);

  /// Fondo suave para advertencias.
  static const Color warningSoft = Color(0xFFFFF3D6);

  /// Fondo de tarjetas leídas, campos de solo lectura y selectores inactivos.
  static const Color surfaceMuted = Color(0xFFF1F4F8);

  // Extras
  /// Verde del ícono de WhatsApp.
  static const Color whatsapp = Color(0xFF25D366);
}
