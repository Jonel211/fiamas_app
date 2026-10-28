import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/user_profile.dart';
import '../widgets/profile_badge.dart';
import '../widgets/profile_field_tile.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_section.dart';

/// Pantalla "Mi Perfil" del tendero.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().cargarPerfil();
    });
  }

  void _snack(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  /// Abre "Editar perfil" y, si se guardó, actualiza los datos en pantalla.
  Future<void> _openEdit(UserProfile current) async {
    final result = await Navigator.of(context)
        .pushNamed(AppRoutes.editProfile, arguments: current);

    if (result == null || !mounted) return;

    if (result is UserProfile) {
      _snack('Perfil actualizado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final perfil = authProvider.perfil;
    final user = authProvider.user;

    final p = UserProfile(
      names: perfil?.nombres.isNotEmpty == true ? perfil!.nombres : (user?.nombre ?? 'Tendero'),
      lastNames: perfil?.apellidos ?? '',
      dni: perfil?.dni.isNotEmpty == true ? perfil!.dni : 'Sin DNI',
      email: '',
      phone: perfil?.telefono ?? '',
      address: perfil?.tiendas.isNotEmpty == true ? (perfil!.tiendas.first.direccion ?? '') : '',
      photoUrl: perfil?.fotoUrl,
    );

    return AppHeaderConfig(
      title: 'Mi Perfil',
      showBack: true,
      centerTitle: true,
      actions: [
        AppHeaderIconAction(icon: Icons.edit_outlined, onTap: () => _openEdit(p)),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeaderCard(
                name: p.fullName.isNotEmpty ? p.fullName : 'Tendero Fiamas',
                email: p.phoneDisplay.isNotEmpty ? p.phoneDisplay : 'Sin teléfono',
                imageUrl: p.photoUrl,
                onChangePhoto: () => _openEdit(p),
              ),
              const SizedBox(height: 24),
              ProfileSection(
                title: 'Información personal',
                children: [
                  ProfileFieldTile(label: 'Nombres', value: p.names, onTap: () => _openEdit(p)),
                  ProfileFieldTile(label: 'Apellidos', value: p.lastNames.isNotEmpty ? p.lastNames : 'No registrado', onTap: () => _openEdit(p)),
                  ProfileFieldTile(label: 'DNI', value: p.dni),
                ],
              ),
              const SizedBox(height: 24),
              ProfileSection(
                title: 'Contacto',
                children: [
                  ProfileFieldTile(
                    label: 'Teléfono móvil',
                    value: p.phoneDisplay.isNotEmpty ? p.phoneDisplay : 'Sin registrar',
                    onTap: () => _openEdit(p),
                    trailing: p.phone.isNotEmpty ? const ProfileBadge(label: 'Verificado') : null,
                  ),
                  ProfileFieldTile(
                    label: 'Dirección particular',
                    value: p.address.isEmpty ? 'Sin registrar' : p.address,
                    onTap: () => _openEdit(p),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}