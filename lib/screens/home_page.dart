import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
// Os nomes dos arquivos (em minúsculo) devem ser exatamente estes:
import 'cadastro_jogo.dart';
import 'detalhes_jogo.dart';

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
            content: Text("Erro ao carregar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Próximos Jogos")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadGames,
              child: ListView.builder(
                itemCount: jogos.length,
                itemBuilder: (context, index) {
                  final jogo = jogos[index];
                  // Busca o nome do estabelecimento via relação do Supabase
                  final local =
                      jogo['estabelecimentos']?['nome'] ?? "Local não definido";

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(jogo['esporte'] ?? "Jogo"),
                      subtitle: Text("$local\n${jogo['data_hora']}"),
                      onTap: () async {
                        // O nome 'DetalhesJogoPage' deve existir no arquivo detalhes_jogo.dart
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => detalhesJogo.dart(jogo: jogo),
                          ),
                        );
                        loadGames();
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // O nome 'CadastroJogosFormPage' deve existir no arquivo cadastro_jogo.dart
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const cadastroJogos_form_page.dart(),
            ),
          );
          loadGames();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
