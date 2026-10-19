import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../domain/user_profile.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_badge.dart';
import '../widgets/profile_field_tile.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_section.dart';

/// Pantalla "Mi Perfil" del tendero.
/// Se abre al tocar la tarjeta de usuario en el Menú.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // TODO: reemplazar por los datos reales del usuario (API / sesión).
  UserProfile _profile = const UserProfile(
    names: 'Jonel',
    lastNames: 'Villanueva',
    dni: '45872631',
    email: 'jonel@email.com',
    phone: '999999999',
    address: 'Av. Universitaria 789, Lima',
  );

  void _snack(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  /// Abre "Editar perfil" y, si se guardó, actualiza los datos en pantalla.
  Future<void> _openEdit() async {
    final result = await Navigator.of(context)
        .pushNamed(AppRoutes.editProfile, arguments: _profile);

    if (result == null || !mounted) return;

    if (result is UserProfile) {
      setState(() => _profile = result);
      _snack('Perfil actualizado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ProfileAppBar(
            title: 'Mi Perfil',
            actionIcon: Icons.edit_outlined,
            onAction: _openEdit,
          ),
          Expanded(
            child: SingleChildScrollView(
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
                    name: p.fullName,
                    email: p.email,
                    onChangePhoto: _openEdit,
                  ),
                  const SizedBox(height: 24),

                  ProfileSection(
                    title: 'Información personal',
                    children: [
                      ProfileFieldTile(label: 'Nombres', value: p.names, onTap: _openEdit),
                      ProfileFieldTile(label: 'Apellidos', value: p.lastNames, onTap: _openEdit),
                      // El DNI no se edita: sin flecha ni toque.
                      ProfileFieldTile(label: 'DNI', value: p.dni),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ProfileSection(
                    title: 'Contacto',
                    children: [
                      ProfileFieldTile(
                        label: 'Teléfono móvil',
                        value: p.phoneDisplay,
                        onTap: _openEdit,
                        trailing: const ProfileBadge(label: 'Verificado'),
                      ),
                      ProfileFieldTile(
                        label: 'Dirección particular',
                        value: p.address.isEmpty ? 'Sin registrar' : p.address,
                        onTap: _openEdit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}