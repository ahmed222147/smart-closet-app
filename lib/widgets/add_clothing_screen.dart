import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clothe_closet_app/models/clothing_item.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? _image;
  bool _isProcessingImage = false;
  bool _isSaving = false;

  final _colorController = TextEditingController();
  final _brandController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSeason;

  Future<File?> removeBackground(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      )
        ..headers['X-Api-Key'] = 'jFm3m4bw5eGayze4AQa6gmPd'
        ..files.add(await http.MultipartFile.fromPath('image_file', imageFile.path))
        ..fields['size'] = 'auto';

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        final bytes = await streamedResponse.stream.toBytes();
        final tempDir = await getTemporaryDirectory();
        final bgRemovedFile = File('${tempDir.path}/no_bg_${DateTime.now().millisecondsSinceEpoch}.png');
        return await bgRemovedFile.writeAsBytes(bytes);
      } else {
        print(' Remove.bg API error: ${streamedResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print(' Exception during background removal: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isProcessingImage = true);
      final originalImage = File(pickedFile.path);
      final cleanedImage = await removeBackground(originalImage);
      setState(() {
        _image = cleanedImage ?? originalImage;
        _isProcessingImage = false;
      });
    }
  }

  Future<String?> uploadToImgbb(File imageFile) async {
    const apiKey = 'b22e0668ec40ce14a5010c4c08fe191c'; // Your ImgBB API key

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey"),
        body: {'image': base64Image},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      } else {
        print("❌ ImgBB upload failed:");
        print("Status Code: ${response.statusCode}");
        print("Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception during ImgBB upload: $e");
      return null;
    }
  }

  // NEW: Function to call the simulated 2D to 3D conversion endpoint

  Future<void> _saveClothingItem() async {
    if (!_formKey.currentState!.validate() || _image == null || _selectedCategory == null || _selectedSeason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and pick an image')),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);

      // 1. Upload 2D image to ImgBB and get the image URL
      final imageUrl = await uploadToImgbb(_image!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
        return;
      }

 

      // 3. Create ClothingItem with both 2D image URL and 3D model URL
      final clothingItem = ClothingItem(
        id: '', // Firestore will assign an ID
        category: _selectedCategory!,
        season: _selectedSeason!,
        color: _colorController.text,
        brand: _brandController.text,
        notes: _notesController.text,
        imageUrl: imageUrl, // 2D image URL
      
      );

      // 4. Save to Firestore
      await FirebaseFirestore.instance.collection('clothing_items').add(clothingItem.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item saved successfully with 3D model link!')));
      Navigator.pop(context);
    } catch (e) {
      print('Error saving item: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isProcessingImage
            ? const Center(child: CircularProgressIndicator())
            : _image == null
                ? const Icon(Icons.add_a_photo, size: 48)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(labelText: 'Category'),
          items: ['Top', 'Bottom', 'Shoes', 'Accessories']
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
          validator: (val) => val == null ? 'Select a category' : null,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedSeason,
          decoration: const InputDecoration(labelText: 'Season'),
          items: ['Summer', 'Winter', 'Spring', 'Fall', 'All'] // Added 'All' season option
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: (val) => setState(() => _selectedSeason = val),
          validator: (val) => val == null ? 'Select a season' : null,
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        TextFormField(
          controller: _colorController,
          decoration: const InputDecoration(labelText: 'Color'),
          validator: (val) => val == null || val.isEmpty ? 'Enter a color' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _brandController,
          decoration: const InputDecoration(labelText: 'Brand'),
          validator: (val) => val == null || val.isEmpty ? 'Enter a brand' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(labelText: 'Notes (optional)'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _saveClothingItem,
      icon: const Icon(Icons.save),
      label: _isSaving
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: CircularProgressIndicator(color: Colors.white),
            )
          : const Text('Save Clothing Item'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        backgroundColor: Colors.pink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clothing Item'),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 20),
                _buildDropdowns(),
                const SizedBox(height: 20),
                _buildTextFields(),
                const SizedBox(height: 30),
                Center(child: _buildSaveButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
