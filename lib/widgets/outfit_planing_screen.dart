

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clothe_closet_app/models/clothing_item.dart';

class OutfitPlanningScreen extends StatefulWidget {
  const OutfitPlanningScreen({super.key});

  @override
  State<OutfitPlanningScreen> createState() => _OutfitPlanningScreenState();
}

class _OutfitPlanningScreenState extends State<OutfitPlanningScreen> {
  List<ClothingItem> _items = [];
  final TextEditingController _outfitNameController = TextEditingController();
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _loadClothes();
  }

  @override
  void dispose() {
    _outfitNameController.dispose();
    super.dispose();
  }

  Future<void> _loadClothes() async {
    final snapshot = await FirebaseFirestore.instance.collection('clothing_items').get();
    setState(() {
      _items = snapshot.docs.map((doc) => ClothingItem.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> _saveOutfit() async {
    if (_selectedItemIds.isEmpty || _outfitNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select clothes and enter a name')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('outfits').add({
        'name': _outfitNameController.text.trim(),
        'item_ids': _selectedItemIds.toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit saved successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print(' Failed to save outfit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving outfit: $e')),
      );
    }
  }

  Widget _buildClothingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        final item = _items[index];
        final isSelected = _selectedItemIds.contains(item.id);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedItemIds.remove(item.id);
              } else {
                _selectedItemIds.add(item.id);
              }
            });
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: isSelected ? Colors.pink : Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl, // Use Image.network for URLs
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            print('Error loading image for item ${item.id}: $exception');
                            return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                          },
                        )
                      : const Center( // Fallback for no image
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.check_circle, color: Colors.pink),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan an Outfit'), backgroundColor: Colors.pink),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildClothingGrid(),
            const SizedBox(height: 20),
            TextField(
              controller: _outfitNameController,
              decoration: const InputDecoration(labelText: 'Outfit Name'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _selectedItemIds.isEmpty ? null : _saveOutfit,
              icon: const Icon(Icons.save),
              label: const Text('Save Outfit'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            )
          ],
        ),
      ),
    );
  }
}