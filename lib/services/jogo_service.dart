import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jogo_model.dart';

class JogoService {
  final supabase = Supabase.instance.client;

  // Listagem de jogos [cite: 40, 92]
  Future<List<Jogo>> listarJogos() async {
    final response = await supabase.from('jogos').select();
    return (response as List).map((dados) => Jogo.fromMap(dados)).toList();
  }

  // Cadastro de novo jogo [cite: 39, 93]
  Future<void> cadastrarJogo(Jogo jogo) async {
    await supabase.from('jogos').insert(jogo.toMap());
  }

  // Participar ou sair de um jogo [cite: 22, 28, 42, 95]
  Future<void> alternarParticipacao(String jogoId, List<dynamic> atuais) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    List<dynamic> novosParticipantes = List.from(atuais);
    if (novosParticipantes.contains(userId)) {
      novosParticipantes.remove(userId);
    } else {
      novosParticipantes.add(userId);
    }

    await supabase
        .from('jogos')
        .update({'participantes': novosParticipantes})
        .eq('id', jogoId);
  }
}
