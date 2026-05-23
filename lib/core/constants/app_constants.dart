import 'package:flutter/material.dart';

/// Define as cores padrao utilizadas em toda a aplicacao.
class AppColors {
  static const Color primaria = Color(0xFF1A5C38);
  static const Color secundaria = Color(0xFF2E8B57);
  static const Color terciaria = Color(0xFF4CAF7D);
  static const Color receita = Color(0xFF1A5C38);
  static const Color despesa = Color(0xFFC0392B);
  static const Color fundo = Color(0xFFF4F6F4);
  static const Color superficie = Colors.white;
  static const Color erro = Color(0xFFC0392B);
  static const Color aviso = Color(0xFFF0A500);
  static const Color fundoReceita = Color(0xFFE8F5EE);
  static const Color fundoDespesa = Color(0xFFFDECEA);
  static const Color textoPrimario = Color(0xFF1A1A1A);
  static const Color textoSecundario = Color(0xFF6B7280);
  static const Color borda = Color(0xFFE5E7EB);
}

class AppTextos {
  static const String nomeApp = 'FelelaMali';
  static const String sair = 'Sair';
  static const String saldoActual = 'Saldo Disponível';
  static const String receitas = 'Receitas';
  static const String despesas = 'Despesas';
  static const String adicionarTransaccao = 'Adicionar transacção';
  static const String historico = 'Histórico';
  static const String semTransaccoes = 'Nenhuma transacção encontrada';
  static const String orcamento = 'Orçamento';
  static const String relatorio = 'Relatório';
}

class AppTheme {
  static ThemeData get tema {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaria,
        primary: AppColors.primaria,
        secondary: AppColors.secundaria,
        surface: AppColors.superficie,
      ),
      scaffoldBackgroundColor: AppColors.fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.superficie,
        foregroundColor: AppColors.textoPrimario,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textoPrimario,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaria,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fundo,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borda, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borda, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secundaria, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borda, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }
}
