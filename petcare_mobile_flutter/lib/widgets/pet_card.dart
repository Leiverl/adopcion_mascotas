import 'package:flutter/material.dart';
import 'package:petcare_mobile/models/pet.dart';
import 'package:petcare_mobile/utils/app_colors.dart';

class PetCard extends StatelessWidget {
  final Pet pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // Bordes más redondeados
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de la mascota
          Image.network(
            pet.galeriaFotos.isNotEmpty
                ? pet.galeriaFotos[0]
                : 'https://via.placeholder.com/300', // Placeholder
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, color: Colors.red, size: 50);
            },
          ),
          // Gradiente oscuro en la parte inferior para legibilidad del texto
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120, // Gradiente más alto
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Nombre y edad de la mascota
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.nombre,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                 Text(
                  '${pet.raza}, ${pet.edad} años',
                  style: TextStyle(
                    color: AppColors.textLight.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}