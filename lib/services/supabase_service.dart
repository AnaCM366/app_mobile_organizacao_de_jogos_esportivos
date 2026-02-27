import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Realiza o login do usuário
  Future<void> login(String email, String senha) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: senha);
    } catch (e) {
      throw Exception("Erro ao fazer login: ${e.toString()}");
    }
  }

  // Realiza o cadastro no Auth e na tabela pública 'usuarios'
  Future<void> register(String email, String password, String nome) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        final novoUsuario = Usuario(id: user.id, nome: nome, email: email);
        await supabase.from('usuarios').insert(novoUsuario.toMap());
      }
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw "Ocorreu um erro inesperado: $e";
    }
  }

  // --- MÉTODOS DE JOGOS ---

  // Busca a lista de jogos cadastrados
  Future<List<dynamic>> getGames() async {
    try {
      // Ordenamos pelos mais recentes para facilitar a visualização
      final response = await supabase
          .from('jogos')
          .select()
          .order('created_at');
      return response as List<dynamic>;
    } catch (e) {
      throw "Erro ao carregar jogos: $e";
    }
  }

  // Cria um novo jogo (Ajustado para aceitar apenas o nome do esporte)
  Future<void> createGame(String esporte) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw "Usuário não autenticado";

      await supabase.from('jogos').insert({
        'esporte': esporte,
        'usuario_id': user.id, // Vincula o criador ao jogo
      });
    } catch (e) {
      throw "Erro ao criar jogo: ${e.toString()}";
    }
  }

  // --- MÉTODOS DE PARTICIPAÇÃO ---

  // Adiciona o usuário a uma partida (Restaurado)
  Future<void> participate(String jogoId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw "Usuário não autenticado";

      await supabase.from('participacoes').insert({
        'jogo_id': jogoId,
        'usuario_id': user.id,
        'status': 'confirmado',
      });
    } catch (e) {
      throw "Erro ao participar do jogo: $e";
    }
  }

  // Remove o usuário da partida
  Future<void> leaveGame(String jogoId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw "Usuário não autenticado";

      await supabase.from('participacoes').delete().match({
        'jogo_id': jogoId,
        'usuario_id': user.id,
      });
    } catch (e) {
      throw "Erro ao sair do jogo: $e";
    }
  }
}
