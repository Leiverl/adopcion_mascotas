import 'package:flutter/material.dart';
import 'package:petcare_mobile/providers/favorites_provider.dart';
import 'package:petcare_mobile/providers/notificaciones_provider.dart';
import 'package:petcare_mobile/screens/notificaciones_screen.dart';
import 'package:petcare_mobile/screens/pet_detail/pet_detail_screen.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        backgroundColor: AppColors.background,
        elevation: 0,
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
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.favoritePets.isEmpty) {
            return const Center(
              child: Text(
                'Aún no tienes mascotas favoritas.\n¡Ve a Descubrir y guarda algunas!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.favoritePets.length,
            itemBuilder: (context, index) {
              final pet = provider.favoritePets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(pet.galeriaFotos.isNotEmpty
                        ? pet.galeriaFotos[0]
                        : 'https://via.placeholder.com/150'),
                  ),
                  title: Text(pet.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(pet.raza),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.pink),
                    onPressed: () {
                      // Permite quitar de favoritos desde esta pantalla también
                      provider.toggleFavorite(pet);
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => PetDetailScreen(pet: pet),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}