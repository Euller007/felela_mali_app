/// Validacao de campos de formulario

class Validators {
  Validators._();

  static final RegExp _padraoEmail =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static String? validarEmail(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'O email é obrigatório';
    }
    if (!_padraoEmail.hasMatch(valor.trim())) {
      return 'Introduza um email válido';
    }
    return null;
  }

  static String? validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'A senha é obrigatória';
    }
    if (valor.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? validarMontante(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'O valor é obrigatório';
    }

    final String valorTratado = valor.trim().replaceAll(',', '.');
    final double? numero = double.tryParse(valorTratado);
    
    if (numero == null) {
      return 'Introduza um número válido';
    }
    if (numero <= 0) {
      return 'O valor deve ser maior que zero';
    }
    return null;
  }

  static String? validarObrigatorio(String? valor, String nomeCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O campo $nomeCampo é obrigatório';
    }
    return null;
  }
}
