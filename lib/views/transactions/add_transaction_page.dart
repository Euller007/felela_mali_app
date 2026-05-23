import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';

/// Pagina para adicionar ou editar uma transacao financeira
class AddTransactionPage extends StatefulWidget {
  final TransactionModel? transacaoEdit;
  const AddTransactionPage({super.key, this.transacaoEdit});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _aGuardar = false;

  late String _tipo;
  late String _categoria;
  late double _valor;
  late String _descricao;
  late DateTime _data;

  final Map<String, String> _categoriasReceita = {
    'Salário': '💼', 'Bolsa': '🎒', 'Mesada': '💰', 'Outro': '💚',
  };

  final Map<String, String> _categoriasDespesa = {
    'Alimentação': '🍽️', 'Transporte': '🚌', 'Lazer': '🎮',
    'Educação': '🎓', 'Saúde': '🏥', 'Outro': '📦',
  };

  bool get _modoEdicao => widget.transacaoEdit != null;
  Map<String, String> get _categoriasActuais =>
      _tipo == TransactionModel.despesa ? _categoriasDespesa : _categoriasReceita;

  @override
  void initState() {
    super.initState();
    if (_modoEdicao) {
      _tipo = widget.transacaoEdit!.tipo;
      _categoria = widget.transacaoEdit!.categoria;
      _valor = widget.transacaoEdit!.valor;
      _descricao = widget.transacaoEdit!.descricao;
      _data = widget.transacaoEdit!.data;
      _valorController.text = _valor.toString();
      _descricaoController.text = _descricao;
    } else {
      _tipo = TransactionModel.despesa;
      _categoria = _categoriasDespesa.keys.first;
      _valor = 0;
      _descricao = '';
      _data = DateTime.now();
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _alterarTipo(String novoTipo) {
    setState(() {
      _tipo = novoTipo;
      if (!_categoriasActuais.containsKey(_categoria)) {
        _categoria = _categoriasActuais.keys.first;
      }
    });
  }

  Future<void> _seleccionarData() async {
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaria),
        ),
        child: child!,
      ),
    );
    if (escolhida != null) setState(() => _data = escolhida);
  }

  Future<void> _submeterFormulario() async {
    if (!_chaveFormulario.currentState!.validate()) return;
    _chaveFormulario.currentState!.save();

    final AuthProvider auth = context.read<AuthProvider>();
    final TransactionProvider tp = context.read<TransactionProvider>();

    if (auth.utilizador == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Utilizador não autenticado')),
      );
      return;
    }

    setState(() => _aGuardar = true);

    final TransactionModel transaccao = TransactionModel(
      id: widget.transacaoEdit?.id ?? '',
      idUsuario: auth.utilizador!.uid,
      valor: _valor,
      tipo: _tipo,
      categoria: _categoria,
      descricao: _descricao,
      data: _data,
    );

    final bool sucesso = _modoEdicao
        ? await tp.editarTransacao(transaccao)
        : await tp.adicionarTransacao(transaccao);

    if (!mounted) return;
    setState(() => _aGuardar = false);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_modoEdicao ? 'Transacção actualizada!' : 'Transacção guardada!'),
          backgroundColor: AppColors.primaria,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tp.erro ?? 'Erro ao guardar transacção.'),
          backgroundColor: AppColors.despesa,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDespesa = _tipo == TransactionModel.despesa;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Column(
        children: [
          // Header com gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaria, AppColors.secundaria],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.only(top: 56, bottom: 24, left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _modoEdicao ? 'Editar Transacção' : 'Nova Transacção',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Toggle Receita / Despesa
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildToggle('↓ Receita', TransactionModel.receita, !isDespesa)),
                      Expanded(child: _buildToggle('↑ Despesa', TransactionModel.despesa, isDespesa)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Corpo do formulario
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _chaveFormulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Valor
                    Center(
                      child: TextFormField(
                        controller: _valorController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: isDespesa ? AppColors.despesa : AppColors.receita,
                        ),
                        decoration: InputDecoration(
                          hintText: '0,00',
                          hintStyle: TextStyle(
                            fontSize: 32,
                            color: AppColors.textoSecundario.withValues(alpha: 0.4),
                          ),
                          suffixText: 'MT',
                          suffixStyle: const TextStyle(fontSize: 16, color: AppColors.textoSecundario),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                        validator: Validators.validarMontante,
                        onSaved: (v) {
                          if (v != null && v.isNotEmpty) {
                            _valor = double.parse(v.trim().replaceAll(',', '.'));
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Descricao
                    _buildLabel('Descrição'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        hintText: 'Ex: Almoço restaurante',
                        prefixIcon: Icon(Icons.edit_outlined, size: 18, color: AppColors.textoSecundario),
                      ),
                      onSaved: (valor) => _descricao = valor ?? '',
                    ),
                    const SizedBox(height: 20),

                    // Categoria
                    _buildLabel('Categoria'),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _categoriasActuais.length,
                      itemBuilder: (context, index) {
                        final cat = _categoriasActuais.keys.elementAt(index);
                        final emoji = _categoriasActuais[cat]!;
                        final sel = _categoria == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _categoria = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.fundoReceita : AppColors.fundo,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: sel ? AppColors.primaria : AppColors.borda,
                                width: sel ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 22)),
                                const SizedBox(height: 4),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: sel ? AppColors.primaria : AppColors.textoSecundario,
                                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Data
                    _buildLabel('Data'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _seleccionarData,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.fundo,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borda, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textoSecundario),
                            const SizedBox(width: 10),
                            Text(
                              '${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}',
                              style: const TextStyle(fontSize: 14, color: AppColors.textoPrimario),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botao guardar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaria, AppColors.secundaria],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: _aGuardar ? null : _submeterFormulario,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _aGuardar
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _modoEdicao ? 'Actualizar Transacção' : 'Guardar Transacção',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, String tipo, bool activo) {
    return GestureDetector(
      onTap: () => _alterarTipo(tipo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: activo ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: activo ? AppColors.primaria : Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String texto) {
    return Text(
      texto.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textoSecundario,
        letterSpacing: 0.8,
      ),
    );
  }
}
