import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'cadastroJogos_form_page.dart';
import 'detalhesJogo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = SupabaseService();
  List jogos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  Future<void> loadGames() async {
    try {
      final data = await service.getGames();
      setState(() {
        jogos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar jogos: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> goToCreateGame() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateGameScreen()),
    );

    // Atualiza lista quando voltar
    loadGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jogos Disponíveis")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : jogos.isEmpty
          ? const Center(child: Text("Nenhum jogo cadastrado"))
          : RefreshIndicator(
              onRefresh: loadGames,
              child: ListView.builder(
                itemCount: jogos.length,
                itemBuilder: (context, index) {
                  final jogo = jogos[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        jogo['esporte'] ?? "Sem esporte",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(jogo['data_hora'] ?? "Sem data"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameDetailsScreen(jogo: jogo),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToCreateGame,
        child: const Icon(Icons.add),
      ),
    );
  }
}
