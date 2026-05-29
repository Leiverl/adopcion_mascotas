import 'package:flutter/material.dart';
import 'package:petcare_mobile/providers/notificaciones_provider.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to get the provider and rebuild when it changes
    return Consumer<NotificacionesProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notificaciones'),
            backgroundColor: AppColors.background,
            actions: [
              if (provider.unreadCount > 0)
                TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: const Text('Marcar todas como leídas'),
                )
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.notificaciones.isEmpty
                  ? const Center(
                      child: Text(
                        'No tienes notificaciones.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.notificaciones.length,
                      itemBuilder: (context, index) {
                        final notificacion = provider.notificaciones[index];
                        return ListTile(
                          leading: notificacion.leida
                              ? const Icon(Icons.notifications_none, color: Colors.grey)
                              : const Icon(Icons.notifications_active, color: AppColors.primary),
                          title: Text(
                            notificacion.titulo,
                            style: TextStyle(
                              fontWeight: notificacion.leida ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${notificacion.cuerpo}\n${DateFormat('dd MMM, HH:mm').format(notificacion.fechaCreacion)}',
                          ),
                          isThreeLine: true,
                          onTap: () {
                            if (!notificacion.leida) {
                              provider.markAsRead(notificacion.id);
                            }
                            // TODO: Implementar navegación a la ruta si existe
                            // if (notificacion.ruta != null) { ... }
                          },
                        );
                      },
                    ),
        );
      },
    );
  }
}