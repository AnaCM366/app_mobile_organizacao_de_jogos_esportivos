class Jogo {
  final String? id;
  final String titulo;
  final DateTime dataHora;
  final String estabelecimentoId;
  final List<dynamic> participantes;

  Jogo({
    this.id,
    required this.titulo,
    required this.dataHora,
    required this.estabelecimentoId,
    this.participantes = const [],
  });

  // Converte o JSON do Supabase para o objeto Dart [cite: 23]
  factory Jogo.fromMap(Map<String, dynamic> map) {
    return Jogo(
      id: map['id'],
      titulo: map['titulo'],
      dataHora: DateTime.parse(map['data_hora']),
      estabelecimentoId: map['estabelecimento_id'],
      participantes: map['participantes'] ?? [],
    );
  }

  // Converte o objeto Dart para JSON para salvar no Supabase [cite: 23, 59]
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'data_hora': dataHora.toIso8601String(),
      'estabelecimento_id': estabelecimentoId,
    };
  }
}
