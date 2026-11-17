import 'package:url_launcher/url_launcher.dart';

enum TonoRecordatorio {
  respetuosa('Respetuosa'),
  firme('Firme'),
  urgente('Urgente');

  const TonoRecordatorio(this.label);

  final String label;

  String introduccion({
    required String nombreCliente,
    required String deuda,
    required String nombreTienda,
  }) {
    switch (this) {
      case TonoRecordatorio.respetuosa:
        return 'Hola $nombreCliente, ¿cómo estás? Te recordamos con cariño '
            'que tienes una deuda pendiente de S/ $deuda en $nombreTienda.';
      case TonoRecordatorio.firme:
        return 'Hola $nombreCliente, te escribimos de $nombreTienda para '
            'recordarte que tienes una deuda pendiente de S/ $deuda. '
            'Te agradecemos regularizarlo a la brevedad.';
      case TonoRecordatorio.urgente:
        return 'Hola $nombreCliente, tu deuda pendiente de S/ $deuda en '
            '$nombreTienda requiere atención inmediata. Por favor, '
            'comunícate con nosotros hoy para regularizarlo.';
    }
  }

  String mensaje({
    required String nombreCliente,
    required String deuda,
    required String nombreTienda,
    List<String> detalle = const [],
  }) {
    final buffer = StringBuffer(
      introduccion(
        nombreCliente: nombreCliente,
        deuda: deuda,
        nombreTienda: nombreTienda,
      ),
    );

    if (detalle.isNotEmpty) {
      buffer.write('\n\nDetalle:\n');
      buffer.write(detalle.join('\n'));
    }

    buffer.write('\n\n¡Gracias!');
    return buffer.toString();
  }
}

String normalizarTelefonoWhatsapp(String telefono) {
  final digitos = telefono.replaceAll(RegExp(r'\D'), '');
  if (digitos.isEmpty) return '';
  if (digitos.length == 9) return '51$digitos';
  return digitos;
}

Future<bool> abrirWhatsapp({
  required String telefono,
  required String mensaje,
}) async {
  final numero = normalizarTelefonoWhatsapp(telefono);
  if (numero.isEmpty) return false;

  final uri = Uri.parse(
    'https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}',
  );

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Mensaje que se envía al cliente la PRIMERA VEZ que el tendero
/// toca "Enviar recordatorio" para él. Su propósito es crear el hilo
/// de conversación en WhatsApp, para que después el envío de imagen
/// con el truco del `jid` funcione automáticamente.
String construirMensajeBienvenida({
  required String nombreCliente,
  required String nombreTienda,
}) {
  final nombre = nombreCliente.trim().isEmpty
      ? 'amigo(a)'
      : nombreCliente.trim();
  final tienda = nombreTienda.trim().isEmpty
      ? 'tu tienda de confianza'
      : nombreTienda.trim();
  return 'Hola $nombre, te saluda $tienda. 👋\n\n'
      'Bienvenido(a) a Fiamas. A partir de ahora te enviaré por aquí '
      'tus recordatorios de fiados. ¡Gracias por tu preferencia!';
}