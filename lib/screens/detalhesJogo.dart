import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class GameDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> jogo;
  const GameDetailsScreen({super.key, required this.jogo});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  final service = SupabaseService();

  // REMOVIDO: userId fixo aqui em cima para evitar erros de inicialização.
  // Vamos buscar o ID dentro dos métodos de forma segura.

  bool jaEstaParticipando = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkParticipation();
  }

  Future<void> _checkParticipation() async {
    try {
      final user = service.supabase.auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final response = await service.supabase
          .from('participacoes')
          .select()
          .eq('jogo_id', widget.jogo['id'])
          .eq('usuario_id', user.id) // Acesso seguro
          .maybeSingle();

      if (mounted) {
        setState(() {
          jaEstaParticipando = response != null;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> handleParticipation() async {
    try {
      setState(() => isLoading = true);

      if (jaEstaParticipando) {
        // Certifique-se que o método leaveGame existe no seu supabase_service.dart
        await service.leaveGame(widget.jogo['id']);
        _showSnackBar("Você saiu da partida!", Colors.orange);
      } else {
        // Certifique-se que o método participate existe no seu supabase_service.dart
        await service.participate(widget.jogo['id']);
        _showSnackBar("Presença confirmada!", Colors.green);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Erro: $e", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                  _infoRow(
                    Icons.calendar_month,
                    "Data: ${widget.jogo['data_hora'] ?? 'Não informada'}",
                    Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  // Acessa o nome do estabelecimento via join feito no getGames()
                  _infoRow(
                    Icons.location_on,
                    "Local: ${widget.jogo['estabelecimentos']?['nome'] ?? 'A definir'}",
                    Colors.red,
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
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showSnackBar("Link de convite copiado!", Colors.blue),
                    icon: const Icon(Icons.share),
                    label: const Text("Convidar Amigos"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
