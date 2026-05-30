class Mensaje {
  final String id;
  final String cuerpo;
  final String remitenteId;
  final String remitenteNombre;
  final DateTime fechaCreacion;

  Mensaje({
    required this.id,
    required this.cuerpo,
    required this.remitenteId,
    required this.remitenteNombre,
    required this.fechaCreacion,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['_id'],
      cuerpo: json['cuerpo'],
      remitenteId: json['remitente']['_id'],
      remitenteNombre: json['remitente']['nombre'] ?? 'Usuario',
      fechaCreacion: DateTime.parse(json['createdAt']),
    );
  }
}