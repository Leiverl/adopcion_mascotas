import 'package:flutter/material.dart';
import 'package:petcare_mobile/providers/auth_provider.dart';
import 'package:petcare_mobile/providers/notificaciones_provider.dart';
import 'package:petcare_mobile/screens/notificaciones_screen.dart';
import 'package:petcare_mobile/screens/profile/my_adoptions_screen.dart';
import 'package:petcare_mobile/screens/profile/my_events_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
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
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('Mis Solicitudes de Adopción'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const MyAdoptionsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('Mis Eventos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const MyEventsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}