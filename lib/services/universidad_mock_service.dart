import 'dart:async';
import '../models/universidad.dart';

/// Servicio Mock para universidades (sin Firebase)
/// Útil para desarrollo y pruebas sin necesidad de conexión a Firebase
/// Implementado como Singleton para mantener el estado global
class UniversidadMockService {
  // Singleton pattern
  static final UniversidadMockService _instance = UniversidadMockService._internal();
  
  factory UniversidadMockService() {
    return _instance;
  }
  
  UniversidadMockService._internal();
  
  // StreamController para emitir cambios en tiempo real
  final _streamController = StreamController<List<Universidad>>.broadcast();
  
  // Lista en memoria que simula la base de datos
  final List<Universidad> _universidades = [
    Universidad(
      id: '1',
      nit: '890.123.456-7',
      nombre: 'UCEVA',
      direccion: 'Cra 27A #48-144, Tuluá - Valle',
      telefono: '+57 602 2242202',
      paginaWeb: 'https://www.uceva.edu.co',
    ),
    Universidad(
      id: '2',
      nit: '890.987.654-3',
      nombre: 'Universidad del Valle',
      direccion: 'Calle 13 # 100-00, Cali - Valle',
      telefono: '+57 602 3212100',
      paginaWeb: 'https://www.univalle.edu.co',
    ),
    Universidad(
      id: '3',
      nit: '890.111.222-9',
      nombre: 'Universidad de Antioquia',
      direccion: 'Calle 67 # 53-108, Medellín - Antioquia',
      telefono: '+57 604 2195000',
      paginaWeb: 'https://www.udea.edu.co',
    ),
  ];

  // Simular un delay de red
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
  
  // Notificar cambios a los listeners del stream
  void _notifyChanges() {
    _streamController.add(List.from(_universidades));
  }

  /// Obtener todas las universidades (Stream simulado)
  Stream<List<Universidad>> getUniversidadesStream() async* {
    // Emitir el estado actual inmediatamente
    yield List.from(_universidades);
    
    // Escuchar cambios del stream controller
    await for (final universidades in _streamController.stream) {
      yield universidades;
    }
  }

  /// Obtener todas las universidades (Future)
  Future<List<Universidad>> getUniversidades() async {
    await _simulateNetworkDelay();
    return List.from(_universidades);
  }

  /// Obtener una universidad por ID
  Future<Universidad?> getUniversidadById(String id) async {
    await _simulateNetworkDelay();
    try {
      return _universidades.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Crear una nueva universidad
  Future<void> createUniversidad(Universidad universidad) async {
    await _simulateNetworkDelay();
    
    // Generar un ID único
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newUniversidad = Universidad(
      id: newId,
      nit: universidad.nit,
      nombre: universidad.nombre,
      direccion: universidad.direccion,
      telefono: universidad.telefono,
      paginaWeb: universidad.paginaWeb,
    );
    
    _universidades.add(newUniversidad);
    _notifyChanges(); // Notificar cambios
    print('✅ Universidad creada: ${newUniversidad.nombre} (ID: $newId)');
  }

  /// Actualizar una universidad existente
  Future<void> updateUniversidad(Universidad universidad) async {
    await _simulateNetworkDelay();
    
    final index = _universidades.indexWhere((u) => u.id == universidad.id);
    if (index != -1) {
      _universidades[index] = universidad;
      _notifyChanges(); // Notificar cambios
      print('✅ Universidad actualizada: ${universidad.nombre}');
    }
  }

  /// Eliminar una universidad
  Future<void> deleteUniversidad(String id) async {
    await _simulateNetworkDelay();
    final universidad = _universidades.firstWhere((u) => u.id == id);
    _universidades.removeWhere((u) => u.id == id);
    _notifyChanges(); // Notificar cambios
    print('✅ Universidad eliminada: ${universidad.nombre}');
  }

  /// Verificar si existe una universidad con el NIT dado (excluyendo una universidad específica)
  Future<bool> existeUniversidadConNit(String nit, {String? excluyendoId}) async {
    await _simulateNetworkDelay();
    return _universidades.any((u) => u.nit == nit && u.id != excluyendoId);
  }

  /// Limpiar todas las universidades
  Future<void> clearAll() async {
    await _simulateNetworkDelay();
    _universidades.clear();
    _notifyChanges(); // Notificar cambios
  }

  /// Obtener el número de universidades
  int get count => _universidades.length;
  
  /// Cerrar el stream (llamar cuando ya no se necesite el servicio)
  void dispose() {
    _streamController.close();
  }
}
