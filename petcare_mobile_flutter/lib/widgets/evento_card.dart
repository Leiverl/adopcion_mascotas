import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petcare_mobile/models/evento.dart';
import 'package:petcare_mobile/screens/eventos/evento_detail_screen.dart'; // <-- IMPORTAR

class EventoCard extends StatelessWidget {
  final Evento evento;
  const EventoCard({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 5,
      child: InkWell( // <-- ENVOLVEMOS CON INKWELL PARA EL EFECTO RIPPLE
        onTap: () {
          // Navegamos a la pantalla de detalle
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => EventoDetailScreen(evento: evento),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              evento.imagenPrincipal,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('dd MMMM, yyyy', 'es_ES').format(evento.fecha)} - ${evento.hora}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(evento.ubicacion, style: const TextStyle(color: Colors.grey))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}