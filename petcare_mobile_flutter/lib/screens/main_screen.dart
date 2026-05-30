import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petcare_mobile/screens/chat/chat_screen.dart';
import 'package:petcare_mobile/screens/discover/discover_screen.dart';
import 'package:petcare_mobile/screens/favorites/favorites_screen.dart';
import 'package:petcare_mobile/screens/eventos/eventos_screen.dart';
import 'package:petcare_mobile/screens/profile/profile_screen.dart';
import 'package:petcare_mobile/utils/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DiscoverScreen(),
    FavoritesScreen(),
    ChatScreen(),
    EventosScreen(),
    ProfileScreen(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Descubrir'),
    _NavItem(icon: Icons.favorite_outline, activeIcon: Icons.favorite, label: 'Favoritos'),
    _NavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Chat'),
    _NavItem(icon: Icons.event_outlined, activeIcon: Icons.event, label: 'Eventos'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil'),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: _selectedIndex,
        items: _navItems,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = index == selectedIndex;
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isActive ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? AppColors.primary : AppColors.textMedium,
                        size: 24,
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: isActive
                          ? Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                item.label,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
