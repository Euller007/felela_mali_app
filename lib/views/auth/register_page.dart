import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

/// Pagina de registo
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  /// registar um novo utilizador
  Future<void> _registar() async {
    if (!_formKey.currentState!.validate()) return;
    if (senhaController.text != confirmarSenhaController.text) {
      Helpers.mostrarSnackBar(context, 'As senhas não coincidem', eErro: true);
      return;
    }
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    try {
      await auth.registar(emailController.text.trim(), senhaController.text.trim());
      if (mounted) {
        Helpers.mostrarSnackBar(context, 'Conta criada com sucesso!');
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) Helpers.mostrarSnackBar(context, e.toString(), eErro: true);
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
            // Header
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Criar Conta',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Preencha os seus dados para começar',
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
                      dica: 'felela@email.com',
                      iconePrefixo: Icons.mail_outline_rounded,
                      tipoTeclado: TextInputType.emailAddress,
                      validador: Validators.validarEmail,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: senhaController,
                      rotulo: 'Senha',
                      dica: '••••••',
                      iconePrefixo: Icons.lock_outline_rounded,
                      obscuro: true,
                      validador: Validators.validarSenha,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: confirmarSenhaController,
                      rotulo: 'Confirmar Senha',
                      dica: '••••••',
                      iconePrefixo: Icons.lock_outline_rounded,
                      obscuro: true,
                      validador: (valor) {
                        if (valor == null || valor.isEmpty) return 'Confirme a sua senha';
                        if (valor != senhaController.text) return 'As senhas não coincidem';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      texto: 'Cadastrar',
                      aoPremir: _registar,
                      carregando: _isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Já tenho conta →',
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
