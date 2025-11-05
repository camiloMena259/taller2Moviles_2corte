import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:registro_clases/config/dev_config.dart';
import 'package:registro_clases/models/universidad.dart';
import 'package:registro_clases/services/universidad_realtime_service.dart';
import 'package:registro_clases/services/universidad_mock_service.dart';
import 'package:registro_clases/widgets/base_view.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversidadesListView extends StatefulWidget {
  const UniversidadesListView({super.key});

  @override
  State<UniversidadesListView> createState() => _UniversidadesListViewState();
}

class _UniversidadesListViewState extends State<UniversidadesListView> {
  // Usar Mock o Firebase Realtime Database según configuración
  final dynamic _service = DevConfig.useMockFirebase 
      ? UniversidadMockService() 
      : UniversidadRealtimeService();

  // Método para abrir URL en el navegador
  Future<void> _abrirPaginaWeb(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se puede abrir la URL: $url')),
        );
      }
    }
  }

  // Método para hacer una llamada telefónica
  Future<void> _llamarTelefono(String telefono) async {
    final Uri uri = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se puede realizar la llamada: $telefono')),
        );
      }
    }
  }

  // Diálogo de confirmación para eliminar
  Future<void> _confirmarEliminacion(Universidad universidad) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Está seguro de eliminar la universidad "${universidad.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && universidad.id != null) {
      try {
        await _service.deleteUniversidad(universidad.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Universidad eliminada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Universidades ${DevConfig.useMockFirebase ? "(Mock)" : "(Realtime DB)"}',
      body: Column(
        children: [
          // Banner de modo desarrollo
          if (DevConfig.useMockFirebase)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              color: Colors.orange.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Modo Mock - Los datos se guardan en memoria',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              color: Colors.green.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_done, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '✅ Conectado a Firebase Realtime Database (GRATIS)',
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // Botón para crear nueva universidad
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/universidades/create');
                },
                icon: const Icon(Icons.add),
                label: const Text('Nueva Universidad'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          // Lista de universidades en tiempo real
          Expanded(
            child: StreamBuilder<List<Universidad>>(
              stream: _service.getUniversidadesStream(),
              builder: (context, snapshot) {
                // Estado de carga
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar datos:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                // Sin datos
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined,
                            size: 80,
                            color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay universidades registradas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Presiona el botón "Nueva Universidad" para agregar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Mostrar lista de universidades
                final universidades = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: universidades.length,
                  itemBuilder: (context, index) {
                    final universidad = universidades[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            universidad.nombre[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          universidad.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'NIT: ${universidad.nit}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  Icons.location_on,
                                  'Dirección',
                                  universidad.direccion,
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () => _llamarTelefono(universidad.telefono),
                                  child: _buildInfoRow(
                                    Icons.phone,
                                    'Teléfono',
                                    universidad.telefono,
                                    isClickable: true,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () => _abrirPaginaWeb(universidad.paginaWeb),
                                  child: _buildInfoRow(
                                    Icons.language,
                                    'Página Web',
                                    universidad.paginaWeb,
                                    isClickable: true,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        context.push(
                                          '/universidades/edit/${universidad.id}',
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Editar'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _confirmarEliminacion(universidad),
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Eliminar'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isClickable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isClickable
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black87,
                  decoration:
                      isClickable ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
