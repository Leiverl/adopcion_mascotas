import 'package:petcare_mobile/models/conversacion.dart';
import 'package:petcare_mobile/models/pet.dart';

class AdoptionRequest {
  final String id;
  final Pet mascota;
  final String estado;
  final DateTime fechaCreacion;
  final String? urlPdfCertificado;
  final Conversacion? conversacion;

  AdoptionRequest({
    required this.id,
    required this.mascota,
    required this.estado,
    required this.fechaCreacion,
    this.urlPdfCertificado,
    this.conversacion,
  });

  factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
    // 'mascota' puede llegar populada (Map) o solo como ID (String)
    Pet parsedMascota;
    final mascotaRaw = json['mascota'];
    if (mascotaRaw is Map<String, dynamic>) {
      parsedMascota = Pet.fromJson(mascotaRaw);
    } else {
      // Solo tenemos el ID, creamos un objeto mínimo
      parsedMascota = Pet(
        id: mascotaRaw?.toString() ?? '',
        nombre: 'Mascota',
        especie: '',
        raza: '',
        edad: 0,
        sexo: '',
        tamano: '',
        descripcion: '',
        galeriaFotos: [],
        refugioId: '',
      );
    }

    // 'conversacion' puede llegar populada (Map) o solo como ID (String)
    Conversacion? parsedConversacion;
    final convRaw = json['conversacion'];
    if (convRaw is Map<String, dynamic>) {
      try {
        parsedConversacion = Conversacion.fromJson(convRaw);
      } catch (_) {
        parsedConversacion = null;
      }
    }

    return AdoptionRequest(
      id: (json['_id'] ?? '').toString(),
      mascota: parsedMascota,
      estado: (json['estado'] ?? 'DESCONOCIDO').toString(),
      fechaCreacion: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      urlPdfCertificado: json['urlPdfCertificado']?.toString(),
      conversacion: parsedConversacion,
    );
  }
}
