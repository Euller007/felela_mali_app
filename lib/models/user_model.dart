/// Representa o utilizador autenticado da aplicacao
class UserModel {
  final String uid;
  final String email;
  final String nome;
  final DateTime dataCriacao;

  UserModel({
    required this.uid,
    required this.email,
    required this.nome,
    required this.dataCriacao,
  });

  /// Extrai o primeiro nome do email caso o nome esteja vazio
  String get primeiroNome {
    if (nome.trim().isNotEmpty) return nome.trim().split(' ').first;
    return email.split('@').first;
  }

  Map<String, dynamic> paraMapa() {
    return {
      'uid': uid,
      'email': email,
      'nome': nome,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory UserModel.deMapa(Map<String, dynamic> mapa) {
    return UserModel(
      uid: mapa['uid'] as String,
      email: mapa['email'] as String,
      nome: mapa['nome'] as String? ?? '',
      dataCriacao: DateTime.parse(mapa['dataCriacao'] as String),
    );
  }

  UserModel copyWith({String? nome, String? email}) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      dataCriacao: dataCriacao,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, nome: $nome)';
}
