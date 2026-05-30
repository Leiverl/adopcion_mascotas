import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petcare_mobile/models/pet.dart';
import 'package:petcare_mobile/utils/app_colors.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const PetCard({
    super.key,
    required this.pet,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final fotoUrl = pet.galeriaFotos.isNotEmpty ? pet.galeriaFotos[0] : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Foto ──────────────────────────────────────────────
          fotoUrl != null
              ? Image.network(
                  fotoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _photoFallback(),
                )
              : _photoFallback(),

          // ── Gradiente inferior ────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // ── Chips superiores (especie + tamaño) ───────────────
          Positioned(
            top: 16,
            left: 16,
            child: Row(
              children: [
                _InfoChip(
                  icon: pet.especie.toLowerCase() == 'gato'
                      ? Icons.catching_pokemon
                      : Icons.pets,
                  label: pet.especie,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.straighten,
                  label: pet.tamano,
                ),
              ],
            ),
          ),

          // ── Botón favorito ────────────────────────────────────
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFavorite
                      ? AppColors.primary.withOpacity(0.9)
                      : Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.white : AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),

          // ── Info inferior ─────────────────────────────────────
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Text(
                  pet.nombre,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Raza + edad + sexo
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pet.raza,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _PillBadge(
                      label: '${pet.edad} ${pet.edad == 1 ? "año" : "años"}',
                    ),
                    const SizedBox(width: 6),
                    _PillBadge(label: pet.sexo),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoFallback() {
    return Container(
      color: AppColors.primary.withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.pets, size: 72, color: AppColors.primary),
      ),
    );
  }
}

// ── Chip de info superior ────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge de pill inferior ───────────────────────────────────────────
class _PillBadge extends StatelessWidget {
  final String label;
  const _PillBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
