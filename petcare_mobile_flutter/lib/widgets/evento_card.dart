import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:petcare_mobile/models/evento.dart';
import 'package:petcare_mobile/screens/eventos/evento_detail_screen.dart';
import 'package:petcare_mobile/utils/app_colors.dart';

class EventoCard extends StatelessWidget {
  final Evento evento;
  const EventoCard({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = AppColors.textSub(context);
    final txtColor = AppColors.text(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: isDark ? 0 : 5,
      color: AppColors.card(context),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (ctx) => EventoDetailScreen(evento: evento)),
        ),
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
                color: isDark ? AppColors.darkSurface : Colors.grey[300],
                child: Icon(Icons.image_not_supported,
                    color: subColor, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento.titulo,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: txtColor)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: subColor),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('dd MMMM, yyyy', 'es_ES').format(evento.fecha)} - ${evento.hora}',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: subColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: subColor),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(evento.ubicacion,
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: subColor))),
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
