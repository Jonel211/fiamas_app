import 'package:flutter/material.dart';

/// Paleta oficial "Fiamas High Contrast".
/// Pensada para tenderos que operan en tiendas con luz variable (mostrador,
/// exterior, celular viejo): alto contraste, pocos tonos, cero ambigüedad.
class AppColors {
  AppColors._();

  /// Fondo general de la app. Blanco puro: máximo contraste y legibilidad
  /// bajo luz directa de mostrador.
  static const Color ivory = Color(0xFFFFFFFF);

  /// Color de marca principal. Usado en botones primarios, títulos
  /// y el texto de mayor jerarquía. Hace de "negro" del sistema.
  static const Color ink = Color(0xFF12172A);

  /// Acento secundario: estados de éxito, iconografía de confianza
  /// (candado, check de registro), y elementos de navegación activa.
  static const Color teal = Color(0xFF3E6F66);

  /// Acento de atención: badges, indicadores de saldo pendiente,
  /// elementos que requieren acción del tendero.
  static const Color gold = Color(0xFFD9A441);

  /// Gris claro para bordes de inputs, separadores y fondos de tarjetas
  /// inactivas. Nunca se usa como texto por bajo contraste.
  static const Color mist = Color(0xFFE4E2DB);

  // Variantes derivadas de uso frecuente
  static const Color inkMuted = Color(0xFF5B6072); // texto secundario
  static const Color surface = Colors.white; // tarjetas sobre ivory
  static const Color danger = Color(0xFFB3452C); // errores de validación
}