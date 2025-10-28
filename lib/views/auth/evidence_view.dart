import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/parking_auth_service.dart';

class EvidenceView extends StatefulWidget {
  const EvidenceView({super.key});

  @override
  State<EvidenceView> createState() => _EvidenceViewState();
}

class _EvidenceViewState extends State<EvidenceView> {
  Map<String, dynamic>? _storedData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final authService = context.read<ParkingAuthService>();
    await authService.loadUserFromStorage();
    final data = await authService.getStoredData();
    setState(() {
      _storedData = data;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authService = context.read<ParkingAuthService>();
      await authService.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada'),
            backgroundColor: Colors.orange,
          ),
        );
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia de Almacenamiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadStoredData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ParkingAuthService>(
              builder: (context, authService, child) {
                final user = authService.currentUser;
                final sharedPrefs = _storedData?['shared_preferences'] ?? {};
                final secureStorage = _storedData?['secure_storage'] ?? {};

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header con información del usuario
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user?.name ?? sharedPrefs['user_name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? sharedPrefs['user_email'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: secureStorage['has_access_token'] == true
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: secureStorage['has_access_token'] == true
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      secureStorage['has_access_token'] == true
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: secureStorage['has_access_token'] == true
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      secureStorage['has_access_token'] == true
                                          ? 'Sesión Activa'
                                          : 'Sin Sesión',
                                      style: TextStyle(
                                        color: secureStorage['has_access_token'] == true
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Sección de SharedPreferences
                      const Text(
                        'SharedPreferences (Datos NO sensibles)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDataRow(
                                'Nombre',
                                sharedPrefs['user_name']?.toString() ?? 'N/A',
                                Icons.person,
                              ),
                              const Divider(),
                              _buildDataRow(
                                'Email',
                                sharedPrefs['user_email']?.toString() ?? 'N/A',
                                Icons.email,
                              ),
                              const Divider(),
                              _buildDataRow(
                                'ID de Usuario',
                                sharedPrefs['user_id']?.toString() ?? 'N/A',
                                Icons.badge,
                              ),
                              const Divider(),
                              _buildDataRow(
                                'Sesión Activa',
                                sharedPrefs['is_logged_in'] == true ? 'Sí' : 'No',
                                Icons.login,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Sección de SecureStorage
                      const Text(
                        'FlutterSecureStorage (Datos SENSIBLES)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.amber.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.security, color: Colors.amber.shade900),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Los tokens se almacenan de forma segura y encriptada',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              _buildDataRow(
                                'Access Token',
                                secureStorage['has_access_token'] == true
                                    ? 'Presente ✓'
                                    : 'Ausente ✗',
                                Icons.key,
                              ),
                              const Divider(),
                              _buildDataRow(
                                'Refresh Token',
                                secureStorage['has_refresh_token'] == true
                                    ? 'Presente ✓'
                                    : 'Ausente ✗',
                                Icons.refresh,
                              ),
                              const Divider(),
                              _buildDataRow(
                                'Longitud del Token',
                                '${secureStorage['access_token_length']} caracteres',
                                Icons.text_fields,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Información adicional
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info, color: Colors.blue.shade700),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Información del Taller',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text('• API: parking.visiontic.com.co'),
                              const Text('• Autenticación: JWT'),
                              const Text('• SharedPreferences: datos no sensibles'),
                              const Text('• SecureStorage: tokens encriptados'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botón de cerrar sesión
                      ElevatedButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar Sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
