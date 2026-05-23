import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Campo de texto personalizado reutilizavel
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String rotulo;
  final String? dica;
  final IconData? iconePrefixo;
  final bool obscuro;
  final TextInputType tipoTeclado;
  final String? Function(String?)? validador;
  final String? valorInicial;
  final void Function(String?)? aoSalvar;
  final void Function(String)? aoMudar;
  final bool soLeitura;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.rotulo,
    this.dica,
    this.iconePrefixo,
    this.obscuro = false,
    this.tipoTeclado = TextInputType.text,
    this.validador,
    this.valorInicial,
    this.aoSalvar,
    this.aoMudar,
    this.soLeitura = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _mostrarSenha = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.rotulo.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textoSecundario,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscuro && !_mostrarSenha,
          keyboardType: widget.tipoTeclado,
          validator: widget.validador,
          onSaved: widget.aoSalvar,
          onChanged: widget.aoMudar,
          readOnly: widget.soLeitura,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textoPrimario,
          ),
          decoration: InputDecoration(
            hintText: widget.dica,
            hintStyle: const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
            prefixIcon: widget.iconePrefixo != null
                ? Icon(widget.iconePrefixo, size: 18, color: AppColors.textoSecundario)
                : null,
            suffixIcon: widget.obscuro
                ? IconButton(
                    icon: Icon(
                      _mostrarSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.textoSecundario,
                    ),
                    onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
