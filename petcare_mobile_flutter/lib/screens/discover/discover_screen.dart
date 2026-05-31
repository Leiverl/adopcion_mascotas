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

class _DiscoverScreenState extends State<DiscoverScreen>
    with TickerProviderStateMixin {
  late Future<List<Pet>> _petsFuture;
  final PetService _petService = PetService();
  final CardSwiperController _swiperController = CardSwiperController();
  late ConfettiController _confettiController;

  late AnimationController _heartAnimController;
  late Animation<double> _heartScale;
  late Animation<double> _heartOpacity;
  bool _showHeartOverlay = false;

  OverlayEntry? _toastEntry;

  int _currentCardIndex = 0;
  Map<String, String> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    _loadPets();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 600));
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(
        CurvedAnimation(parent: _heartAnimController, curve: Curves.easeInOut));
    _heartOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartAnimController);
    _heartAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _showHeartOverlay = false);
      }
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _confettiController.dispose();
    _heartAnimController.dispose();
    _toastEntry?.remove();
    super.dispose();
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

  void _showTopToast(String message, {bool isAdd = true}) {
    _toastEntry?.remove();
    _toastEntry = null;
    final entry = OverlayEntry(
      builder: (context) => _TopToast(message: message, isAdd: isAdd),
    );
    _toastEntry = entry;
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(milliseconds: 1800), () {
      entry.remove();
      if (_toastEntry == entry) _toastEntry = null;
    });
  }

  Future<void> _onFavorite(Pet pet, FavoritesProvider provider) async {
    final bool isAdding = !provider.isFavorite(pet.id);
    if (isAdding) {
      setState(() => _showHeartOverlay = true);
      _heartAnimController.forward(from: 0);
      _confettiController.play();
    }
    final message = await provider.toggleFavorite(pet);
    if (mounted) _showTopToast(message, isAdd: isAdding);
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text('No hay mascotas con esos filtros.',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                );
              }

              final pets = snapshot.data!;

              // ── Botones — usa Consumer para leer isFavorite reactivamente ──
              Widget actionButtons({
                bool showSkip = true,
                required Pet currentPet,
                required VoidCallback onInfo,
              }) {
                return Consumer<FavoritesProvider>(
                  builder: (context, favProvider, _) {
                    final isFav = favProvider.isFavorite(currentPet.id);
                    return SafeArea(
                      top: false,
                      child: Padding(
                        // ↑ más espacio arriba para que los botones bajen
                        padding:
                            const EdgeInsets.only(bottom: 96, top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Botón SKIP (flecha adelante)
                            if (showSkip)
                              _ActionButton(
                                icon: Icons.arrow_forward_rounded,
                                color: Colors.orange,
                                onPressed: () => _swiperController
                                    .swipe(CardSwiperDirection.left),
                              ),
                            // Botón INFO
                            _ActionButton(
                              icon: Icons.article_outlined,
                              color: Colors.blueAccent,
                              size: 28,
                              onPressed: onInfo,
                            ),
                            // Botón FAVORITO — outline si no es fav, relleno si sí
                            _ActionButton(
                              icon: isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFav
                                  ? AppColors.primary
                                  : Colors.grey,
                              onPressed: () =>
                                  _onFavorite(currentPet, favProvider),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              // ── Caso: una sola mascota ────────────────────────────
              if (pets.length == 1) {
                final pet = pets[0];
                return Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: PetCard(pet: pet),
                      ),
                    ),
                    actionButtons(
                      showSkip: false,
                      currentPet: pet,
                      onInfo: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => PetDetailScreen(pet: pet))),
                    ),
                  ],
                );
              }

              // ── Caso: múltiples mascotas ───────────────────────────
              return Column(
                children: [
                  Expanded(
                    child: CardSwiper(
                      controller: _swiperController,
                      cardsCount: pets.length,
                      onSwipe: (prev, current, direction) {
                        setState(() => _currentCardIndex = current ?? 0);
                        return true;
                      },
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      cardBuilder: (context, index, ht, vt) =>
                          PetCard(pet: pets[index]),
                    ),
                  ),
                  actionButtons(
                    currentPet: pets[_currentCardIndex],
                    onInfo: () {
                      if (_currentCardIndex < pets.length) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => PetDetailScreen(
                                pet: pets[_currentCardIndex])));
                      }
                    },
                  ),
                ],
              );
            },
          ),

          // ── Corazón flotante animado ──────────────────────────────
          if (_showHeartOverlay)
            Center(
              child: AnimatedBuilder(
                animation: _heartAnimController,
                builder: (_, __) => Opacity(
                  opacity: _heartOpacity.value,
                  child: Transform.scale(
                    scale: _heartScale.value,
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.primary,
                      size: 120,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 20)],
                    ),
                  ),
                ),
              ),
            ),

          // ── Confetti ─────────────────────────────────────────────
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
}

// ── Botón de acción circular ──────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double size;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        iconSize: size,
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        padding: const EdgeInsets.all(14),
      ),
    );
  }
}

// ── Toast superior ──────────────────────────────────────────────────────
class _TopToast extends StatefulWidget {
  final String message;
  final bool isAdd;
  const _TopToast({required this.message, required this.isAdd});

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: widget.isAdd ? AppColors.primary : Colors.blueGrey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isAdd ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
