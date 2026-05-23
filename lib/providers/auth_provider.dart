import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'budget_provider.dart';
import 'transaction_provider.dart';

/// Fornecedor de autenticacao que gere o estado do utilizador
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? utilizador;
  String? _erro;

  String? get erro => _erro;

  AuthProvider() {
    utilizador = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      utilizador = user;
      notifyListeners();
    });
  }

  /// Registo de novo utilizador
  Future<void> registar(String email, String senha) async {
    _erro = null;
    try {
      final UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      utilizador = credencial.user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _erro = _traduzirErroAuth(e.code);
      throw Exception(_erro);
    }
  }

  /// Login de utilizador existente. Inicializa os providers dependentes.
  Future<void> login(
    String email,
    String senha, {
    TransactionProvider? transactionProvider,
    BudgetProvider? budgetProvider,
  }) async {
    _erro = null;
    try {
      final UserCredential credencial = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      utilizador = credencial.user;
      notifyListeners();

      // Inicializa os outros providers logo apos o login
      if (utilizador != null) {
        transactionProvider?.buscarTransacoes(utilizador!.uid);
        budgetProvider?.definirUsuario(utilizador!.uid);
      }
    } on FirebaseAuthException catch (e) {
      _erro = _traduzirErroAuth(e.code);
      throw Exception(_erro);
    }
  }

  /// Logout do utilizador. Limpa dados dos providers.
  Future<void> logout({
    TransactionProvider? transactionProvider,
    BudgetProvider? budgetProvider,
  }) async {
    await _auth.signOut();
    utilizador = null;
    budgetProvider?.limpar();
    notifyListeners();
  }

  /// Traduz os codigos de erro do Firebase para mensagens em portugues
  String _traduzirErroAuth(String codigo) {
    switch (codigo) {
      case 'user-not-found':
        return 'Utilizador não encontrado.';
      case 'wrong-password':
        return 'Senha incorrecta.';
      case 'email-already-in-use':
        return 'Este email já está registado.';
      case 'weak-password':
        return 'A senha é demasiado fraca.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'too-many-requests':
        return 'Demasiadas tentativas. Tente mais tarde.';
      case 'network-request-failed':
        return 'Sem ligação à internet.';
      default:
        return 'Erro de autenticação. Tente novamente.';
    }
  }

  /// Primeiro nome do utilizador (do email)
  String get primeiroNome {
    final email = utilizador?.email;
    if (email == null) return 'Utilizador';
    return email.split('@').first;
  }
}
