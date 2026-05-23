import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/transaction_model.dart';

/// Card de transacao moderno com emoji de categoria
class TransactionCard extends StatelessWidget {
  final TransactionModel transacao;
  final VoidCallback? aoPremir;

  const TransactionCard({
    super.key,
    required this.transacao,
    this.aoPremir,
  });

  String get _emoji {
    switch (transacao.categoria.toLowerCase()) {
      case 'alimentação':
        return '🍽️';
      case 'transporte':
        return '🚌';
      case 'lazer':
        return '🎮';
      case 'educação':
      case 'propinas':
        return '🎓';
      case 'saúde':
        return '🏥';
      case 'salário':
        return '💼';
      case 'bolsa':
        return '🎒';
      case 'mesada':
        return '💰';
      default:
        return transacao.eReceita ? '💚' : '📦';
    }
  }

  Color get _corFundo {
    switch (transacao.categoria.toLowerCase()) {
      case 'alimentação':
        return const Color(0xFFFEF3C7);
      case 'transporte':
        return const Color(0xFFEEF2FF);
      case 'lazer':
        return const Color(0xFFFCE7F3);
      case 'educação':
      case 'propinas':
        return const Color(0xFFF3E8FF);
      case 'saúde':
        return const Color(0xFFFFEDE7);
      case 'salário':
      case 'bolsa':
      case 'mesada':
        return AppColors.fundoReceita;
      default:
        return transacao.eReceita ? AppColors.fundoReceita : AppColors.fundoDespesa;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoPremir,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borda, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _corFundo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(_emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transacao.descricao.isNotEmpty ? transacao.descricao : transacao.categoria,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textoPrimario,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transacao.categoria} · ${Formatters.formatarDataAbreviada(transacao.data)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${transacao.eReceita ? '+' : '-'}${Formatters.formatarMoeda(transacao.valor)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: transacao.eReceita ? AppColors.receita : AppColors.despesa,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
