import 'package:flutter/material.dart';
import '../asset/colores/colores.dart';
import '../asset/rutas/rutas.dart';
import '../screens/index.dart';  // 👈 IMPORTANTE

class HeaderAlbion extends StatelessWidget {
  final Widget? rightContent;
  final EdgeInsetsGeometry? padding;

  const HeaderAlbion({
    super.key,
    this.rightContent,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.headerFondo,
        border: Border(
          bottom: BorderSide(color: AppColors.headerBorde, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerSombra,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ---------- LOGO + TEXTO (CLICKABLE) ----------
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrincipalPantalla(),
                ),
              );
            },
            child: Row(
              children: [
                Image.asset(
                  RutasImagenes.logo,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.shield, size: 32),
                ),
                const SizedBox(width: 8),
                Text(
                  'ALBION HELPER',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.headerTexto,
                      ),
                ),
              ],
            ),
          ),

          // ---------- CONTENIDO A LA DERECHA ----------
          if (rightContent != null) rightContent!,
        ],
      ),
    );
  }
}
