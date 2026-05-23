import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/formatters.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();
  final TextEditingController _controladorLimite = TextEditingController();
  String _categoriaSeleccionada = 'Alimentação';

  final Map<String, String> _categoriasEmoji = {
    'Alimentação': '🍽️', 'Transporte': '🚌', 'Lazer': '🎮',
    'Educação': '🎓', 'Saúde': '🏥', 'Salário': '💼',
    'Bolsa': '🎒', 'Mesada': '💰', 'Outro': '📦',
  };

  @override
  void dispose() {
    _controladorLimite.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? idUsuario = context.read<AuthProvider>().utilizador?.uid;
      if (idUsuario != null) context.read<BudgetProvider>().definirUsuario(idUsuario);
    });
  }

  Future<void> _guardarOrcamento(BudgetProvider op) async {
    if (!_chaveFormulario.currentState!.validate()) return;
    final double limite = double.parse(_controladorLimite.text.trim().replaceAll(',', '.'));
    final bool sucesso = await op.guardarOrcamento(_categoriaSeleccionada, limite);
    if (!mounted) return;
    _controladorLimite.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sucesso
            ? 'Orçamento de $_categoriaSeleccionada definido!'
            : (op.erro ?? 'Erro ao guardar orçamento.')),
        backgroundColor: sucesso ? AppColors.primaria : AppColors.despesa,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Map<String, double> _calcularGastos(TransactionProvider tp) {
    final Map<String, double> gastos = {};
    for (final t in tp.transacoes) {
      if (t.eDespesa) {
        gastos[t.categoria] = (gastos[t.categoria] ?? 0) + t.valor;
      }
    }
    return gastos;
  }

  Color _corBarra(double percentagem) {
    if (percentagem >= 1.0) return AppColors.despesa;
    if (percentagem >= 0.8) return AppColors.aviso;
    return AppColors.primaria;
  }

  @override
  Widget build(BuildContext context) {
    final BudgetProvider op = context.watch<BudgetProvider>();
    final TransactionProvider tp = context.watch<TransactionProvider>();
    final Map<String, double> gastos = _calcularGastos(tp);

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.superficie,
            padding: const EdgeInsets.only(top: 56, bottom: 16, left: 20, right: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.fundo, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.arrow_back_rounded, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Orçamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),

          if (op.carregando)
            const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Formulario
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.superficie,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borda),
                      ),
                      child: Form(
                        key: _chaveFormulario,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Definir Orçamento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: _categoriaSeleccionada,
                              decoration: InputDecoration(
                                labelText: 'Categoria',
                                prefixIcon: Text(
                                  _categoriasEmoji[_categoriaSeleccionada] ?? '📦',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              items: _categoriasEmoji.keys.map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text('${_categoriasEmoji[cat]} $cat'),
                              )).toList(),
                              onChanged: (v) => setState(() => _categoriaSeleccionada = v!),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _controladorLimite,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Limite mensal (MZN)',
                                prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.textoSecundario),
                                suffixText: 'MT',
                              ),
                              validator: Validators.validarMontante,
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppColors.primaria, AppColors.secundaria]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _guardarOrcamento(op),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Guardar Orçamento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (op.orcamentos.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textoSecundario),
                              SizedBox(height: 12),
                              Text('Nenhum orçamento definido', style: TextStyle(color: AppColors.textoSecundario)),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      const Text('Orçamentos Activos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      ...op.orcamentos.entries.map((entry) {
                        final cat = entry.key;
                        final limite = entry.value;
                        final gasto = gastos[cat] ?? 0;
                        final excedido = gasto > limite;
                        final percentagem = limite > 0 ? (gasto / limite).clamp(0.0, 1.0) : 0.0;
                        final cor = _corBarra(percentagem);
                        final emoji = _categoriasEmoji[cat] ?? '📦';
                        final excesso = gasto - limite;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.superficie,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: excedido ? AppColors.despesa.withValues(alpha: 0.4) : AppColors.borda,
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(emoji, style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                              Text(
                                                '${Formatters.formatarMoeda(gasto)} / ${Formatters.formatarMoeda(limite)}',
                                                style: const TextStyle(fontSize: 11, color: AppColors.textoSecundario),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: cor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${(percentagem * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cor),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () async {
                                            final confirmar = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                title: const Text('Remover orçamento'),
                                                content: Text('Remover orçamento de $cat?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text('Remover', style: TextStyle(color: AppColors.despesa)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmar == true) op.removerOrcamento(cat);
                                          },
                                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textoSecundario),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentagem,
                                        minHeight: 6,
                                        backgroundColor: AppColors.fundo,
                                        color: cor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Banner "Limite ultrapassado" — só aparece quando excedido
                              if (excedido)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.despesa.withValues(alpha: 0.08),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.despesa),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Limite ultrapassado em ${Formatters.formatarMoeda(excesso)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.despesa,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
