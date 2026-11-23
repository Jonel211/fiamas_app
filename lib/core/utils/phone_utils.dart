/// Normaliza un teléfono peruano a 9 dígitos.
///
/// Quita todo lo que no sea dígito y, si quedan 11 dígitos empezando con 51,
/// elimina el prefijo de país. Misma regla que aplica el backend.
String normalizarTelefonoPE(String telefono) {
  var digitos = telefono.replaceAll(RegExp(r'\D'), '');

  if (digitos.length == 11 && digitos.startsWith('51')) {
    digitos = digitos.substring(2);
  }

  return digitos;
}

/// Un teléfono es válido si, tras normalizarlo, tiene exactamente 9 dígitos.
bool esTelefonoValido(String telefono) {
  return normalizarTelefonoPE(telefono).length == 9;
}
