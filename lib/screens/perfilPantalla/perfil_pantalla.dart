import 'package:flutter/material.dart';
import '../index.dart'; // Para cerrar sesión y volver al login

class PerfilPantalla extends StatelessWidget {
  const PerfilPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ====== FOTO DE PERFIL ======
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFFEDE7F6),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 40),

              // ====== BOTÓN: CAMBIAR FOTO ======
              SizedBox(
                width: 300,
                child: Material(
                  color: const Color(0xFFD6D6D6),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función para cambiar la foto de perfil'),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Cambiar Foto de Perfil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ====== BOTÓN: CERRAR SESIÓN ======
              SizedBox(
                width: 300,
                child: Material(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      // Cierra sesión y vuelve al Login
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const PrincipalPantalla()),
                        (route) => false,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
