import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class GameDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> jogo;
  const GameDetailsScreen({super.key, required this.jogo});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  final service = SupabaseService();
  final userId = Supabase.instance.client.auth.currentUser?.id;

  // Variável para controlar se o usuário está na partida localmente
  bool jaEstaParticipando = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkParticipation();
  }

  // Verifica se o usuário logado já está na lista de participações deste jogo
  Future<void> _checkParticipation() async {
    try {
      final response = await service.supabase
          .from('participacoes')
          .select()
          .eq('jogo_id', widget.jogo['id'])
          .eq('usuario_id', userId!)
          .maybeSingle();

      setState(() {
        jaEstaParticipando = response != null;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleParticipation() async {
    try {
      setState(() => isLoading = true);

      if (jaEstaParticipando) {
        // Usa a função que você já tem no service
        await service.leaveGame(widget.jogo['id']);
        _showSnackBar("Você saiu da partida!", Colors.orange);
      } else {
        // Usa a função que você já tem no service
        await service.participate(widget.jogo['id']);
        _showSnackBar("Presença confirmada!", Colors.green);
      }

      Navigator.pop(context); // Volta para atualizar a Home
    } catch (e) {
      _showSnackBar("Erro: $e", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String mensagem, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes do Jogo")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jogo['esporte'] ?? "Sem esporte",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        "Data: ${widget.jogo['data_hora'] ?? 'Não informada'}",
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      // Aqui acessamos o nome do estabelecimento que veio do Join no getGames()
                      Text(
                        "Local: ${widget.jogo['estabelecimentos']?['nome'] ?? 'A definir'}",
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text(
                    "Ações:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jaEstaParticipando
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isLoading ? null : handleParticipation,
                      child: Text(
                        jaEstaParticipando
                            ? "SAIR DO JOGO"
                            : "PARTICIPAR DO JOGO",
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Requisito 5: Convite (Simples botão de compartilhar)
                  OutlinedButton.icon(
                    onPressed: () {
                      _showSnackBar("Link de convite copiado!", Colors.blue);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text("Convidar Amigos"),
                  ),
                ],
              ),
            ),
    );
  }
}
