import 'package:flutter/material.dart';
import 'package:petcare_mobile/providers/interacciones_provider.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:petcare_mobile/widgets/evento_card.dart';
import 'package:provider/provider.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Eventos de Interés'),
        backgroundColor: AppColors.background,
      ),
      body: Consumer<InteraccionesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.misEventos.isEmpty) {
            return const Center(
              child: Text(
                'No has marcado ningún evento como interesante.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final misEventos = provider.misEventos;

          return ListView.builder(
            itemCount: misEventos.length,
            itemBuilder: (ctx, index) => EventoCard(evento: misEventos[index]),
          );
        },
      ),
    );
  }
}