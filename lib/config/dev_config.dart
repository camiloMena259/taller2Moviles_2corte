/// Configuración para modo desarrollo
/// Permite trabajar en funcionalidades sin necesidad de autenticación
class DevConfig {
  // 🚀 Cambiar a true para activar el modo desarrollo (sin login)
  static const bool isDevelopmentMode = true;
  
  // 🔥 Firebase: false = usar Firebase Realtime Database (GRATIS, sin billing)
  static const bool useMockFirebase = false; // ✅ Usar Firebase Realtime Database
  
  // Usuario de desarrollo por defecto
  static const String devUserName = 'Usuario de Desarrollo';
  static const String devUserEmail = 'dev@uceva.edu.co';
  static const int devUserId = 999;
  
  // Token ficticio para pruebas
  static const String devToken = 'dev_token_12345';
}
