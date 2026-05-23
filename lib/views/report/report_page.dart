import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../providers/transaction_provider.dart';

/// Pagina de relatorio mensal com grafico e resumo financeiro
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late DateTime _mesSelecionado;

  @override
  void initState() {
    super.initState();
    _mesSelecionado = DateTime.now();
  }

  void _mesAnterior() => setState(() {
    _mesSelecionado = DateTime(_mesSelecionado.year, _mesSelecionado.month - 1);
  });

  void _mesSeguinte() {
    final agora = DateTime.now();
    if (_mesSelecionado.year < agora.year ||
        (_mesSelecionado.year == agora.year && _mesSelecionado.month < agora.month)) {
      setState(() => _mesSelecionado = DateTime(_mesSelecionado.year, _mesSelecionado.month + 1));
    }
  }

  Map<String, double> _calcularTotais(TransactionProvider tp, int mes, int ano) {
    double receitas = 0, despesas = 0;
    final Map<String, double> porCategoria = {};
    for (final t in tp.transacoes) {
      if (t.data.year == ano && t.data.month == mes) {
        if (t.eReceita) {
          receitas += t.valor;
        } else {
          despesas += t.valor;
          porCategoria[t.categoria] = (porCategoria[t.categoria] ?? 0) + t.valor;
        }
      }
    }
    return {'receitas': receitas, 'despesas': despesas, ...porCategoria};
  }

  String _emojiCategoria(String cat) {
    switch (cat.toLowerCase()) {
      case 'alimentação': return '🍽️';
      case 'transporte': return '🚌';
      case 'lazer': return '🎮';
      case 'educação': case 'propinas': return '🎓';
      case 'saúde': return '🏥';
      case 'salário': return '💼';
      default: return '📦';
    }
  }

  static const List<Color> _coresCats = [
    Color(0xFF4338CA), AppColors.primaria, Color(0xFFD97706),
    Color(0xFFBE185D), Color(0xFF0891B2), Color(0xFF65A30D),
  ];

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransactionProvider>();
    final totais = _calcularTotais(tp, _mesSelecionado.month, _mesSelecionado.year);
    final receitas = totais['receitas']!;
    final despesas = totais['despesas']!;
    final saldo = receitas - despesas;
    final categoriasDesp = totais.entries
        .where((e) => e.key != 'receitas' && e.key != 'despesas' && e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.superficie,
            padding: const EdgeInsets.only(top: 56, bottom: 16, left: 20, right: 20),
            child: Column(
              children: [
                Row(
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
                    const Text('Relatório', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                // Navegacao de mes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _mesAnterior,
                      icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textoSecundario),
                    ),
                    Text(
                      Formatters.obterMesAno(_mesSelecionado).toUpperCase(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                    IconButton(
                      onPressed: _mesSeguinte,
                      icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textoSecundario),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Cards de resumo
                  Row(
                    children: [
                      Expanded(child: _buildSumCard('Renda', receitas, AppColors.fundoReceita, AppColors.receita, Icons.arrow_downward_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildSumCard('Despesa', despesas, AppColors.fundoDespesa, AppColors.despesa, Icons.arrow_upward_rounded)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Card de saldo liquido
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primaria, AppColors.secundaria]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Líquido', style: TextStyle(fontSize: 11, color: Colors.white70, letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        Text(
                          Formatters.formatarMoeda(saldo),
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grafico de barras
                  if (receitas > 0 || despesas > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.superficie,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borda),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Receitas vs Despesas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: (receitas > despesas ? receitas : despesas) * 1.2,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.borda, strokeWidth: 1),
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, _) {
                                        final labels = ['Receitas', 'Despesas'];
                                        if (v.toInt() < labels.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(labels[v.toInt()], style: const TextStyle(fontSize: 11, color: AppColors.textoSecundario)),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [
                                    BarChartRodData(toY: receitas, color: AppColors.receita, width: 36, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                                  ]),
                                  BarChartGroupData(x: 1, barRods: [
                                    BarChartRodData(toY: despesas, color: AppColors.despesa, width: 36, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Despesas por categoria
                  if (categoriasDesp.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.superficie,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borda),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Despesas por Categoria', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 14),
                          ...categoriasDesp.asMap().entries.map((entry) {
                            final i = entry.key;
                            final cat = entry.value.key;
                            final val = entry.value.value;
                            final perc = despesas > 0 ? (val / despesas * 100) : 0;
                            final cor = _coresCats[i % _coresCats.length];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(_emojiCategoria(cat), style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(cat, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                      Text(
                                        '${Formatters.formatarMoeda(val)} (${perc.toStringAsFixed(1)}%)',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textoSecundario),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: despesas > 0 ? val / despesas : 0,
                                      minHeight: 5,
                                      backgroundColor: AppColors.fundo,
                                      color: cor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 40),
                    const Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.textoSecundario),
                    const SizedBox(height: 12),
                    const Text('Sem dados para este mês', style: TextStyle(color: AppColors.textoSecundario)),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSumCard(String label, double valor, Color fundo, Color cor, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textoSecundario, letterSpacing: 0.4)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.formatarMoeda(valor),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cor),
          ),
        ],
      ),
    );
  }
}
