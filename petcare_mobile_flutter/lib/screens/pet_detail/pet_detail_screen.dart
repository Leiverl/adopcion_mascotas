import 'package:flutter/material.dart';
import 'package:petcare_mobile/api/adoption_service.dart';
import 'package:petcare_mobile/models/pet.dart';
import 'package:petcare_mobile/utils/app_colors.dart';
import 'package:petcare_mobile/widgets/adoption_form_dialog.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;
  const PetDetailScreen({super.key, required this.pet});
  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final AdoptionService _adoptionService = AdoptionService();
  bool _isLoading = false;
  bool _hasRequested = false;

  Future<void> _showAdoptionForm() async {
   final Map<String, String>? formResponses = await showDialog(
      context: context,
      builder: (ctx) => const AdoptionFormDialog(),
    );

   if (formResponses != null) {
      setState(() { _isLoading = true; });
      try {
        await _adoptionService.createAdopcionRequest(
          petId: widget.pet.id,
          formResponses: formResponses,
        );
        
        if (mounted) {
          _showResultDialog(
            title: '¡Solicitud Enviada!',
            content: 'El refugio ha recibido tu solicitud. Puedes ver el estado en "Mis Adopciones".',
          );
          setState(() { _hasRequested = true; });
        }
      } catch (e) {
        if (mounted) {
          _showResultDialog(
            title: 'Error',
            content: 'Ocurrió un error. Es posible que ya hayas enviado una solicitud para esta mascota.',
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  void _showResultDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('Entendido'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.nombre),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Carrusel de Imágenes ---
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: widget.pet.galeriaFotos.isNotEmpty ? widget.pet.galeriaFotos.length : 1,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.pet.galeriaFotos.isNotEmpty
                        ? widget.pet.galeriaFotos[index]
                        : 'https://via.placeholder.com/400x300',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.error, color: Colors.red, size: 50)),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- Información Principal ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pet.nombre,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.pet.raza,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Chips de Características ---
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildInfoChip('Edad: ${widget.pet.edad} años'),
                      _buildInfoChip('Sexo: ${widget.pet.sexo}'),
                      _buildInfoChip('Tamaño: ${widget.pet.tamano}'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Descripción ---
                  const Text(
                    'Sobre mí',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.pet.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5, // Interlineado
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20), // Espacio extra al final
                ],
              ),
            ),
          ],
        ),
      ),
      // --- Botón de Adopción ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _hasRequested ? null : _showAdoptionForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasRequested ? Colors.grey : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _hasRequested ? 'Solicitud Enviada' : '¡Adóptame!',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
      ),
    );
  }

  // Widget auxiliar para crear los chips de información
  Widget _buildInfoChip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}