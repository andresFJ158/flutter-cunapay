import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cunapay_flutter/core/providers/auth_provider.dart';
import 'package:cunapay_flutter/core/providers/theme_provider.dart';
import 'package:cunapay_flutter/core/routes/app_router.dart';
import 'package:cunapay_flutter/core/theme/app_theme.dart';

void main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  // Intenta cargar .env.development primero, luego .env como fallback
  try {
    await dotenv.load(fileName: '.env.development');
  } catch (e) {
    // Si no existe .env.development, intenta cargar .env
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // Si tampoco existe .env, continuar sin variables de entorno
      // Se usará el valor por defecto en ApiConfig
    }
  }
  
  runApp(const CunaPayApp());
}

class CunaPayApp extends StatelessWidget {
  const CunaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final themeProvider = ThemeProvider();
            // Iniciar el listener del sensor de luz ambiente
            themeProvider.startListeningToAmbientLight();
            return themeProvider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'CuñaPay',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'), // Español
              Locale('en', 'US'), // Inglés
            ],
            locale: const Locale('es', 'ES'), // Idioma por defecto
          );
        },
      ),
    );
  }
}

