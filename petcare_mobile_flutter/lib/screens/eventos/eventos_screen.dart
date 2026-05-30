import 'package:flutter/material.dart';
import 'package:petcare_mobile/api/eventos_service.dart';
import 'package:petcare_mobile/models/evento.dart';
import 'package:petcare_mobile/providers/notificaciones_provider.dart';
import 'package:petcare_mobile/screens/notificaciones_screen.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:petcare_mobile/widgets/evento_card.dart';
import 'package:provider/provider.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  late Future<List<Evento>> _eventosFuture;
  final EventosService _eventosService = EventosService();

  @override
  void initState() {
    super.initState();
    _eventosFuture = _eventosService.getEventos();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dos pestañas: Próximos y Pasados
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Eventos'),
          backgroundColor: AppColors.background,
          // --- INICIO DE LA MODIFICACIÓN ---
          actions: [
            Consumer<NotificacionesProvider>(
              builder: (context, provider, child) {
                return Badge(
                  label: Text(provider.unreadCount.toString()),
                  isLabelVisible: provider.unreadCount > 0,
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => const NotificacionesScreen(),
                      ));
                    },
                    tooltip: 'Notificaciones',
                  ),
                );
              },
            ),
          ],
          // --- FIN DE LA MODIFICACIÓN ---
          bottom: const TabBar(
            tabs: [
              Tab(text: 'PRÓXIMOS'),
              Tab(text: 'PASADOS'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: FutureBuilder<List<Evento>>(
          future: _eventosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay eventos programados.',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              );
            }

            final hoy = DateTime.now();
            final eventos = snapshot.data!;
            
            final proximosEventos = eventos.where((e) => e.fecha.isAfter(hoy) || e.fecha.isAtSameMomentAs(hoy)).toList();
            final eventosPasados = eventos.where((e) => e.fecha.isBefore(hoy)).toList();

            return TabBarView(
              children: [
                _buildEventosList(proximosEventos, 'No hay eventos próximos.'),
                _buildEventosList(eventosPasados, 'No hay eventos pasados.'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventosList(List<Evento> eventos, String noEventsMessage) {
    if (eventos.isEmpty) {
      return Center(
        child: Text(noEventsMessage,
            style: const TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: eventos.length,
      itemBuilder: (ctx, index) => EventoCard(evento: eventos[index]),
    );
  }
}