import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Botao personalizado reutilizavel com gradiente
class CustomButton extends StatelessWidget {
  final String texto;
  final VoidCallback? aoPremir;
  final bool carregando;
  final bool contornado;
  final IconData? icone;

  const CustomButton({
    super.key,
    required this.texto,
    this.aoPremir,
    this.carregando = false,
    this.contornado = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    if (contornado) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: carregando ? null : aoPremir,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaria, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: carregando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  texto,
                  style: const TextStyle(
                    color: AppColors.primaria,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaria, AppColors.secundaria],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: carregando ? null : aoPremir,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: carregando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icone != null) ...[
                      Icon(icone, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
