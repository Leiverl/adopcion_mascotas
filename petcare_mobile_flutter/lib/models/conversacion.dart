class Conversacion {
  final String id;
  final String solicitudAdopcionId;
  
  Conversacion({required this.id, required this.solicitudAdopcionId});

  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      id: json['_id'],
      solicitudAdopcionId: json['solicitudAdopcion'],
    );
  }
}