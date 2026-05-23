import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_card.dart';
import 'add_transaction_page.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  String _filtroTipo = 'Todas';
  final TextEditingController _pesquisaController = TextEditingController();
  String _pesquisa = '';

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  List<TransactionModel> get _transacoesFiltradas {
    final lista = context.watch<TransactionProvider>().transacoes;
    return lista.where((t) {
      if (_filtroTipo == 'Receitas' && t.tipo != TransactionModel.receita) return false;
      if (_filtroTipo == 'Despesas' && t.tipo != TransactionModel.despesa) return false;
      if (_pesquisa.isNotEmpty) {
        final q = _pesquisa.toLowerCase();
        return t.descricao.toLowerCase().contains(q) || t.categoria.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.superficie,
            padding: const EdgeInsets.only(top: 56, bottom: 0, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.fundo,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                // Tabs de filtro
                Row(
                  children: ['Todas', 'Receitas', 'Despesas'].map((tab) {
                    final sel = _filtroTipo == tab;
                    return GestureDetector(
                      onTap: () => setState(() => _filtroTipo = tab),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.fundoReceita : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel ? AppColors.primaria : AppColors.textoSecundario,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 1),
              ],
            ),
          ),

          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.superficie,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borda),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 18, color: AppColors.textoSecundario),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _pesquisaController,
                      onChanged: (v) => setState(() => _pesquisa = v),
                      decoration: const InputDecoration(
                        hintText: 'Pesquisar transacções…',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista
          Expanded(
            child: _transacoesFiltradas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textoSecundario),
                        SizedBox(height: 12),
                        Text(AppTextos.semTransaccoes, style: TextStyle(color: AppColors.textoSecundario)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _transacoesFiltradas.length,
                    itemBuilder: (ctx, i) {
                      final t = _transacoesFiltradas[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: Key(t.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.fundoDespesa,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: AppColors.despesa),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
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
                          },
                          onDismissed: (_) => context.read<TransactionProvider>().removerTransacao(t.id),
                          child: TransactionCard(
                            transacao: t,
                            aoPremir: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddTransactionPage(transacaoEdit: t)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
