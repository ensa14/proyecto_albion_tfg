import 'package:flutter/material.dart';
import '../../widget/custom_button.dart';
import 'inicio_sesion_screen.dart';
import 'registro_screen.dart';
import '../../../asset/colores/colores.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenido centrado
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                  text: 'Crear Cuenta',
                  backgroundColor: AppColors.botonPrimario,
                  textColor: AppColors.botonPrimarioTexto,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistroPantalla(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Iniciar Sesión',
                  backgroundColor: AppColors.botonSecundario,
                  textColor: AppColors.botonSecundarioTexto,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPantalla(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
