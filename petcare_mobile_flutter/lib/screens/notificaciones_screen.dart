import 'package:flutter/material.dart';
import 'package:petcare_mobile/providers/notificaciones_provider.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.bg(context);
    final txtColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);

    return Consumer<NotificacionesProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            title: Text('Notificaciones', style: TextStyle(color: txtColor)),
            iconTheme: IconThemeData(color: txtColor),
            actions: [
              if (provider.unreadCount > 0)
                TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: const Text('Marcar todas como leídas'),
                ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.notificaciones.isEmpty
                  ? Center(
                      child: Text(
                        'No tienes notificaciones.',
                        style: TextStyle(fontSize: 18, color: subColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.notificaciones.length,
                      itemBuilder: (context, index) {
                        final n = provider.notificaciones[index];
                        return ListTile(
                          leading: n.leida
                              ? Icon(Icons.notifications_none, color: subColor)
                              : const Icon(Icons.notifications_active,
                                  color: AppColors.primary),
                          title: Text(
                            n.titulo,
                            style: TextStyle(
                              color: txtColor,
                              fontWeight: n.leida
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${n.cuerpo}\n${DateFormat('dd MMM, HH:mm').format(n.fechaCreacion)}',
                            style: TextStyle(color: subColor),
                          ),
                          isThreeLine: true,
                          onTap: () {
                            if (!n.leida) provider.markAsRead(n.id);
                          },
                        );
                      },
                    ),
        );
      },
    );
  }
}
