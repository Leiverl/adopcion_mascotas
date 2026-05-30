import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:petcare_mobile/api/pet_service.dart';
import 'package:petcare_mobile/models/pet.dart';
import 'package:petcare_mobile/providers/favorites_provider.dart';
import 'package:petcare_mobile/providers/notificaciones_provider.dart';
import 'package:petcare_mobile/screens/notificaciones_screen.dart';
import 'package:petcare_mobile/screens/pet_detail/pet_detail_screen.dart';
import 'package:petcare_mobile/widgets/filter_bottom_sheet.dart';
import 'package:petcare_mobile/widgets/pet_card.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late Future<List<Pet>> _petsFuture;
  final PetService _petService = PetService();
  final CardSwiperController _swiperController = CardSwiperController();
  late ConfettiController _confettiController;
  int _currentCardIndex = 0;

  Map<String, String> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    _loadPets();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 500));
  }

  void _loadPets() {
    setState(() {
      _petsFuture = _petService.getPets(filters: _currentFilters);
    });
  }

  void _showFilterPanel() async {
    final newFilters = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => FilterBottomSheet(initialFilters: _currentFilters),
    );
    if (newFilters != null) {
      setState(() {
        _currentFilters = newFilters;
        _loadPets();
      });
    }
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _onFavorite(Pet pet, FavoritesProvider provider) async {
    final bool isCurrentlyFavorite = provider.isFavorite(pet.id);
    if (!isCurrentlyFavorite) {
      _confettiController.play();
    }
    final message = await provider.toggleFavorite(pet);
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              message.contains('Añadido') ? Colors.green : Colors.blueGrey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descubrir Mascotas'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterPanel,
            tooltip: 'Filtrar',
          ),
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
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          FutureBuilder<List<Pet>>(
            future: _petsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay mascotas con esos filtros.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final pets = snapshot.data!;

              // ── Caso: una sola mascota ────────────────────────────────
              if (pets.length == 1) {
                final singlePet = pets[0];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: PetCard(pet: singlePet),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 88, top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: Icons.article_outlined,
                                color: Colors.blue,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        PetDetailScreen(pet: singlePet),
                                  ));
                                },
                              ),
                              _buildActionButton(
                                icon: Icons.favorite,
                                color: Colors.pink,
                                onPressed: () =>
                                    _onFavorite(singlePet, favoritesProvider),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // ── Caso: múltiples mascotas con swiper ────────────────────
              return Column(
                children: [
                  Expanded(
                    child: CardSwiper(
                      controller: _swiperController,
                      cardsCount: pets.length,
                      onSwipe: (prev, current, direction) {
                        // FIX: ya NO se añade favorito al deslizar a la derecha.
                        // El favorito solo se agrega desde el botón de corazón.
                        setState(() {
                          _currentCardIndex = current ?? 0;
                        });
                        return true;
                      },
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      cardBuilder: (context, index, ht, vt) =>
                          PetCard(pet: pets[index]),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      // 88px = altura aprox del nav flotante (16 margen + 56 barra)
                      padding: const EdgeInsets.only(bottom: 88, top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.close,
                            color: Colors.red,
                            onPressed: () => _swiperController
                                .swipe(CardSwiperDirection.left),
                          ),
                          _buildActionButton(
                            icon: Icons.article_outlined,
                            color: Colors.blue,
                            size: 30,
                            onPressed: () {
                              if (_currentCardIndex < pets.length) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PetDetailScreen(
                                      pet: pets[_currentCardIndex]),
                                ));
                              }
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.favorite,
                            color: Colors.pink,
                            // FIX: el corazón añade favorito directamente
                            // sin hacer swipe, para no confundir los gestos.
                            onPressed: () =>
                                _onFavorite(pets[_currentCardIndex], favoritesProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.pink, Colors.red, Colors.purple],
            createParticlePath: (size) {
              final path = Path();
              path.moveTo(size.width / 2, size.height / 5);
              path.cubicTo(size.width / 2, size.height / 5,
                  size.width / 10, size.height / 2.5, size.width / 2, size.height);
              path.cubicTo(size.width / 2, size.height,
                  size.width - (size.width / 10), size.height / 2.5,
                  size.width / 2, size.height / 5);
              return path;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 40,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        iconSize: size,
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
