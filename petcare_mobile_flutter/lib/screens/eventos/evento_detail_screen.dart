import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petcare_mobile/models/evento.dart';
import 'package:petcare_mobile/providers/interacciones_provider.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:provider/provider.dart';

class EventoDetailScreen extends StatelessWidget {
  final Evento evento;
  const EventoDetailScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.bg(context);
    final txtColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);

    return Consumer<InteraccionesProvider>(
      builder: (context, interaccionesProvider, child) {
        final isInteresado = interaccionesProvider.isInteresado(evento.id);
        return Scaffold(
          backgroundColor: bgColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                floating: true,
                stretch: true,
                backgroundColor: bgColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    evento.titulo,
                    style: const TextStyle(
                        shadows: [Shadow(color: Colors.black, blurRadius: 15)]),
                  ),
                  background: Image.network(
                    evento.imagenPrincipal,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        Icon(Icons.error, color: subColor),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          title: 'Fecha y Hora',
                          content:
                              '${DateFormat('EEEE dd MMMM, yyyy', 'es_ES').format(evento.fecha)} a las ${evento.hora}',
                          txtColor: txtColor, subColor: subColor,
                        ),
                        Divider(height: 30, color: AppColors.div(context)),
                        _buildInfoRow(
                          icon: Icons.location_on,
                          title: 'Ubicación',
                          content: evento.ubicacion,
                          txtColor: txtColor, subColor: subColor,
                        ),
                        Divider(height: 30, color: AppColors.div(context)),
                        _buildInfoRow(
                          icon: Icons.label,
                          title: 'Categoría',
                          contentWidget: Chip(
                            label: Text(evento.categoria),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          ),
                          txtColor: txtColor, subColor: subColor,
                        ),
                        Divider(height: 30, color: AppColors.div(context)),
                        _buildInfoRow(
                          icon: Icons.storefront,
                          title: 'Organizador',
                          content: evento.organizadorNombre,
                          txtColor: txtColor, subColor: subColor,
                        ),
                        Divider(height: 30, color: AppColors.div(context)),
                        Text('Acerca del Evento',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: txtColor)),
                        const SizedBox(height: 10),
                        Text(evento.descripcion,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    height: 1.5,
                                    color: isDark
                                        ? AppColors.darkTextMedium
                                        : Colors.black54)),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => interaccionesProvider.toggleInteres(evento),
            label: Text(isInteresado ? 'Ya no me interesa' : 'Me Interesa'),
            icon: Icon(isInteresado ? Icons.star : Icons.star_border),
            backgroundColor: isInteresado ? Colors.amber : AppColors.primary,
            foregroundColor: isInteresado ? Colors.black : Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    String? content,
    Widget? contentWidget,
    required Color txtColor,
    required Color subColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: txtColor)),
              const SizedBox(height: 4),
              contentWidget ??
                  Text(content ?? '',
                      style: TextStyle(fontSize: 16, color: subColor)),
            ],
          ),
        ),
      ],
    );
  }
}
