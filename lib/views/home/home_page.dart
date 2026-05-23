import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/transaction_card.dart';
import '../transactions/add_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final userId = auth.utilizador?.uid;
      if (userId != null) {
        final tp = context.read<TransactionProvider>();
        if (tp.transacoes.isEmpty && !tp.carregando) {
          tp.buscarTransacoes(userId);
        }
        context.read<BudgetProvider>().definirUsuario(userId);
      }
    });
  }

  Future<void> _apagarTudo(BuildContext context, TransactionProvider tp) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Apagar tudo'),
        content: const Text('Tem a certeza que quer apagar TODAS as transacções? Esta acção não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar tudo', style: TextStyle(color: AppColors.despesa)),
          ),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      final ids = tp.transacoes.map((t) => t.id).toList();
      for (final id in ids) await tp.removerTransacao(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Todas as transacções foram apagadas.'),
          backgroundColor: AppColors.primaria,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tp = context.watch<TransactionProvider>();
    final nome = auth.primeiroNome;
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: RefreshIndicator(
        color: AppColors.primaria,
        onRefresh: () async {
          final userId = auth.utilizador?.uid;
          if (userId != null) await tp.buscarTransacoes(userId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                padding: const EdgeInsets.only(top: 56, bottom: 24, left: 20, right: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(inicial, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Olá de volta 👋', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                          Text(nome, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                    if (tp.transacoes.isNotEmpty)
                      Container(
                        width: 36, height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                          tooltip: 'Apagar tudo',
                          onPressed: () => _apagarTudo(context, tp),
                        ),
                      ),
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                        tooltip: AppTextos.sair,
                        onPressed: () async {
                          await auth.logout(budgetProvider: context.read<BudgetProvider>());
                          if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Card saldo
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.superficie,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borda),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: tp.carregando
                      ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator(strokeWidth: 2)))
                      : Column(
                          children: [
                            const Text(AppTextos.saldoActual, style: TextStyle(fontSize: 11, color: AppColors.textoSecundario, letterSpacing: 0.6)),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                Formatters.formatarMoeda(tp.saldo),
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -1,
                                  color: tp.saldo >= 0 ? AppColors.primaria : AppColors.despesa,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildSummaryItem(AppTextos.receitas, tp.totalReceitas, AppColors.receita, AppColors.fundoReceita, Icons.arrow_downward_rounded)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildSummaryItem(AppTextos.despesas, tp.totalDespesas, AppColors.despesa, AppColors.fundoDespesa, Icons.arrow_upward_rounded)),
                              ],
                            ),
                          ],
                        ),
                ),
              ),

              // Banner erro
              if (tp.erro != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.fundoDespesa,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.despesa.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.despesa),
                        const SizedBox(width: 8),
                        Expanded(child: Text(tp.erro!, style: const TextStyle(fontSize: 12, color: AppColors.despesa))),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Acoes rapidas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildActionBtn(context, Icons.add_circle_outline_rounded, 'Adicionar', const Color(0xFFE8F5EE), const Color(0xFF1A5C38), () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionPage()));
                    }),
                    const SizedBox(width: 10),
                    _buildActionBtn(context, Icons.receipt_long_outlined, 'Histórico', const Color(0xFFEEF2FF), const Color(0xFF4338CA), () {
                      Navigator.pushNamed(context, '/history');
                    }),
                    const SizedBox(width: 10),
                    _buildActionBtn(context, Icons.account_balance_wallet_outlined, 'Orçamento', const Color(0xFFFEF3C7), const Color(0xFFD97706), () {
                      Navigator.pushNamed(context, '/budget');
                    }),
                    const SizedBox(width: 10),
                    _buildActionBtn(context, Icons.bar_chart_rounded, 'Relatório', const Color(0xFFFCE7F3), const Color(0xFFBE185D), () {
                      Navigator.pushNamed(context, '/report');
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Titulo recentes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transacções Recentes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/history'),
                      child: const Text('Ver todas', style: TextStyle(color: AppColors.secundaria, fontSize: 12)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Lista ou estado vazio
              if (tp.carregando)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (tp.transacoes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Column(children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textoSecundario),
                      SizedBox(height: 12),
                      Text(AppTextos.semTransaccoes, style: TextStyle(color: AppColors.textoSecundario)),
                    ]),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tp.transacoes.length > 5 ? 5 : tp.transacoes.length,
                  itemBuilder: (context, i) {
                    final t = tp.transacoes[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: Key(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: AppColors.fundoDespesa, borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.despesa),
                        ),
                        confirmDismiss: (_) async => await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Apagar transacção'),
                            content: const Text('Tem a certeza?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apagar', style: TextStyle(color: AppColors.despesa))),
                            ],
                          ),
                        ),
                        onDismissed: (_) => tp.removerTransacao(t.id),
                        child: TransactionCard(
                          transacao: t,
                          aoPremir: () => Navigator.pushNamed(context, '/detail', arguments: t),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionPage())),
        backgroundColor: AppColors.primaria,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nova Transacção', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color cor, Color fundo, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textoSecundario, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(Formatters.formatarMoeda(value), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, IconData icone, String label, Color fundo, Color cor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(16)),
              child: Icon(icone, color: cor, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textoSecundario), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
