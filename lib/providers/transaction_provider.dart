import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/transaction_model.dart';

/// Fornecedor que gere o estado das transaccoes financeiras
/// Comunica com o Firestore para persistir e recuperar os dados
class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _coleccao = 'transactions';

  List<TransactionModel> _transacoes = [];
  bool _carregando = false;
  String? _erro;

  List<TransactionModel> get transacoes => _transacoes;
  bool get carregando => _carregando;
  String? get erro => _erro;

  /// Total de receitas
  double get totalReceitas => _transacoes
      .where((t) => t.eReceita)
      .fold(0.0, (soma, t) => soma + t.valor);

  /// Total de despesas
  double get totalDespesas => _transacoes
      .where((t) => t.eDespesa)
      .fold(0.0, (soma, t) => soma + t.valor);

  /// Saldo actual (receitas - despesas)
  double get saldo => totalReceitas - totalDespesas;

  void _limparErro() {
    _erro = null;
  }

  Future<void> buscarTransacoes(String idUsuario) async {
    _carregando = true;
    _limparErro();
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(_coleccao)
          .where('idUsuario', isEqualTo: idUsuario)
          .orderBy('data', descending: true)
          .get();

      _transacoes = snapshot.docs
          .map((doc) => TransactionModel.deMapa(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      _erro = 'Erro ao carregar transacções: ${e.message}';
    } catch (e) {
      _erro = 'Erro inesperado ao carregar dados.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> adicionarTransacao(TransactionModel transacao) async {
    _limparErro();
    try {
      final DocumentReference doc = await _firestore
          .collection(_coleccao)
          .add(transacao.paraMapa());

      final TransactionModel transacaoComId = TransactionModel.deMapa(
        doc.id,
        transacao.paraMapa(),
      );

      _transacoes.insert(0, transacaoComId);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _erro = 'Erro ao guardar: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      _erro = 'Erro inesperado ao guardar.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarTransacao(TransactionModel transacao) async {
    _limparErro();
    try {
      await _firestore
          .collection(_coleccao)
          .doc(transacao.id)
          .update(transacao.paraMapa());

      final index = _transacoes.indexWhere((t) => t.id == transacao.id);
      if (index != -1) {
        _transacoes[index] = transacao;
        notifyListeners();
      }
      return true;
    } on FirebaseException catch (e) {
      _erro = 'Erro ao actualizar: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      _erro = 'Erro inesperado ao actualizar.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removerTransacao(String id) async {
    _limparErro();
    // Guarda copia para restaurar em caso de erro
    final backup = List<TransactionModel>.from(_transacoes);
    _transacoes.removeWhere((t) => t.id == id);
    notifyListeners();

    try {
      await _firestore.collection(_coleccao).doc(id).delete();
      return true;
    } on FirebaseException catch (e) {
      // Restaura lista se falhar
      _transacoes = backup;
      _erro = 'Erro ao remover: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      _transacoes = backup;
      _erro = 'Erro inesperado ao remover.';
      notifyListeners();
      return false;
    }
  }
}
