class User {
  final String id;
  final String nombre;
  final String correo;
  final String rol;

  User({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  // Factory constructor para crear un User desde un mapa (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      nombre: json['nombre'],
      correo: json['correo'],
      rol: json['rol'],
    );
  }
}