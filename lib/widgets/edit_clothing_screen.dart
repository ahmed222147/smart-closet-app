import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:clothe_closet_app/models/clothing_item.dart';
import 'package:clothe_closet_app/services/firebase_service.dart';

class EditClothingScreen extends StatefulWidget {
  final ClothingItem item;
  const EditClothingScreen({super.key, required this.item});

  @override
  State<EditClothingScreen> createState() => _EditClothingScreenState();
}

class _EditClothingScreenState extends State<EditClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _colorController;
  late TextEditingController _brandController;
  late TextEditingController _notesController;
  late String _selectedCategory;
  late String _selectedSeason;

  @override
  void initState() {
    super.initState();
    _colorController = TextEditingController(text: widget.item.color);
    _brandController = TextEditingController(text: widget.item.brand);
    _notesController = TextEditingController(text: widget.item.notes);
    _selectedCategory = widget.item.category;
    _selectedSeason = widget.item.season;
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedItem = ClothingItem(
        id: widget.item.id,
        category: _selectedCategory,
        season: _selectedSeason,
        color: _colorController.text,
        brand: _brandController.text,
        notes: _notesController.text,
        imageUrl: widget.item.imageUrl,
      );
      await FirebaseService().updateClothingItem(widget.item.id, updatedItem);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    try {
      imageBytes = base64Decode(widget.item.imageUrl);
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Clothing Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (imageBytes != null)
                Image.memory(imageBytes, height: 180, fit: BoxFit.cover),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Top', 'Bottom', 'Shoes', 'Accessories']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              DropdownButtonFormField<String>(
                value: _selectedSeason,
                decoration: const InputDecoration(labelText: 'Season'),
                items: ['Summer', 'Winter', 'Spring', 'Fall']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedSeason = val!),
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
