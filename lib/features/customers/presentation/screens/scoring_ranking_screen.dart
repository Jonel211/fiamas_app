import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiamas_app/core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';

class ScoringRankingScreen extends StatefulWidget {
  const ScoringRankingScreen({super.key});

  @override
  State<ScoringRankingScreen> createState() => _ScoringRankingScreenState();
}

class _ScoringRankingScreenState extends State<ScoringRankingScreen> {
  String _filtroCategoria = 'Todos';

  List<ClienteModel> _ordenarClientes(List<ClienteModel> lista) {
    final copia = List<ClienteModel>.from(lista);
    copia.sort((a, b) {
      // 1. Mayor puntaje primero (100 -> 1)
      final cmpScore =
          b.vinculacion.scorePagador.compareTo(a.vinculacion.scorePagador);
      if (cmpScore != 0) return cmpScore;

      // 2. Desempate: quien tenga más pagos realizados va arriba (premia al buen pagador sobre el nuevo)
      final cmpPagos =
          b.vinculacion.totalPagos.compareTo(a.vinculacion.totalPagos);
      if (cmpPagos != 0) return cmpPagos;

      // 3. Desempate: menos fiados en mora
      return a.vinculacion.cantidadFiadosMora
          .compareTo(b.vinculacion.cantidadFiadosMora);
    });
    return copia;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final ordenados = _ordenarClientes(provider.clientes);

    // Filtrar por categoría si el usuario seleccionó un chip
    final filtrados = ordenados.where((c) {
      if (_filtroCategoria == 'Todos') return true;
      return c.vinculacion.nivel.etiqueta == _filtroCategoria;
    }).toList();

    // Mostrar podio solo cuando está en "Todos" y hay al menos 2 clientes
    final mostrarPodio = _filtroCategoria == 'Todos' && filtrados.length >= 2;
    final top3 = mostrarPodio ? filtrados.take(3).toList() : <ClienteModel>[];
    final restoLista =
        mostrarPodio ? filtrados.skip(3).toList() : filtrados;

    // Promedio general de scoring de la tienda
    final promedio = ordenados.isEmpty
        ? 0
        : (ordenados
                    .map((c) => c.vinculacion.scorePagador)
                    .reduce((a, b) => a + b) /
                ordenados.length)
            .round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ranking de Scoring',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Cabecera curva con resumen de la tienda
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(
                  label: 'Evaluados',
                  value: '${ordenados.length}',
                  icon: Icons.people_alt_rounded,
                ),
                Container(
                  height: 32,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                _buildHeaderStat(
                  label: 'Score promedio',
                  value: '$promedio / 100',
                  icon: Icons.insights_rounded,
                ),
              ],
            ),
          ),

          // Chips de filtro por categoría
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                _buildFilterChip('Todos'),
                const SizedBox(width: 8),
                _buildFilterChip('Buen pagador', color: AppColors.teal),
                const SizedBox(width: 8),
                _buildFilterChip('Nuevo', color: AppColors.skyBlue),
                const SizedBox(width: 8),
                _buildFilterChip('Regular', color: AppColors.gold),
                const SizedBox(width: 8),
                _buildFilterChip('Mal pagador', color: AppColors.danger),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: filtrados.isEmpty
                ? const Center(
                    child: Text(
                      'No hay clientes en esta categoría',
                      style: TextStyle(color: AppColors.inkMuted, fontSize: 14),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    children: [
                      // PODIO TOP 3
                      if (mostrarPodio) ...[
                        _buildPodio(top3),
                        const SizedBox(height: 24),
                        if (restoLista.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Clasificación general',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                      ],

                      // LISTA DEL RESTO DE CLIENTES
                      ...List.generate(restoLista.length, (index) {
                        final cliente = restoLista[index];
                        final puesto =
                            mostrarPodio ? index + 4 : index + 1;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildRankingCard(cliente, puesto),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {Color? color}) {
    final isSelected = _filtroCategoria == label;
    return GestureDetector(
      onTap: () => setState(() => _filtroCategoria = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.mist,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodio(List<ClienteModel> top3) {
    final primero = top3[0];
    final segundo = top3.length > 1 ? top3[1] : null;
    final tercero = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mist),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2DO LUGAR (Izquierda)
          if (segundo != null)
            Expanded(
              child: _buildPodiumSpot(
                cliente: segundo,
                puesto: 2,
                medallaColor: const Color(0xFF94A3B8), // Plata
                alturaPedestal: 64,
              ),
            ),
          const SizedBox(width: 8),
          // 1ER LUGAR (Centro - más alto)
          Expanded(
            child: _buildPodiumSpot(
              cliente: primero,
              puesto: 1,
              medallaColor: AppColors.gold, // Oro
              alturaPedestal: 88,
              esPrimero: true,
            ),
          ),
          const SizedBox(width: 8),
          // 3ER LUGAR (Derecha)
          if (tercero != null)
            Expanded(
              child: _buildPodiumSpot(
                cliente: tercero,
                puesto: 3,
                medallaColor: const Color(0xFFCD7F32), // Bronce
                alturaPedestal: 48,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot({
    required ClienteModel cliente,
    required int puesto,
    required Color medallaColor,
    required double alturaPedestal,
    bool esPrimero = false,
  }) {
    final nivel = cliente.vinculacion.nivel;
    final primerNombre = cliente.nombres.split(' ').first;

    return GestureDetector(
      onTap: () => _abrirHistorialScoring(cliente),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (esPrimero)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(
                Icons.emoji_events_rounded,
                color: AppColors.gold,
                size: 28,
              ),
            ),
          // Avatar con borde de medalla
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: medallaColor,
                    width: esPrimero ? 3 : 2,
                  ),
                ),
                child: _buildAvatar(cliente, radius: esPrimero ? 28 : 22),
              ),
              Positioned(
                bottom: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: medallaColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#$puesto',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Nombre
          Text(
            primerNombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: esPrimero ? 14 : 13,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          // Etiqueta de categoría
          Text(
            nivel.etiqueta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: nivel.color,
            ),
          ),
          const SizedBox(height: 8),
          // Pedestal con el puntaje resaltado
          Container(
            width: double.infinity,
            height: alturaPedestal,
            decoration: BoxDecoration(
              color: medallaColor.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border.all(
                color: medallaColor.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${cliente.vinculacion.scorePagador}',
                  style: TextStyle(
                    fontSize: esPrimero ? 24 : 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  'pts',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(ClienteModel cliente, int puesto) {
    final nivel = cliente.vinculacion.nivel;
    final score = cliente.vinculacion.scorePagador;

    return InkWell(
      onTap: () => _abrirHistorialScoring(cliente),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mist),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Posición en el ranking
            SizedBox(
              width: 30,
              child: Text(
                '#$puesto',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.inkMuted,
                ),
              ),
            ),
            // Avatar
            _buildAvatar(cliente, radius: 21),
            const SizedBox(width: 12),
            // Nombre y categoría
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nombreCompleto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: nivel.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          nivel.etiqueta,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: nivel.color,
                          ),
                        ),
                      ),
                      if (cliente.vinculacion.cantidadFiadosMora > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '• ${cliente.vinculacion.cantidadFiadosMora} en mora',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.danger,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Puntaje resaltado
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: nivel.color,
                      ),
                    ),
                    const Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Ver historial ›',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ClienteModel cliente, {required double radius}) {
    final inicial = cliente.nombres.isNotEmpty
        ? cliente.nombres[0].toUpperCase()
        : '?';

    if (cliente.fotoPerfilUrl != null && cliente.fotoPerfilUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(cliente.fotoPerfilUrl!),
        backgroundColor: AppColors.mist,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: cliente.vinculacion.nivel.color.withValues(alpha: 0.2),
      child: Text(
        inicial,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.75,
          color: cliente.vinculacion.nivel.color,
        ),
      ),
    );
  }

  void _abrirHistorialScoring(ClienteModel cliente) {
    Navigator.pushNamed(
      context,
      AppRoutes.scoringHistory,
      arguments: cliente,
    );
  }
}