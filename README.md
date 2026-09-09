# App Móvil - Fiamas SaaS

![Version](https://img.shields.io/badge/version-1.0.0-007EC6)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![JWT](https://img.shields.io/badge/JWT-Authentication-000000?logo=JSON%20web%20tokens&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-336791?logo=postgresql&logoColor=white)

![Status](https://img.shields.io/badge/status-development-D4B800)
![License](https://img.shields.io/badge/license-MIT-4C9108)
![GitHub](https://img.shields.io/badge/GitHub-Repository-000000?logo=github&logoColor=white)
![Git](https://img.shields.io/badge/Git-Version%20Control-F05032?logo=git&logoColor=white)

**"Digitalizando la confianza"** — Una aplicación móvil multiplataforma desarrollada en Flutter para transformar la gestión del crédito informal, permitiendo a tenderos y clientes controlar sus cuentas de fiados de forma ágil y transparente.

---

## Descripción del Proyecto

Esta aplicación forma parte del ecosistema **Fiamas**. La solución móvil está orientada a optimizar la atención de tiendas y comercios minoristas, facilitando el registro rápido de deudas, el control de límites de crédito por cliente, la integración de escáner y el seguimiento en tiempo real de los estados de cuenta.

---

## Arquitectura

La aplicación móvil se conecta con la API RESTful del backend central:

* **App Móvil:** Flutter (Android / iOS).
* **Backend:** Node.js + Express.js.
* **API:** RESTful.
* **Autenticación:** JWT (JSON Web Tokens).
* **Base de Datos:** PostgreSQL.

---

## Estructura del Repositorio

El proyecto organiza sus módulos siguiendo un enfoque escalable dentro de Flutter:

```text
fiamas_app/
├── lib/
│   ├── core/                # Configuración global, temas y clientes de red
│   │   ├── constants/       # Colores, temas y rutas
│   │   ├── hardware/        # Gestión de cámara para el escáner de productos
│   │   ├── network/         # Cliente de conexión a la API REST
│   │   ├── theme/           # Configuración de temas y estilos
│   │   ├── utils/           # Validadores y utilidades
│   │   └── widgets/         # Componentes reutilizables
│   ├── features/            # Módulos por funcionalidad
│   │   ├── auth/            # Autenticación y login de usuarios
│   │   ├── customers/       # Gestión de Clientes y Límites de Crédito
│   │   ├── dashboard/       # Vista principal y reportes financieros en tiempo real
│   │   ├── debts/           # Registro de fiados, abonos y control de pagos
│   │   ├── inventory/       # CRUD de productos, categorías y lógica del escáner
│   │   └── profile/         # Configuración comercial de la tienda
│   └── main.dart            # Punto de entrada de la aplicación
├── assets/                  # Recursos estáticos
│   ├── icons/               # Iconografía de la app
│   └── images/              # Logos e ilustraciones
├── pubspec.yaml             # Configuración de dependencias de Flutter
└── README.md                # Documentación principal del proyecto
```

---

## Requisitos Previos e Instalación

Para ejecutar este proyecto en tu entorno local, asegúrate de contar con:

* [Flutter SDK](https://flutter.dev/) (versión 3.x o superior)
* [Dart SDK](https://dart.dev/)
* Android Studio / VS Code con extensiones de Flutter
* [Git](https://git-scm.com/)
* Servidor Backend de **Fiamas** en ejecución (`http://localhost:3000`)

### Pasos para iniciar el entorno de desarrollo

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/Jonel211/fiamas_app.git
   cd fiamas_app
   ```

2. **Instalar las dependencias de Flutter:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

---

## Arquitectura de Ejecución

La aplicación móvil consume la API de Node.js que interactúa con la base de datos PostgreSQL:

```text
┌─────────────────────┐
│      App Móvil      │
│       Flutter       │
│    (Android / iOS)  │
└──────────┬──────────┘
           │
           │ API REST (HTTP / JSON)
           ▼
┌─────────────────────┐
│       Backend       │
│   Node.js + Express │
│  localhost:3000     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│     PostgreSQL      │
│      Database       │
└──────────┴──────────┘
```

---

## Estado del Proyecto

**En desarrollo:**  
Versión actual: `1.0.0`  
En proceso de implementación de UI/UX y conexión con la API REST.
