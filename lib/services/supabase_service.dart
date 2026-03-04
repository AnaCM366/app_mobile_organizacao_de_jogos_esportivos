import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Busca jogos com join
  Future<List<dynamic>> getGames() async {
    final response = await supabase
        .from('jogos')
        .select('*, estabelecimentos(nome)')
        .order('criado_em', ascending: false);
    return response as List<dynamic>;
  }

  Future<void> createGame({
    required String esporte,
    required String dataHora,
    required String estabelecimentoId,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("Sessão expirada. Por favor, faça login novamente.");
    }

    await supabase.from('jogos').insert({
      'esporte': esporte,
      'data_hora': dataHora,
      'estabelecimento_id': estabelecimentoId,
      'usuario_id': user.id,
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

  // --- ALTERAÇÕES PARA PARTICIPAR DO JOGO ---
  Future<void> participate(String jogoId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('jogadores').insert({
      // Ajustado para os nomes que aparecem na sua imagem 539906.png
      'cadastro_jogos_form_page_id': jogoId,
      'user_id': user.id,
    });
  }

  Future<void> leaveGame(String jogoId) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase.from('jogadores').delete().match({
        'cadastro_jogos_form_page_id': jogoId,
        'user_id': user.id,
      });
    }
  }

  Future<List<dynamic>> getEstablishments() async {
    return await supabase.from('estabelecimentos').select('id, nome');
  }
}
