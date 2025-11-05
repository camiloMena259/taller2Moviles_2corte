# 📱 Proyecto Flutter - Desarrollo Móvil UCEVA

## 🎯 Descripción del Proyecto

Este repositorio contiene el desarrollo de los talleres del curso de Desarrollo de Aplicaciones Móviles de UCEVA. Incluye implementaciones de autenticación JWT, integración con Firebase Realtime Database, y diversas funcionalidades móviles usando Flutter.

---

## 📚 Talleres Implementados

### 🔐 Taller 2: Autenticación JWT
Sistema completo de autenticación con tokens JWT, almacenamiento seguro y gestión de estado.

### 🔥 Taller 3: Integración con Firebase (ACTUAL)
Módulo de gestión de universidades con Firebase Realtime Database, operaciones CRUD y sincronización en tiempo real.

---

## 🔥 TALLER 3: Firebase Realtime Database

### 🎯 Objetivo
Desarrollar un módulo en Flutter que integre Firebase Realtime Database para gestionar una colección de universidades con operaciones CRUD completas y sincronización en tiempo real.

### ✨ Características Implementadas

#### 1. **Integración con Firebase**
- ✅ Configuración completa de Firebase usando FlutterFire CLI
- ✅ Firebase Realtime Database habilitado (sin necesidad de billing)
- ✅ Archivo `firebase_options.dart` generado automáticamente
- ✅ Inicialización de Firebase en la aplicación
- ✅ Conexión exitosa y persistente

#### 2. **Modelo de Datos - Universidad**
```dart
Universidad {
  - id: String?
  - nit: String
  - nombre: String
  - direccion: String
  - telefono: String
  - paginaWeb: String
}
```

#### 3. **Operaciones CRUD Completas**

##### **CREATE** - Crear Universidad
- ✅ Formulario con validaciones
- ✅ Campos: NIT, Nombre, Dirección, Teléfono, Página Web
- ✅ Validación de campos obligatorios
- ✅ Validación de formato de URL
- ✅ Verificación de NIT duplicado
- ✅ Guardado en Firebase Realtime Database
- ✅ Confirmación visual con SnackBar

##### **READ** - Listar Universidades
- ✅ Stream en tiempo real desde Firebase
- ✅ Actualización automática al agregar/editar/eliminar
- ✅ Diseño con Cards Material Design
- ✅ Estados: loading, error, empty state
- ✅ Banner de estado de conexión
- ✅ Información completa de cada universidad

##### **UPDATE** - Actualizar Universidad
- ✅ Carga de datos existentes en formulario
- ✅ Edición de todos los campos
- ✅ Validaciones en modo edición
- ✅ Actualización en Firebase
- ✅ Sincronización inmediata en la lista

##### **DELETE** - Eliminar Universidad
- ✅ Diálogo de confirmación
- ✅ Eliminación de Firebase
- ✅ Actualización automática de la lista
- ✅ Mensaje de confirmación

#### 4. **Funcionalidades Adicionales**
- ✅ **Llamar teléfono:** Integración con `url_launcher` para realizar llamadas
- ✅ **Abrir página web:** Apertura de URLs en navegador externo
- ✅ **Navegación fluida:** GoRouter para rutas declarativas
- ✅ **Modo desarrollo:** Posibilidad de trabajar sin login
- ✅ **Servicio Mock:** Para desarrollo offline (opcional)

#### 5. **Arquitectura del Módulo**
```
lib/
├── config/
│   └── dev_config.dart                    # Configuración de desarrollo
├── models/
│   └── universidad.dart                   # Modelo de datos
├── services/
│   ├── universidad_realtime_service.dart  # Servicio Firebase Realtime DB
│   └── universidad_mock_service.dart      # Servicio Mock (desarrollo)
├── views/
│   └── universidades/
│       ├── universidades_list_view.dart   # Vista de lista
│       └── universidad_form_view.dart     # Formulario CRUD
└── firebase_options.dart                  # Configuración de Firebase
```

### 🔥 Firebase Realtime Database vs Firestore

**¿Por qué Realtime Database?**

Durante el desarrollo se intentó usar Cloud Firestore, pero Google requiere habilitar facturación (billing) incluso para el plan gratuito, lo que implica vincular una tarjeta de crédito/débito. 

