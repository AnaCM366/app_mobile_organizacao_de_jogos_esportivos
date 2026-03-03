import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Busca jogos com join
  Future<List<dynamic>> getGames() async {
    final response = await supabase
        .from('jogos')
        .select('*, estabelecimentos(nome)')
        .order('created_at', ascending: false);
    return response as List<dynamic>;
  }

  Future<void> createGame({
    required String esporte,
    required String dataHora,
    required String estabelecimentoId,
  }) async {
    // Atenção: O erro da imagem diz que 'data_hora' não existe no banco.
    // Se este código falhar, mude o nome da chave abaixo para o nome que está no seu Supabase.
    await supabase.from('jogos').insert({
      'esporte': esporte,
      'data_hora': dataHora,
      'estabelecimento_id': estabelecimentoId,
    });
  }

  Future<void> register(String email, String password, String nome) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      await supabase.from('usuarios').insert({
        'id': response.user!.id,
        'nome': nome,
        'email': email,
      });
    }
  }

  Future<void> login(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> participate(String jogoId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    await supabase.from('participacoes').insert({
      'jogo_id': jogoId,
      'usuario_id': user.id,
    });
  }

  Future<void> leaveGame(String jogoId) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase.from('participacoes').delete().match({
        'jogo_id': jogoId,
        'usuario_id': user.id,
      });
    }
  }

  Future<List<dynamic>> getEstablishments() async {
    return await supabase.from('estabelecimentos').select('id, nome');
  }
}
