class Evento {
  final String id;
  final String titulo;
  final String descripcion;
  final String imagenPrincipal;
  final DateTime fecha;
  final String hora;
  final String ubicacion;
  final String categoria;
  final String organizadorNombre; // Simplificamos para solo mostrar el nombre

  Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagenPrincipal,
    required this.fecha,
    required this.hora,
    required this.ubicacion,
    required this.categoria,
    required this.organizadorNombre,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    // El backend puebla 'organizador' y devuelve un objeto con el nombre
    final organizador = json['organizador'];
    final nombreOrganizador = organizador != null && organizador is Map ? organizador['nombre'] : 'Refugio Desconocido';

    return Evento(
      id: json['_id'] ?? '',
      titulo: json['titulo'] ?? 'Sin Título',
      descripcion: json['descripcion'] ?? '',
      imagenPrincipal: json['imagenPrincipal'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      hora: json['hora'] ?? '',
      ubicacion: json['ubicacion'] ?? 'Ubicación no especificada',
      categoria: json['categoria'] ?? 'General',
      organizadorNombre: nombreOrganizador,
    );
  }
}