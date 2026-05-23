import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fornecedor que gere os orcamentos por categoria do utilizador
class BudgetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _coleccao = 'budgets';
  static const int _intervaloNotificacao = 24 * 60 * 60 * 1000;

  Map<String, double> _orcamentos = {};
  String? _idUsuarioActual;
  bool _carregando = false;
  String? _erro;

  Function(String mensagem)? aoNotificar;

  Map<String, double> get orcamentos => _orcamentos;
  bool get carregando => _carregando;
  String? get erro => _erro;

  /// Inicializa o provider com o ID do utilizador e carrega os orcamentos
  Future<void> definirUsuario(String idUsuario) async {
    if (_idUsuarioActual == idUsuario) return; // Evita recarregar se for o mesmo user
    _idUsuarioActual = idUsuario;
    await _carregarOrcamentos();
  }

  /// Limpa dados ao fazer logout
  void limpar() {
    _idUsuarioActual = null;
    _orcamentos = {};
    _erro = null;
    notifyListeners();
  }

  Future<void> _carregarOrcamentos() async {
    if (_idUsuarioActual == null) return;
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final DocumentSnapshot snapshot = await _firestore
          .collection(_coleccao)
          .doc(_idUsuarioActual)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        final Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
        _orcamentos = Map<String, double>.from(
          dados.map((chave, valor) => MapEntry(chave, (valor as num).toDouble())),
        );
      } else {
        _orcamentos = {};
      }
    } on FirebaseException catch (e) {
      _erro = 'Erro ao carregar orçamentos: ${e.message}';
    } catch (e) {
      _erro = 'Erro inesperado ao carregar orçamentos.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarOrcamento(String categoria, double limite) async {
    if (_idUsuarioActual == null) return false;
    _orcamentos[categoria] = limite;
    notifyListeners(); // Actualiza UI imediatamente (optimistic)

    try {
      await _firestore
          .collection(_coleccao)
          .doc(_idUsuarioActual)
          .set(_orcamentos);
      return true;
    } on FirebaseException catch (e) {
      _erro = 'Erro ao guardar orçamento: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      _erro = 'Erro inesperado.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removerOrcamento(String categoria) async {
    if (_idUsuarioActual == null) return false;
    final backup = double.tryParse(_orcamentos[categoria]?.toString() ?? '');
    _orcamentos.remove(categoria);
    notifyListeners();

    try {
      await _firestore
          .collection(_coleccao)
          .doc(_idUsuarioActual)
          .set(_orcamentos);
      return true;
    } on FirebaseException catch (e) {
      if (backup != null) _orcamentos[categoria] = backup;
      _erro = 'Erro ao remover orçamento: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      if (backup != null) _orcamentos[categoria] = backup;
      _erro = 'Erro inesperado.';
      notifyListeners();
      return false;
    }
  }

  double? obterOrcamentoCategoria(String categoria) => _orcamentos[categoria];

  Future<void> verificarOrcamentoENotificar(String categoria, double gastoNoMes) async {
    final double? limite = _orcamentos[categoria];
    if (limite == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String chaveNotificacao = 'ultima_notificacao_$categoria';
    final int ultimaNotificacao = prefs.getInt(chaveNotificacao) ?? 0;
    final int agora = DateTime.now().millisecondsSinceEpoch;
    final bool podeNotificar = (agora - ultimaNotificacao) > _intervaloNotificacao;

    if (!podeNotificar) return;

    if (gastoNoMes >= limite) {
      _emitirNotificacao('Limite excedido em $categoria: ${gastoNoMes.toStringAsFixed(2)} MZN');
      await prefs.setInt(chaveNotificacao, agora);
    } else if (gastoNoMes >= limite * 0.8) {
      _emitirNotificacao('Atenção: já usou 80% do orçamento de $categoria');
      await prefs.setInt(chaveNotificacao, agora);
    }
  }

  void _emitirNotificacao(String mensagem) {
    if (aoNotificar != null) aoNotificar!(mensagem);
  }
}
