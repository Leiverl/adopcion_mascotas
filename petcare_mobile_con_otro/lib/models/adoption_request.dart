import 'package:petcare_mobile/models/conversacion.dart';
import 'package:petcare_mobile/models/pet.dart';

class AdoptionRequest {
  final String id;
  final Pet mascota;
  final String estado;
  final DateTime fechaCreacion;
  final String? urlPdfCertificado;
  final Conversacion? conversacion; // <-- AÑADIR ESTE CAMPO

  AdoptionRequest({
    required this.id,
    required this.mascota,
    required this.estado,
    required this.fechaCreacion,
    this.urlPdfCertificado,
    this.conversacion, // <-- AÑADIR AL CONSTRUCTOR
  });

  factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
    return AdoptionRequest(
      id: json['_id'],
      mascota: Pet.fromJson(json['mascota']),
      estado: json['estado'] ?? 'DESCONOCIDO',
      fechaCreacion: DateTime.parse(json['createdAt']),
      urlPdfCertificado: json['urlPdfCertificado'],
      // Si la conversación existe en el JSON, la creamos
      conversacion: json['conversacion'] != null
          ? Conversacion.fromJson(json['conversacion'])
          : null,
    );
  }
}