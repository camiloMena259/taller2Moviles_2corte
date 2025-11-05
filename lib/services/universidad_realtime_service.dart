import 'package:firebase_database/firebase_database.dart';
import 'package:registro_clases/models/universidad.dart';

/// Servicio para gestionar universidades en Firebase Realtime Database
/// 100% GRATIS - No requiere billing/tarjeta
class UniversidadRealtimeService {
  // Instancia de Firebase Realtime Database
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  // Referencia a la colección de universidades
  DatabaseReference get _universidadesRef => _database.child('universidades');

  /// Obtener todas las universidades en tiempo real (Stream)
  /// Retorna un Stream que se actualiza automáticamente cuando hay cambios
  Stream<List<Universidad>> getUniversidadesStream() {
    return _universidadesRef.onValue.map((event) {
      final List<Universidad> universidades = [];
      
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          try {
            final universidadData = Map<String, dynamic>.from(value as Map);
            universidadData['id'] = key; // Agregar el ID del documento
            universidades.add(Universidad.fromMap(universidadData));
          } catch (e) {
            print('Error parseando universidad $key: $e');
          }
        });
      }
      
      return universidades;
    });
  }

  /// Crear una nueva universidad
  /// Retorna el ID del documento creado
  Future<String> createUniversidad(Universidad universidad) async {
    try {
      // Crear una nueva referencia con ID automático
      final newRef = _universidadesRef.push();
      
      // Guardar los datos
      await newRef.set(universidad.toMap());
      
      print('✅ Universidad creada con ID: ${newRef.key}');
      return newRef.key!;
    } catch (e) {
      print('❌ Error al crear universidad: $e');
      throw Exception('Error al crear universidad: $e');
    }
  }

  /// Obtener una universidad específica por ID
  Future<Universidad?> getUniversidadById(String id) async {
    try {
      final snapshot = await _universidadesRef.child(id).get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data['id'] = id;
        return Universidad.fromMap(data);
      }
      
      return null;
    } catch (e) {
      print('❌ Error al obtener universidad: $e');
      throw Exception('Error al obtener universidad: $e');
    }
  }

  /// Actualizar una universidad existente
  Future<void> updateUniversidad(Universidad universidad) async {
    try {
      if (universidad.id == null) {
        throw Exception('El ID de la universidad no puede ser nulo');
      }
      
      await _universidadesRef.child(universidad.id!).update(universidad.toMap());
      print('✅ Universidad actualizada: ${universidad.nombre}');
    } catch (e) {
      print('❌ Error al actualizar universidad: $e');
      throw Exception('Error al actualizar universidad: $e');
    }
  }

  /// Eliminar una universidad
  Future<void> deleteUniversidad(String id) async {
    try {
      await _universidadesRef.child(id).remove();
      print('✅ Universidad eliminada con ID: $id');
    } catch (e) {
      print('❌ Error al eliminar universidad: $e');
      throw Exception('Error al eliminar universidad: $e');
    }
  }

  /// Verificar si existe una universidad con el mismo NIT
  Future<bool> existeUniversidadConNit(String nit, {String? excluyendoId}) async {
    try {
      final snapshot = await _universidadesRef
          .orderByChild('nit')
          .equalTo(nit)
          .get();
      
      if (!snapshot.exists) {
        return false;
      }
      
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      if (excluyendoId != null) {
        // Si estamos editando, excluir el documento actual
        return data.keys.any((key) => key != excluyendoId);
      }
      
      return data.isNotEmpty;
    } catch (e) {
      print('❌ Error al verificar NIT: $e');
      throw Exception('Error al verificar NIT: $e');
    }
  }
}
