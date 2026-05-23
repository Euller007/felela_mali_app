import 'package:flutter/material.dart';

/// Centraliza funcoes auxiliares de interface e manipulacao de datas
class Helpers {
  Helpers._();

  static void mostrarSnackBar(
      BuildContext context,
      String mensagem, {
        bool eErro = false,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: eErro ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static int timestampActual() => DateTime.now().millisecondsSinceEpoch;
  static bool mesmoMes(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month;
  }

  static DateTime primeiroDiaMes(DateTime data) {
    return DateTime(data.year, data.month, 1);
  }

  static DateTime ultimoDiaMes(DateTime data) {
    return DateTime(data.year, data.month + 1, 0);
  }


  static bool eHoje(DateTime data) {
    final DateTime agora = DateTime.now();
    return data.year == agora.year &&
        data.month == agora.month &&
        data.day == agora.day;
  }


  static bool eMesActual(DateTime data) {
    return mesmoMes(data, DateTime.now());
  }

  static int diasNoMes(DateTime data) {
    return ultimoDiaMes(data).day;
  }
}