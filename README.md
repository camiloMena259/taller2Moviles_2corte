# 📱 Taller JWT - Aplicación Móvil Flutter

## 🎯 Descripción del Proyecto

Este proyecto es una aplicación Flutter desarrollada como parte del **Taller de Autenticación JWT** del curso de Desarrollo Móvil. La aplicación implementa un sistema completo de autenticación utilizando JSON Web Tokens (JWT) conectándose a una API REST real.

## 🚀 ¿Qué se implementó?

### 1. **Autenticación JWT Completa**
- ✅ **Registro de usuarios** mediante API REST (`POST /api/users`)
- ✅ **Login con credenciales** que retorna un token JWT (`POST /api/login`)
- ✅ **Logout** que limpia todos los datos almacenados localmente
- ✅ Validación de formularios con manejo de errores en tiempo real
- ✅ Manejo de excepciones específicas por código HTTP (401, 422, 409, 404, 403)

### 2. **Gestión de Estado con Provider**
- ✅ Implementación de `ChangeNotifier` para manejo reactivo del estado
- ✅ Estados: `idle`, `loading`, `success`, `error`
- ✅ Notificaciones automáticas a la UI cuando cambia el estado de autenticación

### 3. **Almacenamiento Local Seguro**
- ✅ **SharedPreferences**: Datos no sensibles (nombre, email, ID de usuario)
- ✅ **FlutterSecureStorage**: Datos sensibles encriptados (tokens JWT)
- ✅ Diferenciación clara entre tipos de almacenamiento
- ✅ Uso de Keychain (iOS) y Keystore (Android) para encriptación nativa

### 4. **Arquitectura Limpia**
```
lib/
├── models/              # Modelos de datos (ParkingUser)
├── services/            # Lógica de negocio (ParkingAuthService)
├── views/               # Interfaces de usuario
│   ├── auth/           # Vistas de autenticación (Login, Registro)
│   └── home/           # Dashboard y vistas principales
├── widgets/            # Componentes reutilizables (CustomDrawer)
└── routes/             # Configuración de navegación (GoRouter)
```

### 5. **Integración con API Real**
- 🌐 **API Base**: `https://parking.visiontic.com.co/api`
- 📡 **Endpoints utilizados**:
  - `POST /api/users` - Registro de usuarios
  - `POST /api/login` - Autenticación con JWT
- 🔒 Headers requeridos: `Content-Type: application/json`, `Accept: application/json`

### 6. **Experiencia de Usuario**
- ✅ Flujo de navegación intuitivo: Login → Dashboard → Información de Usuario
- ✅ Mensajes de error claros y visibles en pantalla
- ✅ Feedback visual con SnackBars y banners de error
- ✅ Confirmación de acciones críticas (logout)
- ✅ Menú lateral (Drawer) con todas las funcionalidades de la app
- ✅ Vista detallada de información almacenada localmente

## 📋 Características Principales

| Característica | Descripción |
|----------------|-------------|
| **Autenticación JWT** | Sistema completo de registro, login y logout |
| **Manejo de Errores** | Validación en tiempo real con mensajes específicos |
| **Almacenamiento Dual** | SharedPreferences + SecureStorage |
| **Estado Reactivo** | Provider para actualización automática de UI |
| **Navegación** | GoRouter para rutas declarativas |
| **API REST** | Integración con backend real |
| **Seguridad** | Encriptación de tokens con Keychain/Keystore |

## 🛠️ Tecnologías Utilizadas

- **Flutter** `^3.9.0` - Framework de desarrollo móvil
- **Dart** - Lenguaje de programación
- **Provider** `^6.1.5` - Gestión de estado
- **GoRouter** `^16.2.1` - Navegación declarativa
- **HTTP** `^1.5.0` - Cliente HTTP para API REST
- **SharedPreferences** `^2.5.3` - Almacenamiento local simple
- **FlutterSecureStorage** `^9.2.4` - Almacenamiento encriptado

## 📱 Flujo de la Aplicación

