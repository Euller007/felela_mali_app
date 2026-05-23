/// Representa uma transaccao financeira do utilizador
class TransactionModel {
  final String id;
  final String idUsuario;
  final double valor;
  final String tipo;
  final String categoria;
  final String descricao;
  final DateTime data;

  TransactionModel({
    required this.id,
    required this.idUsuario,
    required this.valor,
    required this.tipo,
    required this.categoria,
    required this.descricao,
    required this.data,
  });

  static const String receita = 'receita';
  static const String despesa = 'despesa';

  Map<String, dynamic> paraMapa() {
    return {
      'idUsuario': idUsuario,
      'valor':     valor,
      'tipo':      tipo,
      'categoria': categoria,
      'descricao': descricao,
      'data':      data.toIso8601String(),
    };
  }

  factory TransactionModel.deMapa(String id, Map<String, dynamic> mapa) {
    return TransactionModel(
      id:        id,
      idUsuario: mapa['idUsuario'] as String,
      valor:     (mapa['valor'] as num).toDouble(),
      tipo:      mapa['tipo']      as String,
      categoria: mapa['categoria'] as String,
      descricao: mapa['descricao'] as String,
      data:      DateTime.parse(mapa['data'] as String),
    );
  }
  bool get eReceita => tipo == receita;
  bool get eDespesa => tipo == despesa;

  @override
  String toString() {
    return 'TransactionModel(id: $id, tipo: $tipo, valor: $valor, data: $data)';
  }
}