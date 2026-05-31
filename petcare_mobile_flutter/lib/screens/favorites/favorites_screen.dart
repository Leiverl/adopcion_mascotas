import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petcare_mobile/models/pet.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Mis Favoritos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          Consumer<NotificacionesProvider>(
            builder: (context, provider, child) {
              return Badge(
                label: Text(provider.unreadCount.toString()),
                isLabelVisible: provider.unreadCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) => const NotificacionesScreen())),
                  tooltip: 'Notificaciones',
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.favoritePets.isEmpty) {
            return _EmptyState();
          }

          final pets = provider.favoritePets;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              return _FavCard(
                pet: pets[index],
                onRemove: () => provider.toggleFavorite(pets[index]),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => PetDetailScreen(pet: pets[index]))),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Card de favorito ────────────────────────────────────────────────────────
class _FavCard extends StatefulWidget {
  final Pet pet;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  const _FavCard(
      {required this.pet, required this.onRemove, required this.onTap});

  @override
  State<_FavCard> createState() => _FavCardState();
}

class _FavCardState extends State<_FavCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleRemove() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final fotoUrl = widget.pet.galeriaFotos.isNotEmpty
        ? widget.pet.galeriaFotos[0]
        : null;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─ Foto ──────────────────────────────────────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      child: fotoUrl != null
                          ? Image.network(
                              fotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallback(),
                            )
                          : _fallback(),
                    ),
                    // Badge especie
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.pet.especie.toLowerCase() == 'gato'
                                  ? Icons.catching_pokemon
                                  : Icons.pets,
                              size: 11,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.pet.especie,
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón quitar
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: _handleRemove,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ─ Info ──────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pet.nombre,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.pet.raza,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMedium),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${widget.pet.edad}a',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: AppColors.primary.withOpacity(0.08),
        child: const Center(
            child: Icon(Icons.pets, size: 40, color: AppColors.primary)),
      );
}

// ── Estado vacío ──────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline,
              size: 80, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'Aún no tienes favoritos',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Ve a Descubrir y guarda\nlas mascotas que te gusten!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}
