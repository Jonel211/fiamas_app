import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../domain/user_profile.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_avatar.dart';

/// Edita los datos del tendero. Recibe el [UserProfile] como argumento de
/// la ruta y, al guardar, devuelve el perfil actualizado a la pantalla anterior.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ModalRoute.of(context)?.settings.arguments as UserProfile? ??
        const UserProfile.empty();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const ProfileAppBar(title: 'Editar perfil'),
          Expanded(child: _EditProfileForm(profile: profile)),
        ],
      ),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm({required this.profile});

  final UserProfile profile;

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _names;
  late final TextEditingController _lastNames;
  late final TextEditingController _dni;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    _names = TextEditingController(text: widget.profile.names);
    _lastNames = TextEditingController(text: widget.profile.lastNames);
    _dni = TextEditingController(text: widget.profile.dni);
    _phone = TextEditingController(text: widget.profile.phone);
    _address = TextEditingController(text: widget.profile.address);
  }

  @override
  void dispose() {
    _names.dispose();
    _lastNames.dispose();
    _dni.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _required(String? v, String message) =>
      (v == null || v.trim().isEmpty) ? message : null;

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // TODO: enviar los cambios a la API.
    Navigator.of(context).pop(widget.profile.copyWith(
      names: _names.text.trim(),
      lastNames: _lastNames.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + MediaQuery.of(context).padding.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ProfileAvatar(
                name: widget.profile.names,
                onChangePhoto: () {
                  // TODO: abrir selector de imagen / cámara
                },
              ),
            ),
            const SizedBox(height: 32),
            AuthField(
              label: 'Nombres',
              controller: _names,
              textCapitalization: TextCapitalization.words,
              validator: (v) => _required(v, 'Ingresa tus nombres'),
            ),
            AuthField(
              label: 'Apellidos',
              controller: _lastNames,
              textCapitalization: TextCapitalization.words,
              validator: (v) => _required(v, 'Ingresa tus apellidos'),
            ),
            AuthField(
              label: 'DNI (no se puede modificar)',
              controller: _dni,
              enabled: false,
            ),
            AuthField(
              label: 'Número de celular',
              controller: _phone,
              keyboardType: TextInputType.phone,
              maxLength: 9,
              digitsOnly: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa tu celular';
                return v.length == 9 ? null : 'El celular debe tener 9 dígitos';
              },
            ),
            AuthField(
              label: 'Dirección particular (Opcional)',
              controller: _address,
              textCapitalization: TextCapitalization.sentences,
              bottomSpacing: 28,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              onPressed: _save,
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}