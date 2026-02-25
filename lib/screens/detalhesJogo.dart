import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameDetailsScreen extends StatelessWidget {
  final Map jogo;
  final service = SupabaseService();

  GameDetailsScreen({required this.jogo});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("Detalhes")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Esporte: ${jogo['esporte']}"),
            Text("Data: ${jogo['data_hora']}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await service.participate(jogo['id'], user!.id);
              },
              child: Text("Ingressar"),
            ),
          ],
        ),
      ),
    );
  }
}
