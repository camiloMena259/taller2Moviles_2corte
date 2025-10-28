import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_user.dart';

enum AuthState { idle, loading, success, error }

class ParkingAuthService extends ChangeNotifier {
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

  /// Registrar un nuevo usuario
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setState(AuthState.loading);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _setState(AuthState.success);
        return {
          'success': true,
          'message': 'Usuario registrado exitosamente',
          'data': data
        };
      } else {
        _setError(data['message'] ?? 'Error al registrar usuario');
        return {
          'success': false,
          'message': data['message'] ?? 'Error al registrar usuario'
        };
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      debugPrint('Error en register: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Login de usuario
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Guardar token de forma segura
        await _secureStorage.write(
          key: 'access_token',
          value: data['access_token'],
        );

        if (data['refresh_token'] != null) {
          await _secureStorage.write(
            key: 'refresh_token',
            value: data['refresh_token'],
          );
        }

        // Guardar datos no sensibles del usuario
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', data['user']['name'] ?? '');
        await prefs.setString('user_email', data['user']['email'] ?? '');
        await prefs.setInt('user_id', data['user']['id'] ?? 0);
        await prefs.setBool('is_logged_in', true);

        // Crear objeto de usuario
        _currentUser = ParkingUser.fromJson(data['user']);

        _setState(AuthState.success);
        return {
          'success': true,
          'message': 'Login exitoso',
          'user': _currentUser
        };
      } else {
        _setError(data['message'] ?? 'Credenciales inválidas');
        return {
          'success': false,
          'message': data['message'] ?? 'Credenciales inválidas'
        };
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      debugPrint('Error en login: $e');
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
