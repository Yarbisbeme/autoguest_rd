import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/catalogo_provider.dart';
import 'providers/combustible_provider.dart';
import 'providers/foro_provider.dart';
import 'providers/gasto_provider.dart';
import 'providers/goma_provider.dart';
import 'providers/ingreso_provider.dart';
import 'providers/mantenimiento_provider.dart';
import 'providers/noticia_provider.dart';
import 'providers/perfil_provider.dart';
import 'providers/vehiculo_provider.dart';
import 'providers/video_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PerfilProvider()),
        ChangeNotifierProvider(create: (_) => VehiculoProvider()),
        ChangeNotifierProvider(create: (_) => MantenimientoProvider()),
        ChangeNotifierProvider(create: (_) => CombustibleProvider()),
        ChangeNotifierProvider(create: (_) => GastoProvider()),
        ChangeNotifierProvider(create: (_) => IngresoProvider()),
        ChangeNotifierProvider(create: (_) => GomaProvider()),
        ChangeNotifierProvider(create: (_) => NoticiaProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => CatalogoProvider()),
        ChangeNotifierProvider(create: (_) => ForoProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AutoGest RD',
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}