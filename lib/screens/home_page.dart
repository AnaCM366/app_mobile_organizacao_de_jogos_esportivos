import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
// Certifique-se de que estes caminhos e nomes de arquivos estão corretos no seu VS Code
import 'detalhesJogo.dart';
import 'cadastroJogos_form_page.dart';

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
      if (mounted) {
        setState(() {
          jogos = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar jogos: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Próximos Jogos"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadGames),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadGames,
              child: jogos.isEmpty
                  ? const Center(child: Text("Nenhum jogo encontrado."))
                  : ListView.builder(
                      itemCount: jogos.length,
                      itemBuilder: (context, index) {
                        final jogo = jogos[index];
                        // Acessa o nome do estabelecimento via join configurado no serviço
                        final local =
                            jogo['estabelecimentos']?['nome'] ??
                            "Local não definido";

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(
                              jogo['esporte'] ?? "Jogo",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("$local\n${jogo['data_hora']}"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              // CORREÇÃO: Usando o nome da CLASSE definida em detalhesJogo.dart
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GameDetailsScreen(jogo: jogo),
                                ),
                              );
                              loadGames(); // Atualiza a lista ao voltar
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // CORREÇÃO: Usando o nome da CLASSE definida em cadastroJogos_form_page.dart
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGameScreen()),
          );
          loadGames(); // Atualiza a lista ao voltar
        },
        label: const Text("Novo Jogo"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
