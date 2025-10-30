import 'package:go_router/go_router.dart';
import 'package:registro_clases/views/cdt/cdt_list_view.dart';
import 'package:registro_clases/views/ciclo_vida/ciclo_vida_screen.dart';
import 'package:registro_clases/views/establecimientos/establecimiento_create_view.dart';
import 'package:registro_clases/views/establecimientos/establecimiento_edit_view.dart';
import 'package:registro_clases/views/establecimientos/establecimientos_list_view.dart';
import 'package:registro_clases/views/home/home_screen.dart';
import 'package:registro_clases/views/paso_parametros/detalle_screen.dart';
import 'package:registro_clases/views/paso_parametros/paso_parametros_screen.dart';

import '../views/auth/login_page.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/user_info_view.dart';
import '../views/future/future_view.dart';
import '../views/isolate/isolate_view.dart';
import '../views/pokemons/pokemon_detail_view.dart';
import '../views/pokemons/pokemon_list_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login', // ✅ INICIO en Login
  routes: [
    // ✅ Ruta principal - HomeScreen original (Dashboard)
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // ✅ Ruta de Login como pantalla inicial
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    // Ruta de Registro
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),
    // ✅ Ruta para ver información detallada del usuario (desde el drawer)
    GoRoute(
      path: '/user-info',
      builder: (context, state) => const UserInfoView(),
    ),
    // Rutas para el paso de parámetros
    GoRoute(
      path: '/paso_parametros',
      builder: (context, state) => const PasoParametrosScreen(),
    ),

    // !Ruta para el detalle con parámetros
    GoRoute(
      path:
          '/detalle/:parametro/:metodo', //la ruta recibe dos parametros los " : " indican que son parametros
      builder: (context, state) {
        //*se capturan los parametros recibidos
        // declarando las variables parametro y metodo
        // es final porque no se van a modificar
        final parametro = state.pathParameters['parametro']!;
        final metodo = state.pathParameters['metodo']!;
        return DetalleScreen(parametro: parametro, metodoNavegacion: metodo);
      },
    ),
    //!Ruta para el ciclo de vida
    GoRoute(
      path: '/ciclo_vida',
      name: 'ciclo_vida',
      builder: (context, state) => const CicloVidaScreen(),
    ),
    //!Ruta para FUTURE
    GoRoute(
      path: '/future',
      name: 'future',
      builder: (context, state) => const FutureView(),
    ),
    //!Ruta para ISOLATE
    GoRoute(
      path: '/isolate',
      name: 'isolate',
      builder: (context, state) => const IsolateView(),
    ),
    //!Ruta para listaado de pokemones
    GoRoute(
      path: '/pokemons',
      name: 'pokemons',
      builder: (context, state) => const PokemonListView(),
    ),

    //!Ruta para detalle de pokemones
    GoRoute(
      path: '/pokemon/:name', // se recibe el nombre del pokemon como parametro
      name: 'pokemon_detail',
      builder: (context, state) {
        final name =
            state.pathParameters['name']!; // se captura el nombre del pokemon.
        return PokemonDetailView(name: name);
      },
    ),
    //!Ruta cdts
    GoRoute(
      path: '/cdts',
      name: 'cdts',
      builder: (context, state) => const CDTListView(),
    ),

    //!Ruta para la lista de establecimientos
    //!Rutas para el manejo de Establecimientos
    GoRoute(
      path: '/establecimientos',
      name: 'establecimientos',
      builder: (context, state) => const EstablecimientosListView(),
    ),
    //!Ruta para editar de un establecimiento
    GoRoute(
      path: '/establecimientos/edit/:id',
      builder: (context, state) {
        //*se captura el id del establecimiento
        final id = int.parse(state.pathParameters['id']!);
        return EstablecimientoEditView(id: id);
      },
    ),
    //!Ruta para crear un nuevo establecimiento
    GoRoute(
      path: '/establecimientos/create',
      builder: (context, state) => const EstablecimientoCreateView(),
    ),
    //!Ruta para login (página anterior del taller 1)
    GoRoute(
      path: '/login_old',
      builder: (context, state) => const LoginPage(),
    ),
  ],
);
