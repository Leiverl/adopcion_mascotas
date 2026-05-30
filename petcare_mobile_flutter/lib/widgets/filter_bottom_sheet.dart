import 'package:flutter/material.dart';
import 'package:petcare_mobile/utils/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, String> initialFilters;

  const FilterBottomSheet({super.key, required this.initialFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedEspecie;
  late String? _selectedTamano;
  late String? _selectedSexo;

  @override
  void initState() {
    super.initState();
    _selectedEspecie = widget.initialFilters['especie'];
    _selectedTamano = widget.initialFilters['tamano'];
    _selectedSexo = widget.initialFilters['sexo'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtrar Mascotas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildFilterSection('Especie', ['Perro', 'Gato'], _selectedEspecie, (value) {
            setState(() => _selectedEspecie = value);
          }),
          _buildFilterSection('Tamaño', ['Pequeño', 'Mediano', 'Grande'], _selectedTamano, (value) {
            setState(() => _selectedTamano = value);
          }),
           _buildFilterSection('Sexo', ['Macho', 'Hembra'], _selectedSexo, (value) {
            setState(() => _selectedSexo = value);
          }),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               TextButton(
                onPressed: () {
                  // Limpiar filtros y aplicar
                  Navigator.pop(context, <String, String>{});
                },
                child: const Text('Limpiar Filtros'),
              ),
              ElevatedButton(
                onPressed: () {
                  final filters = <String, String>{};
                  if (_selectedEspecie != null) filters['especie'] = _selectedEspecie!;
                  if (_selectedTamano != null) filters['tamano'] = _selectedTamano!;
                  if (_selectedSexo != null) filters['sexo'] = _selectedSexo!;
                  Navigator.pop(context, filters);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: selectedValue == option,
              onSelected: (selected) {
                onChanged(selected ? option : null);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}