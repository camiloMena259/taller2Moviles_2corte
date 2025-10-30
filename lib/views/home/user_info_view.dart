import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/parking_auth_service.dart';

/// Vista para mostrar la información almacenada del usuario
/// Muestra datos de SharedPreferences (no sensibles) y SecureStorage (sensibles)
class UserInfoView extends StatefulWidget {
  const UserInfoView({super.key});

  @override
  State<UserInfoView> createState() => _UserInfoViewState();
}

class _UserInfoViewState extends State<UserInfoView> {
  Map<String, dynamic>? _storedData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final authService = Provider.of<ParkingAuthService>(context, listen: false);
    final data = await authService.getStoredData();
    setState(() {
      _storedData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del Usuario'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => context.go('/'), // ✅ Volver al HomeScreen
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar datos',
            onPressed: () {
              setState(() => _isLoading = true);
              _loadStoredData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final sharedPrefsData = _storedData?['shared_preferences'] ?? {};
    final secureStorageData = _storedData?['secure_storage'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.person, size: 48, color: Colors.blue[700]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Usuario',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'API: parking.visiontic.com.co',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue[700],
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

          // Datos de SharedPreferences
          _buildSectionTitle(context, 'Datos No Sensibles', Icons.storage, Colors.green),
          const SizedBox(height: 8),
          _buildInfoCard(
            context,
            'SharedPreferences',
            'Almacenamiento en texto plano (local)',
            sharedPrefsData,
            Colors.green[50]!,
          ),
          const SizedBox(height: 24),

          // Datos de SecureStorage
          _buildSectionTitle(context, 'Datos Sensibles', Icons.lock, Colors.orange),
          const SizedBox(height: 8),
          _buildInfoCard(
            context,
            'FlutterSecureStorage',
            'Almacenamiento encriptado (Keychain/Keystore)',
            secureStorageData,
            Colors.orange[50]!,
          ),
          const SizedBox(height: 24),

          // Explicación
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        '¿Por qué dos tipos de almacenamiento?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildExplanationRow(
                    Icons.storage,
                    'SharedPreferences',
                    'Para datos no críticos (nombre, email, ID)',
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildExplanationRow(
                    Icons.lock,
                    'SecureStorage',
                    'Para datos críticos (tokens JWT)',
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, Color? color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String subtitle,
    Map<String, dynamic> data,
    Color backgroundColor,
  ) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const Divider(),
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No hay datos almacenados'),
              )
            else
              ...data.entries.map((entry) {
                String displayValue = entry.value?.toString() ?? 'null';
                
                // Si es un token, mostrar solo una parte
                if (entry.key.contains('token') && displayValue.length > 30) {
                  displayValue = '${displayValue.substring(0, 30)}... (${displayValue.length} caracteres)';
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          displayValue,
                          style: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationRow(IconData icon, String title, String description, Color? color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
