import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();
    _requestsFuture = _adoptionService.getMyAdoptionRequests();
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el certificado.')),
        );
      }
      return;
    }
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APROBADA':
        return Colors.green;
      case 'EN_REVISION':
        return Colors.orange;
      case 'RECHAZADA':
        return Colors.red;
      case 'NUEVA':
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes de Adopción'),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<AdoptionRequest>>(
        future: _requestsFuture,
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
                'Aún no has enviado ninguna solicitud.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final requests = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              request.mascota.galeriaFotos.isNotEmpty
                                  ? request.mascota.galeriaFotos[0]
                                  : 'https://via.placeholder.com/150',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.mascota.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Solicitud enviada: ${DateFormat('dd/MM/yyyy').format(request.fechaCreacion)}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(request.estado),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              request.estado,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (request.conversacion != null)
                            TextButton.icon(
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Abrir Chat'),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) =>
                                      ChatScreen(adoptionRequest: request),
                                ));
                              },
                            ),
                          if (request.estado == 'APROBADA')
                            TextButton.icon(
                              icon: const Icon(Icons.download_for_offline),
                              label: const Text('Certificado'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              onPressed: () =>
                                  _launchURL(request.urlPdfCertificado),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}