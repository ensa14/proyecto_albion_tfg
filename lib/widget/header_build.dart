import 'package:flutter/material.dart';
import '../asset/colores/colores.dart';
import '../asset/rutas/rutas.dart';
import '../screens/index.dart';

class HeaderSimpleAlbion extends StatelessWidget {
  final Widget? rightContent;

  const HeaderSimpleAlbion({super.key, this.rightContent});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 650;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.headerFondo,
        border: Border(bottom: BorderSide(color: AppColors.headerBorde)),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerSombra,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: isMobile
            ? _buildMobileHeader(context)
            : _buildDesktopHeader(context),
      ),
    );
  }

  // ======================================================
  //                      DESKTOP
  // ======================================================
  Widget _buildDesktopHeader(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PrincipalPantalla()),
              );
            },
            child: Row(
              children: [
                Image.asset(
                  RutasImagenes.logo,
                  height: 45,
                ),
                const SizedBox(width: 10),
                Text(
                  "ALBION HELPER",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headerTexto,
                  ),
                ),
              ],
            ),
          ),

          // Contenido derecho (filtros, buscador…)
          if (rightContent != null)
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: rightContent!,
              ),
            ),
        ],
      ),
    );
  }

  // ======================================================
  //                       MÓVIL
  // ======================================================
  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PrincipalPantalla()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                RutasImagenes.logo,
                height: 32,
              ),
              const SizedBox(width: 6),
              Text(
                "ALBION HELPER",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headerTexto,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        if (rightContent != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: rightContent!,
          ),
      ],
    );
  }
}
