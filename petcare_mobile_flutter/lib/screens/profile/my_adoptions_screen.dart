import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petcare_mobile/api/adoption_service.dart';
import 'package:petcare_mobile/models/adoption_request.dart';
import 'package:petcare_mobile/screens/chat/chat_screen.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAdoptionsScreen extends StatefulWidget {
  const MyAdoptionsScreen({super.key});
  @override
  State<MyAdoptionsScreen> createState() => _MyAdoptionsScreenState();
}

class _MyAdoptionsScreenState extends State<MyAdoptionsScreen> {
  late Future<List<AdoptionRequest>> _requestsFuture;
  final AdoptionService _adoptionService = AdoptionService();

  @override
  void initState() { super.initState(); _load(); }

  void _load() => setState(() {
    _requestsFuture = _adoptionService.getMyAdoptionRequests();
  });

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el certificado.')));
      return;
    }
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')));
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'APROBADA': return Colors.green;
      case 'EN_REVISION': return Colors.orange;
      case 'RECHAZADA': return Colors.red;
      default: return Colors.blue;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'APROBADA': return Icons.check_circle;
      case 'EN_REVISION': return Icons.hourglass_empty;
      case 'RECHAZADA': return Icons.cancel;
      default: return Icons.fiber_new;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.bg(context);
    final txtColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);
    final cardColor = AppColors.card(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('Mis Solicitudes',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 20, color: txtColor)),
        iconTheme: IconThemeData(color: txtColor),
      ),
      body: FutureBuilder<List<AdoptionRequest>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 64, color: subColor),
                    const SizedBox(height: 16),
                    Text('No se pudieron cargar tus solicitudes',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 15, color: subColor)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar')),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pets, size: 72, color: subColor.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('Aún no has enviado solicitudes',
                      style: GoogleFonts.poppins(fontSize: 16, color: subColor)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: snapshot.data!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = snapshot.data![index];
                final fotoUrl = r.mascota.galeriaFotos.isNotEmpty
                    ? r.mascota.galeriaFotos[0]
                    : null;

                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark
                        ? Border.all(color: AppColors.darkDivider)
                        : null,
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: fotoUrl != null
                                  ? Image.network(fotoUrl,
                                      width: 64, height: 64, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _photoPlaceholder())
                                  : _photoPlaceholder(),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.mascota.nombre,
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: txtColor)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Enviada el ${DateFormat('dd/MM/yyyy').format(r.fechaCreacion)}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11, color: subColor),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _statusColor(r.estado).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_statusIcon(r.estado),
                                      size: 13, color: _statusColor(r.estado)),
                                  const SizedBox(width: 4),
                                  Text(r.estado,
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _statusColor(r.estado))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (r.conversacion != null || r.estado == 'APROBADA') ...[
                        Divider(height: 1, color: AppColors.div(context)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (r.conversacion != null)
                                TextButton.icon(
                                  icon: const Icon(
                                      Icons.chat_bubble_outline, size: 16),
                                  label: Text('Chat',
                                      style: GoogleFonts.poppins(fontSize: 12)),
                                  onPressed: () =>
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ChatScreen(adoptionRequest: r),
                                        ),
                                      ),
                                ),
                              if (r.estado == 'APROBADA')
                                TextButton.icon(
                                  icon: const Icon(
                                      Icons.download_for_offline, size: 16),
                                  label: Text('Certificado',
                                      style: GoogleFonts.poppins(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary),
                                  onPressed: () =>
                                      _launchURL(r.urlPdfCertificado),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _photoPlaceholder() => Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.pets, color: AppColors.primary, size: 28));
}