**Solución:** Se utilizó **Firebase Realtime Database** que ofrece:
- ✅ **100% GRATIS** - Sin necesidad de tarjeta
- ✅ **Sincronización en tiempo real** - Igual que Firestore
- ✅ **1GB de almacenamiento** - Plan gratuito generoso
- ✅ **10GB de transferencia/mes** - Suficiente para desarrollo
- ✅ **Cumple todos los requisitos del taller**

### 📊 Estructura de Datos en Firebase

```json
{
  "universidades": {
    "-O7XnPqR3JKlMm9nP8qS": {
      "nit": "890.123.456-7",
      "nombre": "UCEVA",
      "direccion": "Cra 27A #48-144, Tuluá - Valle",
      "telefono": "+57 602 2242202",
      "pagina_web": "https://www.uceva.edu.co"
    }
  }
}
```

### 🎨 Interfaz de Usuario

- ✅ **Material Design 3**
- ✅ **Cards con elevación** para cada universidad
- ✅ **ExpansionTile** para detalles expandibles
- ✅ **Iconos descriptivos** para cada acción
- ✅ **Colores temáticos** consistentes
- ✅ **Feedback visual** con SnackBars
- ✅ **Diálogos de confirmación** para acciones críticas
- ✅ **Estados de carga** con CircularProgressIndicator

### Prerrequisitos
```bash
flutter --version  # Flutter SDK 3.9.0 o superior
dart --version     # Dart 3.9.0 o superior
```

### Instalación
```bash
# 1. Clonar el repositorio
git clone https://github.com/camiloMena259/taller2Moviles_2corte.git
cd taller2Moviles_2corte

# 2. Cambiar a la rama del Taller 3
git checkout feature/taller_firebase_universidades

# 3. Instalar dependencias
flutter pub get

# 4. Ejecutar la aplicación
flutter run
```

### Configuración de Firebase (Taller 3)

Si quieres trabajar con Firebase real (recomendado):

```bash
# 1. Instalar Firebase CLI
npm install -g firebase-tools

# 2. Login en Firebase
firebase login

# 3. Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# 4. Configurar Firebase en el proyecto
flutterfire configure
```

**Nota:** Para el Taller 3 se usa **Realtime Database** que no requiere billing/tarjeta.

---

## 🌳 Gestión de Ramas (GitFlow)

### Ramas Principales
- `main` - Producción (versión estable)
- `dev` - Desarrollo (integración de features)

### Ramas de Features
- `feature/taller_jwt` - Taller 2: Autenticación JWT
- `feature/taller_firebase_universidades` - Taller 3: Firebase (ACTUAL)

### Flujo de Trabajo
```bash
# Crear nueva rama feature desde dev
git checkout dev
git pull origin dev
git checkout -b feature/nombre-del-feature

# Trabajar en la rama
git add .
git commit -m "feat: descripción del cambio"
git push origin feature/nombre-del-feature

# Crear Pull Request: feature → dev
```

---

## 📱 Ejecución en Diferentes Plataformas

```bash
# Web (Chrome)
flutter run -d chrome

# Android Emulator
flutter run -d emulator-5554

# iOS Simulator (macOS)
flutter run -d iPhone

# Listar dispositivos disponibles
flutter devices
```

---

## 🧪 Testing y Depuración

```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Analizar código
flutter analyze

# Ver logs en tiempo real
flutter logs

# Hot Reload (mientras la app está corriendo)
# Presiona 'r' en la terminal

# Hot Restart
# Presiona 'R' en la terminal
```

---

## 📖 Documentación Adicional

| Archivo | Descripción |
|---------|-------------|
| [INFORME_TALLER3_FIREBASE.md](./INFORME_TALLER3_FIREBASE.md) | Informe completo del Taller 3 |
| [TALLER3_FIREBASE.md](./TALLER3_FIREBASE.md) | Documentación técnica del Taller 3 |
| [GUIA_FIREBASE_PASO_A_PASO.md](./GUIA_FIREBASE_PASO_A_PASO.md) | Guía de configuración de Firebase |
| [INSTRUCCIONES_FIREBASE.md](./INSTRUCCIONES_FIREBASE.md) | Instrucciones rápidas de setup |

