import 'package:flutter/material.dart';
import '../asset/colores/colores.dart';
import '../asset/rutas/rutas.dart';
import '../screens/index.dart';

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
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 650;

    return Container(
      width: double.infinity,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
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

      child: isMobile
          ? _buildMobileHeader(context)
          : _buildDesktopHeader(context),
    );
  }

  // ============================================================
  //                        DESKTOP
  // ============================================================
  Widget _buildDesktopHeader(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(context, 40, 18),
          if (rightContent != null) rightContent!,
        ],
      ),
    );
  }

  // ============================================================
  //                        MOBILE
  // ============================================================
  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo centrado
        Center(
          child: _buildLogo(context, 34, 17),
        ),

        const SizedBox(height: 12),

        // RightContent a lo ancho
        if (rightContent != null)
          SizedBox(
            width: double.infinity,
            child: rightContent!,
          ),
      ],
    );
  }

  // ============================================================
  //                    LOGO + TEXTO
  // ============================================================
  Widget _buildLogo(BuildContext context, double height, double fontSize) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PrincipalPantalla()),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            RutasImagenes.logo,
            height: height,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            "ALBION HELPER",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.headerTexto,
            ),
          ),
        ],
      ),
    );
  }
}
