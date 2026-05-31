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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.bg(context);
    final tabIndicatorColor = AppColors.primary;
    final unselectedTab = isDark ? AppColors.darkTextMedium : Colors.grey;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: const Text('Eventos'),
          actions: [
            Consumer<NotificacionesProvider>(
              builder: (context, provider, child) => Badge(
                label: Text(provider.unreadCount.toString()),
                isLabelVisible: provider.unreadCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const NotificacionesScreen())),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: const [Tab(text: 'PRÓXIMOS'), Tab(text: 'PASADOS')],
            labelColor: tabIndicatorColor,
            unselectedLabelColor: unselectedTab,
            indicatorColor: tabIndicatorColor,
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
              return Center(
                child: Text('No hay eventos programados.',
                    style: TextStyle(fontSize: 18, color: AppColors.textSub(context))),
              );
            }
            final hoy = DateTime.now();
            final eventos = snapshot.data!;
            final proximos = eventos.where((e) => !e.fecha.isBefore(hoy)).toList();
            final pasados = eventos.where((e) => e.fecha.isBefore(hoy)).toList();
            return TabBarView(children: [
              _buildList(proximos, 'No hay eventos próximos.', context),
              _buildList(pasados, 'No hay eventos pasados.', context),
            ]);
          },
        ),
      ),
    );
  }

  Widget _buildList(List<Evento> eventos, String msg, BuildContext context) {
    if (eventos.isEmpty) {
      return Center(
        child: Text(msg, style: TextStyle(fontSize: 18, color: AppColors.textSub(context))),
      );
    }
    return ListView.builder(
      itemCount: eventos.length,
      itemBuilder: (ctx, i) => EventoCard(evento: eventos[i]),
    );
  }
}
