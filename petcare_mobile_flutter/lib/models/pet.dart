class Pet {
  final String id;
  final String nombre;
  final String especie;
  final String raza;
  final int edad;
  final String sexo;
  final String tamano;
  final String descripcion;
  final List<String> galeriaFotos;
  final String refugioId;

  Pet({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
    required this.sexo,
    required this.tamano,
    required this.descripcion,
    required this.galeriaFotos,
    required this.refugioId,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    // 'refugio' puede llegar como objeto populado, como string ID, o como null
    String parsedRefugioId = '';
    final refugioRaw = json['refugio'];
    if (refugioRaw is Map) {
      parsedRefugioId = (refugioRaw['_id'] ?? '').toString();
    } else if (refugioRaw is String) {
      parsedRefugioId = refugioRaw;
    }
    // Soporte legacy por si todavía llega como 'refugioId'
    if (parsedRefugioId.isEmpty) {
      parsedRefugioId = (json['refugioId'] ?? '').toString();
    }

    // 'edad' puede llegar como int o como string
    int parsedEdad = 0;
    final edadRaw = json['edad'];
    if (edadRaw is int) {
      parsedEdad = edadRaw;
    } else if (edadRaw is String) {
      parsedEdad = int.tryParse(edadRaw) ?? 0;
    }

    return Pet(
      id: (json['_id'] ?? '').toString(),
      nombre: (json['nombre'] ?? 'Sin nombre').toString(),
      especie: (json['especie'] ?? 'Desconocida').toString(),
      raza: (json['raza'] ?? 'Mestizo').toString(),
      edad: parsedEdad,
      sexo: (json['sexo'] ?? 'Desconocido').toString(),
      tamano: (json['tamano'] ?? 'Mediano').toString(),
      descripcion: (json['descripcion'] ?? 'Sin descripción.').toString(),
      galeriaFotos: List<String>.from(json['galeriaFotos'] ?? []),
      refugioId: parsedRefugioId,
    );
  }
}
