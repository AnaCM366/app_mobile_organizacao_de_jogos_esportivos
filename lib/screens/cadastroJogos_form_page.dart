import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});
  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final esporteController = TextEditingController();
  final dataController = TextEditingController();
  final service = SupabaseService();
  String? localSelecionado;
  List estabelecimentos = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocais();
  }

  _loadLocais() async {
    try {
      final dados = await service.getEstablishments();
      setState(() => estabelecimentos = dados);
    } catch (e) {
      debugPrint("Erro ao carregar locais: $e");
    }
  }

  void salvar() async {
    if (!_formKey.currentState!.validate() || localSelecionado == null) return;
    setState(() => isLoading = true);
    try {
      await service.createGame(
        esporte: esporteController.text,
        dataHora: dataController.text,
        estabelecimentoId: localSelecionado!,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Novo Jogo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Estilo conforme imagem 539906.png
              TextFormField(
                controller: esporteController,
                decoration: const InputDecoration(
                  labelText: "Qual o esporte?",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_soccer),
                ),
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dataController,
                decoration: const InputDecoration(
                  labelText: "Data e Hora",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: localSelecionado,
                isExpanded: true,
                hint: const Text("Selecione o Local"),
                decoration: const InputDecoration(
                  labelText: "Local do Jogo",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                items: estabelecimentos
                    .map(
                      (e) => DropdownMenuItem(
                        value: e['id'].toString(),
                        child: Text(e['nome']),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => localSelecionado = v),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: salvar,
                        child: const Text("Salvar Jogo"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
