import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // --- BUSCA DE JOGOS (O que estava faltando!) ---
  // Este método resolve o erro 'getGames isn't defined'
  Future<List<dynamic>> getGames() async {
    // Buscamos todos os dados da tabela 'jogos' e o 'nome' da tabela 'estabelecimentos'
    final response = await supabase
        .from('jogos')
        .select('*, estabelecimentos(nome)')
        .order('created_at', ascending: false);

    return response as List<dynamic>;
  }

  // --- BUSCA DE ESTABELECIMENTOS ---
  Future<List<dynamic>> getEstablishments() async {
    final response = await supabase.from('estabelecimentos').select('id, nome');
    return response as List<dynamic>;
  }

  // --- CRIAÇÃO DE JOGO (Requisito da Aula 2) ---
  Future<void> createGame({
    required String esporte,
    required String dataHora,
    required String estabelecimentoId,
  }) async {
    final user = supabase.auth.currentUser;
    // Verificação de Null Safety para evitar erro de user nulo
    if (user == null) throw "Usuário não autenticado";

    await supabase.from('jogos').insert({
      'esporte': esporte,
      'data_hora': dataHora,
      'estabelecimento_id': estabelecimentoId,
      'usuario_id': user.id,
    });
  }

  // --- AUTENTICAÇÃO E REGISTRO ---
  Future<void> login(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
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

  // --- PARTICIPAÇÃO (Requisito da Aula 3) ---
  Future<void> participate(String jogoId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw "Faça login para participar";

    await supabase.from('participacoes').insert({
      'jogo_id': jogoId,
      'usuario_id': user.id,
      'status': 'confirmado',
    });
  }
}
