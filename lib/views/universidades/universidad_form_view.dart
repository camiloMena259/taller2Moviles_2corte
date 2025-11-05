import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:registro_clases/config/dev_config.dart';
import 'package:registro_clases/models/universidad.dart';
import 'package:registro_clases/services/universidad_realtime_service.dart';
import 'package:registro_clases/services/universidad_mock_service.dart';
import 'package:registro_clases/widgets/base_view.dart';

class UniversidadFormView extends StatefulWidget {
  final String? universidadId; // null = crear, con id = editar

  const UniversidadFormView({super.key, this.universidadId});

  @override
  State<UniversidadFormView> createState() => _UniversidadFormViewState();
}

class _UniversidadFormViewState extends State<UniversidadFormView> {
  final _formKey = GlobalKey<FormState>();
  // Usar Mock o Firebase Realtime Database según configuración
  final dynamic _service = DevConfig.useMockFirebase 
      ? UniversidadMockService() 
      : UniversidadRealtimeService();

  // Controladores de los campos de texto
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _paginaWebController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.universidadId != null;
    if (_isEditing) {
      _cargarUniversidad();
    }
  }

  // Cargar datos de la universidad si estamos editando
  Future<void> _cargarUniversidad() async {
    setState(() => _isLoading = true);
    try {
      final universidad =
          await _service.getUniversidadById(widget.universidadId!);
      if (universidad != null) {
        setState(() {
          _nitController.text = universidad.nit;
          _nombreController.text = universidad.nombre;
          _direccionController.text = universidad.direccion;
          _telefonoController.text = universidad.telefono;
          _paginaWebController.text = universidad.paginaWeb;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar universidad: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nitController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _paginaWebController.dispose();
    super.dispose();
  }

  // Validador de URL
  String? _validarUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlPattern.hasMatch(value)) {
      return 'Ingrese una URL válida (http:// o https://)';
    }
    return null;
  }

  // Validador de campo requerido
  String? _validarRequerido(String? value, String nombreCampo) {
    if (value == null || value.trim().isEmpty) {
      return '$nombreCampo es requerido';
    }
    return null;
  }

  // Guardar o actualizar universidad
  Future<void> _guardarUniversidad() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verificar si el NIT ya existe (solo al crear o si cambió el NIT)
      final nitExiste = await _service.existeUniversidadConNit(
        _nitController.text.trim(),
        excluyendoId: _isEditing ? widget.universidadId : null,
      );

      if (nitExiste) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya existe una universidad con ese NIT'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final universidad = Universidad(
        id: _isEditing ? widget.universidadId : null,
        nit: _nitController.text.trim(),
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        telefono: _telefonoController.text.trim(),
        paginaWeb: _paginaWebController.text.trim(),
      );

      if (_isEditing) {
        await _service.updateUniversidad(universidad);
      } else {
        await _service.createUniversidad(universidad);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Universidad actualizada correctamente'
                  : 'Universidad creada correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Regresar a la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: _isEditing ? 'Editar Universidad' : 'Nueva Universidad',
      body: _isLoading && _isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icono y título
                    Icon(
                      Icons.school,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isEditing
                          ? 'Actualizar información de la universidad'
                          : 'Ingrese los datos de la nueva universidad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo NIT
                    TextFormField(
                      controller: _nitController,
                      decoration: InputDecoration(
                        labelText: 'NIT',
                        hintText: 'Ej: 890.123.456-7',
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => _validarRequerido(value, 'El NIT'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Campo Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ej: Universidad del Valle',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          _validarRequerido(value, 'El nombre'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Campo Dirección
                    TextFormField(
                      controller: _direccionController,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        hintText: 'Ej: Cra 27A #48-144, Tuluá - Valle',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          _validarRequerido(value, 'La dirección'),
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Campo Teléfono
                    TextFormField(
                      controller: _telefonoController,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        hintText: 'Ej: +57 602 2242202',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          _validarRequerido(value, 'El teléfono'),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Campo Página Web
                    TextFormField(
                      controller: _paginaWebController,
                      decoration: InputDecoration(
                        labelText: 'Página Web',
                        hintText: 'Ej: https://www.uceva.edu.co',
                        prefixIcon: const Icon(Icons.language),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: _validarUrl,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 32),

                    // Botón Guardar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _guardarUniversidad,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isEditing ? 'Actualizar' : 'Guardar',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Botón Cancelar
                    OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
