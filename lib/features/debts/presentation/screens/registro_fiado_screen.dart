import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../main.dart'; // <-- IMPORTANTE: Para usar AppRoutes
import '../widgets/recent_client_card.dart';
import '../widgets/register_client_suggestion.dart';

class RegistroFiadoScreen extends StatefulWidget {
  const RegistroFiadoScreen({super.key});

  @override
  State<RegistroFiadoScreen> createState() => _RegistroFiadoScreenState();
}

class _RegistroFiadoScreenState extends State<RegistroFiadoScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Nuevo Fiado'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Datos del fiadero',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿A quién le vas a fiar?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // BUSCADOR
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Busca por telefono',
                        hintStyle: TextStyle(
                          color: AppColors.inkMuted.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.inkMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  // BOTÓN DE REGISTRAR CLIENTE (Aparece solo si hay texto)
                  if (_searchQuery.isNotEmpty)
                    RegisterClientSuggestion(
                      phone: _searchQuery,
                      onTap: () {
                        // Navega a la pantalla de Nuevo Cliente
                        Navigator.of(context).pushNamed(AppRoutes.newClient);
                      },
                    ),

                  const SizedBox(height: 24),
                  const Text(
                    'Recientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  RecentClientCard(
                    name: 'Jonel Villanueva',
                    phone: '999999999',
                    onTap: () {
                      // CORREGIDO: Navega a la pantalla del escáner de productos
                      Navigator.of(context).pushNamed(AppRoutes.scannerView);
                    },
                  ),
                ],
              ),
            ),
          ),

          // BOTÓN SIGUIENTE
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: ElevatedButton(
              onPressed: () {
                // TODO: navegar al siguiente paso (productos)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Siguiente'),
            ),
          ),
        ],
      ),
    );
  }
}