---

## 🎓 Conceptos y Aprendizajes

### Taller 2 (JWT)
- Autenticación y autorización con JWT
- Gestión de estado con Provider
- Almacenamiento seguro en dispositivos móviles
- Consumo de APIs REST
- Manejo de errores HTTP

### Taller 3 (Firebase)
- Integración de Firebase con Flutter
- Firebase Realtime Database (NoSQL)
- Operaciones CRUD en tiempo real
- Streams y programación reactiva
- Validación de formularios
- Integración con funcionalidades del dispositivo (llamadas, URLs)
- Arquitectura limpia y separación de responsabilidades

---

## 🔒 Seguridad

### Datos Sensibles
- 🔐 Tokens JWT encriptados con FlutterSecureStorage
- 🔐 Uso de Keychain (iOS) y Keystore (Android)
- 🔐 Variables de entorno en archivo `.env` (no versionado)

### Datos No Sensibles
- ✅ Información de usuario en SharedPreferences
- ✅ Preferencias de la app
- ✅ Caché de datos públicos

### Firebase Security Rules
```json
{
  "rules": {
    "universidades": {
      ".read": true,
      ".write": true
    }
  }
}
```
**Nota:** En producción, implementar reglas más restrictivas.

---

## 🐛 Solución de Problemas Comunes

### Error: "No Firebase App has been created"
**Solución:**
```bash
flutterfire configure
flutter clean
flutter pub get
flutter run
```

### Error: "MissingPluginException"
**Solución:**
```bash
flutter clean
flutter pub get
# Reiniciar el dispositivo/emulador
flutter run
```

### Error de compilación con imports
**Solución:**
```bash
flutter clean
flutter pub get
# Cerrar y reabrir VS Code
flutter run
```

### Firebase no sincroniza
**Verificar:**
1. Internet está funcionando
2. Firebase Realtime Database está habilitado en Console
3. Reglas de seguridad permiten lectura/escritura
4. `firebase_options.dart` existe y está correcto

---

## 📊 Estado del Proyecto

### Completado ✅
- ✅ Taller 2: Autenticación JWT
- ✅ Taller 3: Firebase Realtime Database
- ✅ Integración con APIs externas
- ✅ Navegación con GoRouter
- ✅ Gestión de estado con Provider
- ✅ Almacenamiento local y seguro
- ✅ CRUD completo de universidades
- ✅ Sincronización en tiempo real

### En Desarrollo 🚧
- 🚧 Tests unitarios
- 🚧 Tests de integración
- 🚧 Optimización de rendimiento

---

## 👨‍💻 Autor

**Juan Camilo Mena**
- Email: juancamilomena2010@gmail.com
- GitHub: [@camiloMena259](https://github.com/camiloMena259)
- Universidad: UCEVA
- Programa: Ingeniería de Sistemas

---

## 📝 Licencia

Este proyecto fue desarrollado con fines educativos como parte del curso de Desarrollo de Aplicaciones Móviles de UCEVA.

---

## 🔗 Enlaces Útiles

### Flutter & Dart
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language](https://dart.dev/)
- [Flutter Packages](https://pub.dev/)

### Firebase
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [Realtime Database Guide](https://firebase.google.com/docs/database)

### Paquetes Utilizados
- [Provider](https://pub.dev/packages/provider)
- [GoRouter](https://pub.dev/packages/go_router)
- [FlutterSecureStorage](https://pub.dev/packages/flutter_secure_storage)
- [URL Launcher](https://pub.dev/packages/url_launcher)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)

### Otros
- [JWT.io](https://jwt.io/) - Info sobre JSON Web Tokens
- [Material Design 3](https://m3.material.io/)

---

## 🙏 Agradecimientos

- UCEVA - Universidad Central del Valle del Cauca
- Profesor del curso de Desarrollo Móvil
- Comunidad de Flutter en español
- Documentación oficial de Flutter y Firebase

---

**Última actualización:** Noviembre 4, 2025  
**Versión:** 2.0.0 - Taller 3 Firebase Realtime Database
**Última actualización:** Noviembre 4, 2025  
**Versión:** 2.0.0 - Taller 3 Firebase Realtime Database
