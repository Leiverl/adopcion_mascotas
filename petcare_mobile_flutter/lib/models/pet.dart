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
    // El operador '??' significa: "si el valor de la izquierda es null, usa el de la derecha".
    return Pet(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      especie: json['especie'] ?? 'Desconocida',
      raza: json['raza'] ?? 'Mestizo',
      edad: json['edad'] ?? 0,
      sexo: json['sexo'] ?? 'Desconocido',
      tamano: json['tamano'] ?? 'Mediano',
      descripcion: json['descripcion'] ?? 'Sin descripción.',
      galeriaFotos: List<String>.from(json['galeriaFotos'] ?? []),
      refugioId: json['refugioId'] ?? '',
    );
  }
}