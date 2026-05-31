import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petcare_mobile/providers/auth_provider.dart';
import 'package:petcare_mobile/providers/favorites_provider.dart';
import 'package:petcare_mobile/providers/notificaciones_provider.dart';
import 'package:petcare_mobile/providers/user_provider.dart';
import 'package:petcare_mobile/screens/notificaciones_screen.dart';
import 'package:petcare_mobile/screens/profile/my_adoptions_screen.dart';
import 'package:petcare_mobile/screens/profile/my_events_screen.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).fetchProfile();
      }
    });
  }

  void _logout() {
    // Limpiar todos los providers antes de cerrar sesión
    Provider.of<UserProvider>(context, listen: false).clear();
    Provider.of<FavoritesProvider>(context, listen: false).clear();
    // El AuthProvider dispara la navegación via AuthWrapper
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Mi Perfil',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 20)),
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
      body: Consumer2<UserProvider, FavoritesProvider>(
        builder: (context, userProvider, favProvider, _) {
          final apiProfile = userProvider.profile;
          final favsCount = favProvider.favoritePets.length;
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);

          final nombre = apiProfile?.nombre ??
              authProvider.userNombre ??
              'Usuario';
          final correo = apiProfile?.correo ??
              authProvider.userCorreo ??
              '';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              // ── Header ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              size: 30, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: userProvider.isLoading
                              ? _LoadingName()
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombre,
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      correo,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textMedium),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.favorite,
                          label: 'Favoritos',
                          value: favsCount.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text('Mi actividad',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMedium)),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.pets,
                iconColor: AppColors.primary,
                title: 'Mis Solicitudes de Adopción',
                subtitle: 'Revisa el estado de tus solicitudes',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const MyAdoptionsScreen())),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.event_available,
                iconColor: Colors.blueAccent,
                title: 'Mis Eventos',
                subtitle: 'Eventos en los que te has inscrito',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const MyEventsScreen())),
              ),

              const SizedBox(height: 20),

              Text('Cuenta',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMedium)),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.logout,
                iconColor: Colors.redAccent,
                title: 'Cerrar Sesión',
                subtitle: 'Salir de tu cuenta',
                danger: true,
                onTap: _logout,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 120, height: 14,
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 6),
        Container(
            width: 180, height: 11,
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8))),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.primary)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textMedium)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: danger
                              ? Colors.redAccent
                              : AppColors.textDark)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textMedium)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textMedium.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
