import 'package:flutter/material.dart';
import 'package:clothe_closet_app/models/clothing_item.dart';
import 'package:clothe_closet_app/services/firebase_service.dart'; // Import your FirebaseService

class OutfitDetailScreen extends StatefulWidget {
  final String outfitName;
  final List<String> itemIds;

  const OutfitDetailScreen({
    super.key,
    required this.outfitName,
    required this.itemIds,
  });

  @override
  State<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends State<OutfitDetailScreen> {
  List<ClothingItem> _outfitItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOutfitItems();
  }

  Future<void> _loadOutfitItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<ClothingItem> loadedItems = [];
      for (String id in widget.itemIds) {
        final item = await FirebaseService().getClothingItemById(id);
        if (item != null) {
          loadedItems.add(item);
        }
      }
      setState(() {
        _outfitItems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load outfit details: $e';
        _isLoading = false;
      });
      print('Error loading outfit items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.outfitName),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _outfitItems.isEmpty
                  ? const Center(child: Text('No items found for this outfit.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _outfitItems.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75, // Adjust as needed
                      ),
                      itemBuilder: (context, index) {
                        final item = _outfitItems[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: item.imageUrl.isNotEmpty

                                      ? Image.network(
                                          item.imageUrl, // CORRECTED: Use Image.network
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
                                            print('Error loading outfit image: ${item.imageUrl} - $exception');
                                            return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                          },
                                        )
                                      : const Center(
                                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text('Color: ${item.color}'),
                                    Text('Brand: ${item.brand}'),
                                    Text('Season: ${item.season}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}