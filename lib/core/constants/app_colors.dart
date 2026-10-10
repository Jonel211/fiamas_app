import 'package:flutter/material.dart';

/// Paleta oficial Fiamas (según el diseño en Figma).
class AppColors {
  AppColors._();

  // ── Paleta principal del diseño ──────────────────────────────
  /// Color de marca. Paneles, acentos y navegación activa.
  static const Color teal = Color(0xFF1D9492);

  /// Acento de acción: botones destacados, badges, saldos pendientes.
  static const Color gold = Color(0xFFE0AA3D);

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

  // ── Extras ───────────────────────────────────────────────────
  /// Verde del ícono de WhatsApp.
  static const Color whatsapp = Color(0xFF25D366);
}