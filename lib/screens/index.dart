import 'package:flutter/material.dart';
import '../screens/perfilPantalla/perfil_pantalla.dart';
import '../screens/verBuilds/buildScreen.dart';
import '../screens/verBuilds/crearBuild.dart'; 
import '../../asset/colores/colores.dart';
import '../widget/header_albion.dart';

class PrincipalPantalla extends StatelessWidget {
  const PrincipalPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final buscarCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      body: SafeArea(
        child: Stack(
          children: [
            // ===== CONTENIDO PRINCIPAL =====
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 👇 BOTÓN ACTUALIZADO
                    _BloqueAccion(
                      titulo: 'Crear Build',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ItemsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _BloqueAccion(titulo: 'Historial de Muertes', onTap: () {}),
                    const SizedBox(height: 12),
                    _BloqueAccion(
                      titulo: 'Ver Mis Builds',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BuildsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            // ===== CABECERA REUTILIZABLE =====
            HeaderAlbion(
              rightContent: Row(
                children: [
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: buscarCtrl,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Buscar...',
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.iconoInput,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Mi perfil',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PerfilPantalla(),
                        ),
                      );
                    },
                    icon: const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.botonSecundario,
                      child: Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.botonSecundarioTexto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== BLOQUE REUTILIZABLE DE OPCIONES =====
class _BloqueAccion extends StatelessWidget {
  final String titulo;
  final VoidCallback onTap;

  const _BloqueAccion({required this.titulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bloqueFondo,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bloqueIcono,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.add,
                  color: AppColors.bloqueIconoTexto,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
