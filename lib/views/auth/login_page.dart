import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

/// Pagina de autenticacao
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final tp = context.read<TransactionProvider>();
    final bp = context.read<BudgetProvider>();

    try {
      // Passa os providers para que sejam inicializados automaticamente apos login
      await auth.login(
        emailController.text.trim(),
        senhaController.text.trim(),
        transactionProvider: tp,
        budgetProvider: bp,
      );
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (mounted) Helpers.mostrarSnackBar(context, e.toString().replaceAll('Exception: ', ''), eErro: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com gradiente
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaria, AppColors.secundaria],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.only(top: 70, bottom: 40, left: 28, right: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bem-vindo',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Faça login para continuar',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),

            // Formulario
            Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: emailController,
                      rotulo: 'Email',
                      dica: 'utilizador@email.com',
                      iconePrefixo: Icons.mail_outline_rounded,
                      tipoTeclado: TextInputType.emailAddress,
                      validador: Validators.validarEmail,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: senhaController,
                      rotulo: 'Senha',
                      dica: '••••••••',
                      iconePrefixo: Icons.lock_outline_rounded,
                      obscuro: true,
                      validador: Validators.validarSenha,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      texto: 'Entrar',
                      aoPremir: _fazerLogin,
                      carregando: _isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text(
                        'Não tem conta? Criar conta →',
                        style: TextStyle(color: AppColors.secundaria, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
