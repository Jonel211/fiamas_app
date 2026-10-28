/// Datos personales del tendero.
class UserProfile {
  const UserProfile({
    required this.names,
    required this.lastNames,
    required this.dni,
    required this.email,
    required this.phone,
    this.address = '',
    this.photoUrl,
  });

  const UserProfile.empty()
      : names = '',
        lastNames = '',
        dni = '',
        email = '',
        phone = '',
        address = '',
        photoUrl = null;

  final String names;
  final String lastNames;
  final String dni;
  final String email;

  /// Solo los 9 dígitos, sin prefijo. Ej: 999999999
  final String phone;
  final String address;
  final String? photoUrl;

  String get fullName => '$names $lastNames'.trim();

  /// Ej: +51 999 999 999
  String get phoneDisplay {
    if (phone.length != 9) return phone;
    return '+51 ${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
  }

  UserProfile copyWith({
    String? names,
    String? lastNames,
    String? phone,
    String? address,
    String? photoUrl,
  }) =>
      UserProfile(
        names: names ?? this.names,
        lastNames: lastNames ?? this.lastNames,
        dni: dni,
        email: email,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}