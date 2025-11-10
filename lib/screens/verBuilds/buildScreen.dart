import 'package:flutter/material.dart';
import '../../asset/colores/colores.dart';
import '../../widget/header_albion.dart';

class BuildsScreen extends StatelessWidget {
  const BuildsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== CABECERA REUTILIZABLE =====
              HeaderAlbion(
                rightContent: Row(
                  children: [
                    _buildDropdown('PVE'),
                    const SizedBox(width: 8),
                    _buildDropdown('PVP'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar build...',
                          isDense: true,
                          prefixIcon:
                              const Icon(Icons.search, size: 18, color: AppColors.iconoInput),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== SECCIÓN PVP =====
              Text(
                'PVP (solo)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.headerTexto,
                    ),
              ),
              Text(
                'Subheading',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 12),

              // Contenedor dinámico para las builds PVP
              Column(
                children: [
                  // Aquí se insertarán dinámicamente las cards PVP
                ],
              ),

              const SizedBox(height: 30),

              // ===== SECCIÓN PVE =====
              Text(
                'PVE',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.headerTexto,
                    ),
              ),
              Text(
                'Subheading',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 12),

              // Contenedor dinámico para las builds PVE
              Column(
                children: [
                  // Aquí se insertarán dinámicamente las cards PVE
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.botonSecundario,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.headerBorde),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.headerTexto),
          ),
          const Icon(Icons.arrow_drop_down, color: AppColors.iconoInput),
        ],
      ),
    );
  }
}
