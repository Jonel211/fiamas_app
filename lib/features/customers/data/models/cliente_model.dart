import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ClienteModel {
  final String id;
  final String telefono;
  final String nombres;
  final String apellidos;
  final String? direccion;
  final String? fotoPerfilUrl;
  final DateTime? creadoEn;
  final VinculacionModel vinculacion;

  ClienteModel({
    required this.id,
    required this.telefono,
    required this.nombres,
    required this.apellidos,
    this.direccion,
    this.fotoPerfilUrl,
    this.creadoEn,
    required this.vinculacion,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] ?? '',
      telefono: json['telefono'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      direccion: json['direccion'],
      fotoPerfilUrl:
          json['foto_perfil_url'] ??
          json['foto_url'] ??
          json['foto'] ??
          json['avatar_url'],
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'].toString())
          : null,
      vinculacion: VinculacionModel.fromJson(json['vinculacion'] ?? {}),
    );
  }

  String get nombreCompleto => '$nombres $apellidos'.trim();
}

class VinculacionModel {
  final String id;
  final double limiteCredito;
  final double saldoActual;
  final int scorePagador;
  final String categoriaPagador;
  final int totalFiados;
  final int totalPagos;
  final int cantidadFiadosMora;

  VinculacionModel({
    required this.id,
    required this.limiteCredito,
    required this.saldoActual,
    required this.scorePagador,
    required this.categoriaPagador,
    required this.totalFiados,
    required this.totalPagos,
    required this.cantidadFiadosMora,
  });

  factory VinculacionModel.fromJson(Map<String, dynamic> json) {
    return VinculacionModel(
      id: json['id'] ?? '',
      limiteCredito:
          double.tryParse(json['limite_credito']?.toString() ?? '') ?? 500.0,
      saldoActual:
          double.tryParse(json['saldo_actual']?.toString() ?? '') ?? 0.0,
      scorePagador:
          int.tryParse(json['score_pagador']?.toString() ?? '') ?? 100,
      categoriaPagador: json['categoria_pagador'] ?? 'nuevo',
      totalFiados: int.tryParse(json['total_fiados']?.toString() ?? '') ?? 0,
      totalPagos: int.tryParse(json['total_pagos']?.toString() ?? '') ?? 0,
      cantidadFiadosMora:
          int.tryParse(json['cantidad_fiados_mora']?.toString() ?? '') ?? 0,
    );
  }

  /// Nivel de scoring según lo que calcula el backend.
  NivelScore get nivel => nivelScore(scorePagador, categoriaPagador);
}

// ───────────── SCORING: ÚNICA REGLA PARA TODAS LAS PANTALLAS ─────────────
// Solo usa score_pagador y categoria_pagador que manda el backend.
// Si el backend cambia cómo calcula el score, las pantallas se actualizan solas.

enum NivelScore { nuevo, bueno, regular, malo }

NivelScore nivelScore(int score, String categoria) {
  if (categoria.toLowerCase() == 'nuevo') return NivelScore.nuevo;
  if (score >= 80) return NivelScore.bueno;
  if (score >= 50) return NivelScore.regular;
  return NivelScore.malo;
}

extension NivelScoreX on NivelScore {
  String get etiqueta {
    switch (this) {
      case NivelScore.nuevo:
        return 'Nuevo';
      case NivelScore.bueno:
        return 'Buen pagador';
      case NivelScore.regular:
        return 'Regular';
      case NivelScore.malo:
        return 'Mal pagador';
    }
  }

  Color get color {
    switch (this) {
      case NivelScore.nuevo:
        return AppColors.skyBlue;
      case NivelScore.bueno:
        return AppColors.teal;
      case NivelScore.regular:
        return AppColors.gold;
      case NivelScore.malo:
        return AppColors.danger;
    }
  }
}