import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:registro_clases/routes/app_router.dart';
import 'package:registro_clases/services/parking_auth_service.dart';
import 'themes/app_theme.dart'; // Importar el tema

void main() async {
  // Asegurarse de que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Optimizar la carga del .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
  // Inicializar dotenv para cargar las variables de entorno
  // await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // build es un metodo que se ejecuta cada vez que se necesita redibujar la pantalla
    //go_router para navegacion
    return ChangeNotifierProvider(
      create: (_) => ParkingAuthService(),
      child: MaterialApp.router(
        theme:
            AppTheme.lightTheme, //thema personalizado y permamente en toda la app
        title:
            'Flutter - UCEVA', // Usa el tema personalizado, no se muestra el tema por defecto. esto se visualiza en toda la app
        routerConfig: appRouter, // Usa el router configurado
      ),
    );
  }
}
