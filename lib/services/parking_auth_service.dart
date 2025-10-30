import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_user.dart';

enum AuthState { idle, loading, success, error }

class ParkingAuthService extends ChangeNotifier {
  // API de parking.visiontic.com.co - API real del taller
  final String baseUrl = 'https://parking.visiontic.com.co/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthState _state = AuthState.idle;
  String _errorMessage = '';
  ParkingUser? _currentUser;

  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  ParkingUser? get currentUser => _currentUser;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  /// Registrar un nuevo usuario usando POST /api/users
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setState(AuthState.loading);

    try {
      debugPrint('🔵 Intentando registro en: $baseUrl/users');
      debugPrint('📧 Email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Extraer datos del usuario creado
        final userData = data['data'] ?? data['user'] ?? data;
        final userId = userData['id'] ?? 0;
        final userName = userData['name'] ?? name;
        final userEmail = userData['email'] ?? email;
        
        // Si la API devuelve token en el registro, guardarlo
        if (data['token'] != null) {
          await _secureStorage.write(key: 'access_token', value: data['token']);
        }
        
        // Guardar datos de usuario en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', userName);
        await prefs.setString('user_email', userEmail);
        await prefs.setInt('user_id', userId);
        await prefs.setBool('is_logged_in', false); // Aún no ha iniciado sesión
        
        _setState(AuthState.success);
        debugPrint('✅ Registro exitoso - User ID: $userId');
        return {
          'success': true,
          'message': 'Usuario registrado exitosamente',
          'data': userData
        };
      } else {
        // Manejo detallado de errores
        final data = jsonDecode(response.body);
        String errorMsg = 'Error al registrar usuario';
        
        if (response.statusCode == 422) {
          // Error de validación
          if (data['errors'] != null) {
            final errors = data['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.map((e) => e.toString()));
              }
            });
            errorMsg = errorMessages.join('\n');
          } else {
            errorMsg = data['message'] ?? 'Datos inválidos';
          }
        } else if (response.statusCode == 409) {
          errorMsg = 'El email ya está registrado. Intenta con otro email.';
        } else if (response.statusCode == 400) {
          errorMsg = data['message'] ?? 'Solicitud incorrecta';
        } else {
          errorMsg = data['message'] ?? data['error'] ?? 'Error al registrar usuario';
        }
        
        _setError(errorMsg);
        debugPrint('❌ Error de registro: $errorMsg');
        return {
          'success': false,
          'message': errorMsg
        };
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      debugPrint('❌ Error en register: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Login de usuario usando POST /api/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      debugPrint('🔵 Intentando login en: $baseUrl/login');
      debugPrint('📧 Email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extraer token (puede venir como 'token', 'access_token', etc.)
        final token = data['token'] ?? data['access_token'] ?? '';
        final refreshToken = data['refresh_token'] ?? '';
        
        if (token.isEmpty) {
          _setError('No se recibió token de autenticación');
          return {
            'success': false,
            'message': 'No se recibió token de autenticación'
          };
        }
        
        // Guardar tokens de forma segura
        await _secureStorage.write(key: 'access_token', value: token);
        if (refreshToken.isNotEmpty) {
          await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        }

        // Extraer datos del usuario
        final userData = data['user'] ?? data['data'] ?? {};
        final userName = userData['name'] ?? email.split('@')[0];
        final userEmail = userData['email'] ?? email;
        final userId = userData['id'] ?? 0;
        
        // Guardar datos no sensibles
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', userName);
        await prefs.setString('user_email', userEmail);
        await prefs.setInt('user_id', userId);
        await prefs.setBool('is_logged_in', true);

        // Crear objeto de usuario
        _currentUser = ParkingUser(
          id: userId,
          name: userName,
          email: userEmail,
        );

        _setState(AuthState.success);
        debugPrint('✅ Login exitoso - Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
        return {
          'success': true,
          'message': 'Login exitoso',
          'user': _currentUser
        };
      } else {
        // Manejo detallado de errores
        final data = jsonDecode(response.body);
        String errorMsg = 'Error al iniciar sesión';
        
        if (response.statusCode == 401) {
          errorMsg = 'Credenciales incorrectas. Verifica tu email y contraseña.';
        } else if (response.statusCode == 422) {
          // Error de validación
          if (data['errors'] != null) {
            final errors = data['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.map((e) => e.toString()));
              }
            });
            errorMsg = errorMessages.join('\n');
          } else {
            errorMsg = data['message'] ?? 'Datos inválidos';
          }
        } else if (response.statusCode == 404) {
          errorMsg = 'Usuario no encontrado.';
        } else if (response.statusCode == 403) {
          errorMsg = 'Cuenta no verificada o bloqueada.';
        } else {
          errorMsg = data['message'] ?? data['error'] ?? 'Error al iniciar sesión';
        }
        
        _setError(errorMsg);
        debugPrint('❌ Error de login: $errorMsg');
        return {
          'success': false,
          'message': errorMsg
        };
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      debugPrint('❌ Error en login: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Verificar si hay sesión activa
  Future<bool> hasActiveSession() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      return token != null && isLoggedIn;
    } catch (e) {
      debugPrint('Error verificando sesión: $e');
      return false;
    }
  }

  /// Cargar usuario desde almacenamiento local
  Future<void> loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final id = prefs.getInt('user_id');

      if (name != null && email != null && id != null) {
        _currentUser = ParkingUser(
          id: id,
          name: name,
          email: email,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error cargando usuario: $e');
    }
  }

  /// Obtener token almacenado
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// Cerrar sesión
  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      // Eliminar tokens
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');

      // Eliminar datos de usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.setBool('is_logged_in', false);

      _currentUser = null;
      _setState(AuthState.idle);
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
      debugPrint('Error en logout: $e');
    }
  }

  /// Obtener datos almacenados localmente (para evidencia)
  Future<Map<String, dynamic>> getStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await _secureStorage.read(key: 'access_token');
      final refreshToken = await _secureStorage.read(key: 'refresh_token');

      return {
        'shared_preferences': {
          'user_name': prefs.getString('user_name'),
          'user_email': prefs.getString('user_email'),
          'user_id': prefs.getInt('user_id'),
          'is_logged_in': prefs.getBool('is_logged_in'),
        },
        'secure_storage': {
          'has_access_token': token != null,
          'has_refresh_token': refreshToken != null,
          'access_token_length': token?.length ?? 0,
        }
      };
    } catch (e) {
      debugPrint('Error obteniendo datos almacenados: $e');
      return {};
    }
  }
}
