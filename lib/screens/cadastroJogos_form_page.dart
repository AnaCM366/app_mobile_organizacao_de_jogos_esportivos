import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Correção do erro de formatação
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
  final horaController = TextEditingController();

  DateTime? dataSelecionada;
  TimeOfDay? horaSelecionada;

  final service = SupabaseService();
  String? localSelecionado;
  List<dynamic> estabelecimentos =
      []; // Tipagem dinâmica para evitar erro de cast
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocais();
  }

  Future<void> _loadLocais() async {
    try {
      final dados = await service.getEstablishments();
      setState(() => estabelecimentos = dados);
    } catch (e) {
      debugPrint("Erro ao carregar locais: $e");
    }
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dataSelecionada = picked;
        dataController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selecionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        horaSelecionada = picked;
        if (mounted) {
          horaController.text = picked.format(context);
        }
      });
    }
  }

  void salvar() async {
    if (!_formKey.currentState!.validate() ||
        localSelecionado == null ||
        dataSelecionada == null ||
        horaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Cria o objeto DateTime combinando os seletores
      final dataFinal = DateTime(
        dataSelecionada!.year,
        dataSelecionada!.month,
        dataSelecionada!.day,
        horaSelecionada!.hour,
        horaSelecionada!.minute,
      );

      // Certifique-se que o método createGame no seu service aceita String ou DateTime
      await service.createGame(
        esporte: esporteController.text,
        dataHora: dataFinal.toIso8601String(),
        estabelecimentoId: localSelecionado!,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Novo Jogo"),
      ), // Corrigido de app_bar para appBar
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: esporteController,
                decoration: const InputDecoration(
                  labelText: "Qual o esporte?",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_soccer),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dataController,
                readOnly: true,
                onTap: _selecionarData,
                decoration: const InputDecoration(
                  labelText: "Data do Jogo",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Selecione a data" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: horaController,
                readOnly: true,
                onTap: _selecionarHora,
                decoration: const InputDecoration(
                  labelText: "Horário",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Selecione a hora" : null,
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
                items: estabelecimentos.map((e) {
                  return DropdownMenuItem<String>(
                    value: e['id'].toString(),
                    child: Text(e['nome'] ?? 'Local sem nome'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => localSelecionado = v),
                validator: (v) => v == null ? "Selecione um local" : null,
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
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
