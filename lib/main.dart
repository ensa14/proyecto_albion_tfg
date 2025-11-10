import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 👇 Importa la pantalla de inicio
import 'screens/sing-in/elegirCuenta.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isWindows) {
    debugPrint(
        "FirebaseAuth está deshabilitado en Windows (no compatible nativamente).");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Albion Helper',
      home: const HomeScreen(), // 👈 ahora inicia en la pantalla de inicio
    );
  }
}
