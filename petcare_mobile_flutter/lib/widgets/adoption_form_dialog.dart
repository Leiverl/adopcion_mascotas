import 'package:flutter/material.dart';

class AdoptionFormDialog extends StatefulWidget {
  const AdoptionFormDialog({super.key});

  @override
  State<AdoptionFormDialog> createState() => _AdoptionFormDialogState();
}

class _AdoptionFormDialogState extends State<AdoptionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _respuesta1Controller = TextEditingController();
  final _respuesta2Controller = TextEditingController();

  final String _pregunta1 = '¿Por qué quieres adoptar esta mascota?';
  final String _pregunta2 = '¿Tienes experiencia previa cuidando mascotas?';

  @override
  void dispose() {
    _respuesta1Controller.dispose();
    _respuesta2Controller.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // --- CORRECCIÓN AQUÍ: Creamos un Mapa, no una Lista ---
      final respuestas = {
        _pregunta1: _respuesta1Controller.text,
        _pregunta2: _respuesta2Controller.text,
      };
      Navigator.of(context).pop(respuestas);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Formulario de Adopción'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_pregunta1, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _respuesta1Controller,
                decoration: const InputDecoration(hintText: 'Tu respuesta...'),
                validator: (value) => (value ?? '').isEmpty ? 'Campo requerido' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text(_pregunta2, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _respuesta2Controller,
                decoration: const InputDecoration(hintText: 'Tu respuesta...'),
                validator: (value) => (value ?? '').isEmpty ? 'Campo requerido' : null,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Enviar Solicitud'),
        ),
      ],
    );
  }
}