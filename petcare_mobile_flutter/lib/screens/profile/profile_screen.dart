import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petcare_mobile/providers/auth_provider.dart';
import 'package:petcare_mobile/providers/favorites_provider.dart';
import 'package:petcare_mobile/providers/notificaciones_provider.dart';
import 'package:petcare_mobile/providers/theme_provider.dart';
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
    Provider.of<UserProvider>(context, listen: false).clear();
    Provider.of<FavoritesProvider>(context, listen: false).clear();
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.card(context);
    final bgColor = AppColors.bg(context);
    final txtColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('Mi Perfil',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: txtColor)),
        actions: [
          Consumer<NotificacionesProvider>(
            builder: (context, provider, child) {
              return Badge(
                label: Text(provider.unreadCount.toString()),
                isLabelVisible: provider.unreadCount > 0,
                child: IconButton(
                  icon: Icon(Icons.notifications_outlined,
                      color: txtColor),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) =>
                              const NotificacionesScreen())),
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
          final nombre =
              apiProfile?.nombre ?? authProvider.userNombre ?? 'Usuario';
          final correo =
              apiProfile?.correo ?? authProvider.userCorreo ?? '';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              // ── Header card ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: isDark
                      ? Border.all(
                          color: AppColors.darkDivider, width: 1)
                      : null,
                  boxShadow: isDark
                      ? []
                      : [
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
                            color:
                                AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              size: 30, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: userProvider.isLoading
                              ? _LoadingName(isDark: isDark)
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(nombre,
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.w700,
                                            color: txtColor)),
                                    const SizedBox(height: 2),
                                    Text(correo,
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: subColor)),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _StatChip(
                      icon: Icons.favorite,
                      label: 'Favoritos',
                      value: favsCount.toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Sección: Mi actividad ─────────────────────────
              _SectionLabel('Mi actividad', color: subColor),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.pets,
                iconColor: AppColors.primary,
                title: 'Mis Solicitudes de Adopción',
                subtitle: 'Revisa el estado de tus solicitudes',
                isDark: isDark,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const MyAdoptionsScreen())),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.event_available,
                iconColor: Colors.blueAccent,
                title: 'Mis Eventos',
                subtitle: 'Eventos en los que te has inscrito',
                isDark: isDark,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const MyEventsScreen())),
              ),

              const SizedBox(height: 24),

              // ── Sección: Preferencias ────────────────────────
              _SectionLabel('Preferencias', color: subColor),
              const SizedBox(height: 10),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return _ToggleTile(
                    icon: themeProvider.isDark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    iconColor: themeProvider.isDark
                        ? const Color(0xFF9575CD)
                        : const Color(0xFFFFB300),
                    title: 'Modo oscuro',
                    subtitle: themeProvider.isDark
                        ? 'Tema oscuro activado'
                        : 'Tema claro activado',
                    value: themeProvider.isDark,
                    isDark: isDark,
                    onChanged: (_) => themeProvider.toggle(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Sección: Cuenta ──────────────────────────────
              _SectionLabel('Cuenta', color: subColor),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.logout,
                iconColor: Colors.redAccent,
                title: 'Cerrar Sesión',
                subtitle: 'Salir de tu cuenta',
                danger: true,
                isDark: isDark,
                onTap: _logout,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color));
  }
}

class _LoadingName extends StatelessWidget {
  final bool isDark;
  const _LoadingName({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final shimmer =
        isDark ? const Color(0xFF2C2C3E) : Colors.grey.shade200;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 120,
            height: 14,
            decoration: BoxDecoration(
                color: shimmer,
                borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 6),
        Container(
            width: 180,
            height: 11,
            decoration: BoxDecoration(
                color: shimmer,
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
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
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
                  fontSize: 12,
                  color: AppColors.textSub(context))),
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
  final bool isDark;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.card(context);
    final txtColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: AppColors.darkDivider, width: 1)
              : null,
          boxShadow: isDark
              ? []
              : [
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
                color: iconColor.withOpacity(0.12),
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
                              : txtColor)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: subColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: subColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.card(context);
    final txtColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppColors.darkDivider, width: 1)
            : null,
        boxShadow: isDark
            ? []
            : [
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
              color: iconColor.withOpacity(0.12),
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
                        color: txtColor)),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: subColor)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
