///formatacao de valores, datas e texto

class Formatters {
  Formatters._();
  static const List<String> _nomesMeses = [
    'Janeiro', 'Fevereiro', 'Março',    'Abril',
    'Maio',    'Junho',     'Julho',    'Agosto',
    'Setembro','Outubro',   'Novembro', 'Dezembro',
  ];

  static String formatarMoeda(double valor) {
    final String parteInteira = valor
        .toStringAsFixed(2)
        .split('.')[0]
        .replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );
    final String parteDecimal = valor.toStringAsFixed(2).split('.')[1];

    return '$parteInteira,$parteDecimal MZN';
  }

  static String formatarData(DateTime data) {
    final String dia  = data.day.toString().padLeft(2, '0');
    final String mes  = data.month.toString().padLeft(2, '0');
    final String ano  = data.year.toString();

    return '$dia/$mes/$ano';
  }

  static String formatarDataAbreviada(DateTime data) {
    final String dia = data.day.toString().padLeft(2, '0');
    final String mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes';
  }

  static String obterNomeMes(int mes) {
    assert(mes >= 1 && mes <= 12, 'O mês deve estar entre 1 e 12');
    return _nomesMeses[mes - 1];
  }

  static String obterMesAno(DateTime data) {
    return '${obterNomeMes(data.month)} ${data.year}';
  }
}