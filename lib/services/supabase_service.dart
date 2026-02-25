import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future login(String email, String senha) async {
    await supabase.auth.signInWithPassword(email: email, password: senha);
  }

  Future register(String email, String senha) async {
    await supabase.auth.signUp(email: email, password: senha);
  }

  Future createGame(Map<String, dynamic> data) async {
    await supabase.from('jogos').insert(data);
  }

  Future<List<dynamic>> getGames() async {
    final response = await supabase.from('jogos').select();
    return response;
  }

  Future participate(String jogoId, String userId) async {
    await supabase.from('participacoes').insert({
      'jogo_id': jogoId,
      'usuario_id': userId,
      'status': 'confirmado',
    });
  }

  Future leaveGame(String jogoId, String userId) async {
    await supabase.from('participacoes').delete().match({
      'jogo_id': jogoId,
      'usuario_id': userId,
    });
  }
}
