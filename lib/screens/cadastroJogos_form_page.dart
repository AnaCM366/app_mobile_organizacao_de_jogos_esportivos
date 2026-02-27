import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final esporteController = TextEditingController();
  final service = SupabaseService();
  bool isLoading = false;

  Future<void> salvarJogo() async {
    final esporte = esporteController.text.trim();

    if (esporte.isEmpty) {
      _showSnackBar("Informe o esporte", Colors.orange);
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showSnackBar(
        "Usuário não autenticado. Faça login novamente.",
        Colors.red,
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      await service.createGame(esporte);

      if (mounted) {
        _showSnackBar("Jogo criado com sucesso!", Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Erro ao salvar jogo: $e", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String mensagem, Color cor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
  }

  @override
  void dispose() {
    esporteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Novo Jogo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: esporteController,
              decoration: const InputDecoration(
                labelText: "Qual o esporte?",
                hintText: "Ex: Futebol, Vôlei, Basquete",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_soccer),
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: salvarJogo,
                      child: const Text("Salvar Jogo"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
