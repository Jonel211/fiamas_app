/// Texto de la Política de Privacidad de Fiamas.
/// Separado de la UI para facilitar traducciones y ediciones futuras.
class PrivacyText {
  PrivacyText._();

  static const String intro =
      'En Fiamas, nos tomamos muy en serio la privacidad y seguridad de tus '
      'datos y los de tu negocio. Esta Política de Privacidad describe cómo '
      'recopilamos, utilizamos, almacenamos y protegemos tu información '
      'personal y comercial cuando utilizas nuestra aplicación móvil.';

  static const String collectIntro =
      'Para ofrecerte un funcionamiento óptimo de la aplicación, '
      'recopilamos los siguientes datos:';

  static const List<String> collectedData = [
    'Información de la Cuenta y Negocio: Nombre del titular, nombre de la '
        'bodega/negocio, dirección física, número de teléfono y correo '
        'electrónico.',
    'Información Comercial e Inventario: Nombres de productos, precios, '
        'stock, historial de ventas y registros de movimientos financieros.',
    'Información de Clientes y Fiados: Nombres, números de contacto y montos '
        'adeudados que ingresas manualmente dentro del módulo de fiados.',
    'Datos Técnicos y de Uso: Dirección IP, tipo de dispositivo, sistema '
        'operativo e informes de fallas para mejorar el rendimiento de la app.',
  ];

  static const String purposesIntro =
      'Utilizamos la información recopilada exclusivamente para los '
      'siguientes fines:';

  static const List<String> purposes = [
    'Facilitar el control de tus ventas, inventario y gestión de cobranzas '
        'a clientes.',
    'Generar los reportes visuales y archivos exportables en formato PDF '
        'dentro de la app.',
    'Brindarte soporte técnico y responder a tus consultas en el módulo de '
        'ayuda.',
    'Enviar notificaciones importantes sobre actualizaciones de la '
        'aplicación o cambios en el servicio.',
  ];

  static const String balance =
      'Precisión de Saldos: La app calcula los saldos y reportes en función '
      'de los datos que ingreses. No nos hacemos responsables por errores '
      'de digitación o pérdida de información por mal uso del dispositivo.';

  static const String availability =
      'Disponibilidad: Nos esforzamos por mantener el servicio disponible '
      '24/7, pero no garantizamos un servicio ininterrumpido en caso de '
      'mantenimiento o fallas técnicas ajenas a nuestro control.';

  static const String thirdPartiesIntro =
      'No compartimos tus datos personales ni comerciales con terceros, '
      'salvo en las siguientes excepciones:';

  static const List<String> thirdParties = [
    'Proveedores de Servicios Cloud: Para el alojamiento seguro de la base '
        'de datos de tu app.',
    'Requerimiento Legal: Cuando sea exigido por ley o por orden de una '
        'autoridad competente.',
  ];

  static const String rights =
      'Tienes derecho a acceder, rectificar, actualizar o solicitar la '
      'eliminación definitiva de tu cuenta y todos los datos registrados en '
      'la app. Puedes ejercer estos derechos enviando una solicitud desde '
      'la sección de Configuración / Perfil o escribiéndonos a '
      'jhad@fiamas.com.';

  static const String updates =
      'Nos reservamos el derecho de actualizar esta Política de Privacidad '
      'en cualquier momento. Notificaremos cualquier cambio significativo '
      'publicando la nueva versión dentro de la app con la fecha '
      'actualizada.';

  static const String contactIntro =
      'Si tienes preguntas o dudas sobre esta Política de Privacidad, puedes '
      'contactarnos directamente en:';

  static const List<String> contactChannels = [
    'Correo de soporte: jhad@fiamas.com',
    'Sección de Soporte: Menú Ayuda dentro de la App.',
  ];
}