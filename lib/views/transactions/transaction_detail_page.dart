import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'add_transaction_page.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel transacao;
  const TransactionDetailPage({super.key, required this.transacao});

  String get _emoji {
    switch (transacao.categoria.toLowerCase()) {
      case 'alimentação': return '🍽️';
      case 'transporte': return '🚌';
      case 'lazer': return '🎮';
      case 'educação': case 'propinas': return '🎓';
      case 'saúde': return '🏥';
      case 'salário': return '💼';
      case 'bolsa': return '🎒';
      case 'mesada': return '💰';
      default: return transacao.eReceita ? '💚' : '📦';
    }
  }

  Future<void> _remover(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover transacção'),
        content: const Text('Tem a certeza que quer remover esta transacção?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: AppColors.despesa)),
          ),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      await context.read<TransactionProvider>().removerTransacao(transacao.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDespesa = transacao.eDespesa;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56, bottom: 40, left: 20, right: 20),
            decoration: BoxDecoration(color: isDespesa ? AppColors.despesa : AppColors.primaria),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const Text('Detalhe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(width: 36),
                  ],
                ),
                const SizedBox(height: 24),
                Text(_emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  '${isDespesa ? '-' : '+'}${Formatters.formatarMoeda(transacao.valor)}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -1),
                ),
                const SizedBox(height: 4),
                Text(isDespesa ? 'Despesa' : 'Receita', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.superficie,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borda),
                    ),
                    child: Column(
                      children: [
                        _buildLinha(Icons.edit_outlined, 'Descrição', transacao.descricao.isNotEmpty ? transacao.descricao : '—'),
                        _buildDivider(),
                        _buildLinha(Icons.category_outlined, 'Categoria', transacao.categoria),
                        _buildDivider(),
                        _buildLinha(Icons.calendar_today_outlined, 'Data',
                            '${transacao.data.day.toString().padLeft(2, '0')}/${transacao.data.month.toString().padLeft(2, '0')}/${transacao.data.year}'),
                        _buildDivider(),
                        _buildLinha(Icons.swap_vert_rounded, 'Tipo', isDespesa ? 'Despesa' : 'Receita'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionPage(transacaoEdit: transacao))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaria, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primaria, size: 18),
                      label: const Text('Editar Transacção', style: TextStyle(color: AppColors.primaria, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _remover(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.despesa, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.despesa, size: 18),
                      label: const Text('Remover Transacção', style: TextStyle(color: AppColors.despesa, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinha(IconData icone, String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icone, size: 18, color: AppColors.textoSecundario),
          const SizedBox(width: 12),
          Text(rotulo, style: const TextStyle(fontSize: 13, color: AppColors.textoSecundario)),
          const Spacer(),
          Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 16, endIndent: 16);
}