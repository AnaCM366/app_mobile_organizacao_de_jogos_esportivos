import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final service = SupabaseService(); // CORREÇÃO: Usando a Classe correta
  bool isLoading = false;

  Future<void> cadastrar() async {
    if (nomeController.text.isEmpty ||
        emailController.text.isEmpty ||
        senhaController.text.isEmpty) {
      _msg("Preencha tudo!");
      return;
    }

    setState(() => isLoading = true);
    try {
      await service.register(
        emailController.text.trim(),
        senhaController.text.trim(),
        nomeController.text.trim(),
      );
      if (mounted) {
        _msg("Cadastro realizado!", cor: Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _msg("Erro: $e", cor: Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _msg(String m, {Color cor = Colors.orange}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(m), backgroundColor: cor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Conta")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: senhaController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: cadastrar,
                    child: const Text("Finalizar Registro"),
                  ),
          ],
        ),
      ),
    );
  }
}
