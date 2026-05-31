import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petcare_mobile/api/adoption_service.dart';
import 'package:petcare_mobile/models/adoption_request.dart';
import 'package:petcare_mobile/screens/chat/chat_screen.dart';
import 'package:petcare_mobile/utils/app_colors.dart';

class ConversacionesScreen extends StatefulWidget {
  const ConversacionesScreen({super.key});

  @override
  State<ConversacionesScreen> createState() => _ConversacionesScreenState();
}

class _ConversacionesScreenState extends State<ConversacionesScreen> {
  late Future<List<AdoptionRequest>> _future;
  final AdoptionService _service = AdoptionService();

  @override
  void initState() {
    super.initState();
    _future = _service.getMyAdoptionRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Chats',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<List<AdoptionRequest>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.textSub(context)),
                  const SizedBox(height: 12),
                  Text('No se pudieron cargar los chats',
                      style: GoogleFonts.poppins(color: AppColors.textSub(context))),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _future = _service.getMyAdoptionRequests();
                    }),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final requests = (snapshot.data ?? [])
              .where((r) => r.conversacion != null)
              .toList();

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 72, color: AppColors.textSub(context).withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No tienes conversaciones aún',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600,
                          color: AppColors.textSub(context))),
                  const SizedBox(height: 8),
                  Text('Solicita adoptar una mascota\npara iniciar un chat',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.textSub(context))),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => setState(() {
              _future = _service.getMyAdoptionRequests();
            }),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _ConversacionTile(request: requests[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ConversacionTile extends StatelessWidget {
  final AdoptionRequest request;
  const _ConversacionTile({required this.request});

  String? get _fotoUrl {
    final fotos = request.mascota.galeriaFotos;
    return fotos.isNotEmpty ? fotos[0] : null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.card(context);
    final txtColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 2,
      shadowColor: AppColors.shadow,
      child: isDark
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkDivider),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildContent(context, txtColor, subColor),
            )
          : _buildContent(context, txtColor, subColor),
    );
  }

  Widget _buildContent(BuildContext context, Color txtColor, Color subColor) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ChatScreen(adoptionRequest: request))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _fotoUrl != null
                  ? Image.network(_fotoUrl!, width: 56, height: 56, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback())
                  : _avatarFallback(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.mascota.nombre,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 15, color: txtColor)),
                  const SizedBox(height: 2),
                  Text('Solicitud de adopción',
                      style: GoogleFonts.poppins(fontSize: 12, color: subColor)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _estadoColor(request.estado).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(request.estado,
                  style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: _estadoColor(request.estado))),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: subColor),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() => Container(
      width: 56, height: 56,
      color: AppColors.primary.withOpacity(0.1),
      child: const Icon(Icons.pets, color: AppColors.primary, size: 28));

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada': return AppColors.success;
      case 'rechazada': return AppColors.error;
      case 'pendiente': return AppColors.warning;
      default: return AppColors.info;
    }
  }
}