```
1. Inicio → Pantalla de Login
   ↓
2. Usuario puede:
   - Iniciar sesión (si ya tiene cuenta)
   - Registrarse (crear nueva cuenta)
   ↓
3. Login exitoso → Dashboard Principal
   - Muestra información del usuario autenticado
   - Botón de logout en AppBar
   - Menú lateral con opciones:
     * Pokemons, CDTs, Establecimientos, etc.
     * Información de Usuario (detallada)
   ↓
4. Información de Usuario
   - Muestra datos de SharedPreferences
   - Muestra datos de SecureStorage (tokens)
   - Explicación educativa de los tipos de almacenamiento
   ↓
5. Logout → Vuelve a Login
   - Limpia todos los datos locales
   - Requiere confirmación del usuario
```

## 🔒 Seguridad Implementada

### Datos No Sensibles (SharedPreferences)
- ✅ Nombre de usuario
- ✅ Email
- ✅ ID de usuario
- ✅ Estado de sesión (`is_logged_in`)

### Datos Sensibles (FlutterSecureStorage)
- 🔐 Access Token (JWT)
- 🔐 Refresh Token (si aplica)
- 🔐 Encriptación automática por el SO

## 🧪 Manejo de Errores

| Código | Error | Manejo en la App |
|--------|-------|------------------|
| **200** | OK | Login exitoso, navega al dashboard |
| **201** | Created | Registro exitoso, navega al login |
| **400** | Bad Request | Muestra mensaje de solicitud incorrecta |
| **401** | Unauthorized | "Credenciales incorrectas" |
| **403** | Forbidden | "Cuenta no verificada o bloqueada" |
| **404** | Not Found | "Usuario no encontrado" |
| **409** | Conflict | "El email ya está registrado" |
| **422** | Validation Error | Muestra errores específicos del campo |

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                           # Punto de entrada, configuración Provider
├── models/
│   └── parking_user.dart              # Modelo de usuario
├── services/
│   └── parking_auth_service.dart      # Servicio de autenticación JWT
├── views/
│   ├── auth/
│   │   ├── login_view.dart           # Pantalla de login
│   │   └── register_view.dart        # Pantalla de registro
│   └── home/
│       ├── home_screen.dart          # Dashboard principal
│       └── user_info_view.dart       # Información detallada de usuario
├── widgets/
│   └── custom_drawer.dart            # Menú lateral personalizado
└── routes/
    └── app_router.dart               # Configuración de rutas
```

## 🎓 Conceptos Aprendidos

1. **Autenticación JWT**: Implementación completa de flujo de autenticación
2. **Gestión de Estado**: Uso de Provider y ChangeNotifier
3. **Almacenamiento Local**: Diferencias entre SharedPreferences y SecureStorage
4. **API REST**: Consumo de endpoints con HTTP
5. **Manejo de Errores**: Validación y feedback al usuario
6. **Arquitectura Limpia**: Separación de responsabilidades
7. **Navegación**: Rutas declarativas con GoRouter
8. **Seguridad Móvil**: Encriptación de datos sensibles

## 🚀 Getting Started

### Prerrequisitos
```bash
flutter --version  # Flutter SDK 3.9.0 o superior
```

### Instalación
```bash
# Clonar el repositorio
git clone <repository-url>
cd taller2Moviles_2corte

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

### Ejecutar en diferentes plataformas
```bash
# Chrome
flutter run -d chrome

# Android Emulator
flutter run -d emulator-5554

# iOS Simulator
flutter run -d iPhone
```

## 👨‍💻 Autor

**Camilo Mena**
- GitHub: [@camiloMena259](https://github.com/camiloMena259)

## 📝 Licencia

Este proyecto fue desarrollado con fines educativos como parte del curso de Desarrollo Móvil.

---

## 🔗 Enlaces Útiles

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)
- [FlutterSecureStorage](https://pub.dev/packages/flutter_secure_storage)
- [JWT.io](https://jwt.io/) - Información sobre JSON Web Tokens
