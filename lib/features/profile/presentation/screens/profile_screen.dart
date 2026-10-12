import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/profile_badge.dart';
import '../widgets/profile_field_tile.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_section.dart';

/// Pantalla "Mi Perfil" del tendero.
/// Se abre al tocar la tarjeta de usuario en el Menú.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // TODO: reemplazar por los datos reales del usuario (API / sesión).
  static const _names = 'Jonel';
  static const _lastNames = 'Villanueva';
  static const _dni = '45872631';
  static const _email = 'jonel@email.com';
  static const _phone = '+51 999 999 999';
  static const _address = 'Av. Universitaria 789, Lima';

  void _edit(BuildContext context, String field) {
    // TODO: abrir la edición del campo.
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Editar $field: próximamente')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _ProfileAppBar(onEdit: () => _edit(context, 'perfil')),
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
                    name: '$_names $_lastNames',
                    email: _email,
                    onChangePhoto: () => _edit(context, 'foto'),
                  ),
                  const SizedBox(height: 24),

                  ProfileSection(
                    title: 'Información personal',
                    children: [
                      ProfileFieldTile(
                        label: 'Nombres',
                        value: _names,
                        onTap: () => _edit(context, 'nombres'),
                      ),
                      ProfileFieldTile(
                        label: 'Apellidos',
                        value: _lastNames,
                        onTap: () => _edit(context, 'apellidos'),
                      ),
                      ProfileFieldTile(
                        label: 'DNI',
                        value: _dni,
                        onTap: () => _edit(context, 'DNI'),
                      ),
                      
                    ],
                  ),
                  const SizedBox(height: 24),

                  ProfileSection(
                    title: 'Contacto',
                    children: [
                      const ProfileFieldTile(
                        label: 'Teléfono móvil',
                        value: _phone,
                        trailing: ProfileBadge(label: 'Verificado'),
                      ),
                      ProfileFieldTile(
                        label: 'Dirección particular',
                        value: _address,
                        onTap: () => _edit(context, 'dirección'),
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

/// Barra superior: flecha de regreso, título centrado y lápiz de editar.
class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,

      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.ink),
              ),
              const Expanded(
                child: Text(
                  'Mi Perfil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
