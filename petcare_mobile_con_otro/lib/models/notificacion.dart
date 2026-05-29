class Notificacion {
  final String id;
  final String titulo;
  final String cuerpo;
  final bool leida;
  final String? ruta;
  final DateTime fechaCreacion;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.leida,
    this.ruta,
    required this.fechaCreacion,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['_id'],
      titulo: json['titulo'] ?? 'Sin Título',
      cuerpo: json['cuerpo'] ?? 'Sin contenido.',
      leida: json['leida'] ?? false,
      ruta: json['ruta'],
      fechaCreacion: DateTime.parse(json['createdAt']),
    );
  }
}