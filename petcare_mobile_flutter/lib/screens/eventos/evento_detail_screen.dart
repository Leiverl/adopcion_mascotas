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
    // Usamos Consumer para que el botón se reconstruya cuando cambie el estado
    return Consumer<InteraccionesProvider>(
      builder: (context, interaccionesProvider, child) {
        final isInteresado = interaccionesProvider.isInteresado(evento.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                floating: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    evento.titulo,
                    style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 15)]),
                  ),
                  background: Image.network(
                    evento.imagenPrincipal,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
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
                          content: '${DateFormat('EEEE dd MMMM, yyyy', 'es_ES').format(evento.fecha)} a las ${evento.hora}',
                        ),
                        const Divider(height: 30),
                        _buildInfoRow(
                          icon: Icons.location_on,
                          title: 'Ubicación',
                          content: evento.ubicacion,
                        ),
                        const Divider(height: 30),
                        _buildInfoRow(
                          icon: Icons.label,
                          title: 'Categoría',
                          contentWidget: Chip(
                            label: Text(evento.categoria),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        const Divider(height: 30),
                         _buildInfoRow(
                          icon: Icons.storefront,
                          title: 'Organizador',
                          content: evento.organizadorNombre,
                        ),
                        const Divider(height: 30),
                        Text(
                          'Acerca del Evento',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          evento.descripcion,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              interaccionesProvider.toggleInteres(evento);
            },
            label: Text(isInteresado ? 'Ya no me interesa' : 'Me Interesa'),
            icon: Icon(isInteresado ? Icons.star : Icons.star_border),
            backgroundColor: isInteresado ? Colors.amber : AppColors.primary,
            foregroundColor: isInteresado ? Colors.black : Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, String? content, Widget? contentWidget}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              contentWidget ?? Text(content ?? '', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }
}