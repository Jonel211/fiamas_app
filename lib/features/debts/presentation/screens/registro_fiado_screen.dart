import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart'; // Para usar AppRoutes
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
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

  // Un teléfono válido son exactamente 9 dígitos
  static final _telefonoValido = RegExp(r'^\d{9}$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
  }

  // CORRECCIÓN: Ahora es async y espera a que el backend responda
  Future<void> _cargarDatos() async {
    final tiendaId = context.read<AuthProvider>().user?.tiendaId;
    if (tiendaId != null && tiendaId.isNotEmpty) {
      final provider = context.read<ClienteProvider>();
      await provider.cargarClientes(tiendaId); // para el buscador
      await provider.cargarRecientes(tiendaId, limit: 4); // para "Recientes"
      
      // Forzamos el redibujado para que aparezca el cliente nuevo
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _irAEscaner(Object cliente) {
    Navigator.of(context).pushNamed(AppRoutes.scannerView, arguments: cliente);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim();
    final buscando = query.isNotEmpty;

    return AppHeaderConfig(
      title: 'Nuevo Fiado',
      showBack: true,
      centerTitle: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
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
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Busca por nombre o teléfono',
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

                    const SizedBox(height: 16),

                    Consumer<ClienteProvider>(
                      builder: (context, provider, _) {
                        if (provider.error != null) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                provider.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }

                        // ─────────── MODO BÚSQUEDA ───────────
                        if (buscando) {
                          final resultados = provider.buscarClienteLocal(query);
                          final puedeRegistrar =
                              _telefonoValido.hasMatch(query) && resultados.isEmpty;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (puedeRegistrar)
                                RegisterClientSuggestion(
                                  phone: query,
                                  onTap: () async {
                                    await Navigator.of(context).pushNamed(
                                      AppRoutes.newClient,
                                      arguments: query,
                                    );
                                    if (!mounted) return;
                                    await _cargarDatos(); // Refresca la lista al volver
                                  },
                                ),

                              if (resultados.isEmpty && !puedeRegistrar)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Text(
                                      'No se encontraron clientes.\nEscribe los 9 dígitos del teléfono para registrar uno nuevo.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.inkMuted),
                                    ),
                                  ),
                                ),

                              for (final cliente in resultados)
                                RecentClientCard(
                                  name: cliente.nombreCompleto,
                                  phone: cliente.telefono,
                                  onTap: () => _irAEscaner(cliente),
                                ),
                            ],
                          );
                        }

                        // ─────────── MODO RECIENTES ───────────
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Recientes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (provider.isLoadingRecientes)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (provider.recientes.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'Aún no has fiado a nadie.\nBusca un cliente por nombre o teléfono.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.inkMuted),
                                  ),
                                ),
                              )
                            else
                              for (final cliente in provider.recientes)
                                RecentClientCard(
                                  name: cliente.nombreCompleto,
                                  phone: cliente.telefono,
                                  onTap: () => _irAEscaner(cliente),
                                ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
