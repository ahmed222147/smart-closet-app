
import 'package:clothe_closet_app/widgets/edit_clothing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clothe_closet_app/models/clothing_item.dart';
import 'package:clothe_closet_app/services/firebase_service.dart';

class ClothesLibraryScreen extends StatefulWidget {
  const ClothesLibraryScreen({super.key});

  @override
  State<ClothesLibraryScreen> createState() => _ClothesLibraryScreenState();
}

class _ClothesLibraryScreenState extends State<ClothesLibraryScreen> {
  String? selectedCategory;
  String? selectedSeason;
  String? selectedColor;
  Set<String> wishlistedIds = {};

  final availableCategories = ['Top', 'Bottom', 'Shoes', 'Accessories'];
  final availableSeasons = ['Summer', 'Winter', 'Spring', 'Fall', 'All'];
  final availableColors = ['black', 'white', 'red', 'blue', 'green'];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
    // Initialize selected filters to null to prevent assertion errors
    selectedCategory = null;
    selectedSeason = null; // Explicitly set to null or a default like 'All'
    selectedColor = null;
  }

  Future<void> _loadWishlist() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('wishlist_items').get();
    setState(() {
      wishlistedIds =
          snapshot.docs.map((doc) => doc['item_id'] as String).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Closet'),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          // Filter Dropdowns
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                DropdownButton<String>(
                  value:
                      availableCategories.contains(selectedCategory)
                          ? selectedCategory
                          : null,
                  hint: const Text('Category'),
                  items:
                      availableCategories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() => selectedCategory = value),
                ),
                DropdownButton<String>(
                  value:
                      availableSeasons.contains(selectedSeason)
                          ? selectedSeason
                          : null,
                  hint: const Text('Season'),
                  items:
                      availableSeasons
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => selectedSeason = value),
                ),
                DropdownButton<String>(
                  value:
                      availableColors.contains(selectedColor)
                          ? selectedColor
                          : null,
                  hint: const Text('Color'),
                  items:
                      availableColors
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => selectedColor = value),
                ),
              ],
            ),
          ),
          // Clothing Items List
          Expanded(
            child: StreamBuilder<List<ClothingItem>>(
              stream: FirebaseService().getClothingItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<ClothingItem> items = snapshot.data ?? [];

                // Apply filters
                items =
                    items.where((item) {
                      final matchCategory =
                          selectedCategory == null ||
                          item.category == selectedCategory;
                      final matchSeason =
                          selectedSeason == null ||
                          item.season == selectedSeason;
                      final matchColor =
                          selectedColor == null || item.color == selectedColor;
                      return matchCategory && matchSeason && matchColor;
                    }).toList();

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No clothing items match the filters.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final bool isWishlisted = wishlistedIds.contains(item.id);

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
                              child:
                                  (item.imageUrl.isNotEmpty)
                                      ? Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace,
                                        ) {
                                          print(
                                            'Error loading network image: ${item.imageUrl} - $exception',
                                          );
                                          return const Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: Colors.grey,
                                          );
                                        },
                                      )
                                      : const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Color: ${item.color}'),
                                Text('Brand: ${item.brand}'),
                                Text('Season: ${item.season}'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Existing wishlist button
                                    IconButton(
                                      icon: Icon(
                                        isWishlisted
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        if (isWishlisted) {
                                          final snapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('wishlist_items')
                                                  .where(
                                                    'item_id',
                                                    isEqualTo: item.id,
                                                  )
                                                  .get();
                                          for (var doc in snapshot.docs) {
                                            await doc.reference.delete();
                                          }
                                          wishlistedIds.remove(item.id);
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection('wishlist_items')
                                              .add({
                                                'item_id': item.id,
                                                'timestamp':
                                                    FieldValue.serverTimestamp(),
                                              });
                                          wishlistedIds.add(item.id);
                                        }

                                        setState(() {});
                                      },
                                    ),

                                    // Existing edit button
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => EditClothingScreen(
                                                  item: item,
                                                ),
                                          ),
                                        );
                                      },
                                    ),

                                    // Existing delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await FirebaseService()
                                            .deleteClothingItem(item.id);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Item deleted'),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
