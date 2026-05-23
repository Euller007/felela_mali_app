/// Representa uma categoria de transaccao financeira
class CategoryModel {
  final String id;
  final String nome;
  final String tipo;
  final String icone;

  CategoryModel({
    required this.id,
    required this.nome,
    required this.tipo,
    this.icone = '',
  });

  static const String receita = 'receita';
  static const String despesa = 'despesa';

  bool get eReceita => tipo == receita;
  bool get eDespesa => tipo == despesa;

  Map<String, dynamic> paraMapa() {
    return {
      'nome': nome,
      'tipo': tipo,
      'icone': icone,
    };
  }

  factory CategoryModel.deMapa(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      nome: map['nome'] as String,
      tipo: map['tipo'] as String,
      icone: map['icone'] as String? ?? '',
    );
  }

  // Categorias
  static List<CategoryModel> categoriasPadrao() {
    return [
      // Despesas
      CategoryModel(id: 'cat_alimentacao', nome: 'Alimentação', tipo: despesa),
      CategoryModel(id: 'cat_transporte',  nome: 'Transporte',  tipo: despesa),
      CategoryModel(id: 'cat_lazer',       nome: 'Lazer',       tipo: despesa),
      CategoryModel(id: 'cat_educacao',    nome: 'Educação',    tipo: despesa),
      CategoryModel(id: 'cat_saude',       nome: 'Saúde',       tipo: despesa),
      CategoryModel(id: 'cat_outro',       nome: 'Outro',       tipo: despesa),

      // Receitas
      CategoryModel(id: 'cat_salario', nome: 'Salário', tipo: receita),
      CategoryModel(id: 'cat_bolsa',   nome: 'Bolsa',   tipo: receita),
      CategoryModel(id: 'cat_mesada',  nome: 'Mesada',  tipo: receita),
    ];
  }
  /// Retorna apenas as categorias do tipo despesa
  static List<CategoryModel> categoriasDespesa() {
    return categoriasPadrao().where((c) => c.eDespesa).toList();
  }

  /// Retorna apenas as categorias do tipo receita
  static List<CategoryModel> categoriasReceita() {
    return categoriasPadrao().where((c) => c.eReceita).toList();
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, nome: $nome, tipo: $tipo)';
  }

}