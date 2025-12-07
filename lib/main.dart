import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/auth_provider.dart';

// PANTALLAS
import 'screens/sing-in/elegirCuenta.dart';
import 'screens/verBuilds/agregarHabilidades.dart';
import 'screens/verBuilds/build_stast.dart'; // <-- AGREGA ESTA IMPORTACIÓN

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isWindows) {
    debugPrint("FirebaseAuth está deshabilitado en Windows (no compatible nativamente).");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Albion Helper',

      routes: {
        '/agregarHabilidades': (context) => const AgregarHabilidadesScreen(),

    
        '/buildStats': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

          return BuildStastScreen(
            equipped: args['equipped'],
            skills: args['skills'],
          );
        },
      },

      home: const HomeScreen(),
    );
  }
}
