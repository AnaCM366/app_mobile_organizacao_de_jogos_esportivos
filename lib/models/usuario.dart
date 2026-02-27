class Usuario {
  final String id;
  final String nome;
  final String email;

  Usuario({required this.id, required this.nome, required this.email});

  //  Converte um mapa (JSON) do banco de dados para o objeto Usuario
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
    );
  }

  // Converte o objeto Usuario para um mapa (JSON) para salvar no banco
  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'email': email};
  }
}
