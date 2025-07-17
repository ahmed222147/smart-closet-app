import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clothe_closet_app/models/clothing_item.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<ClothingItem> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }

  Future<void> _loadWishlistItems() async {
    final wishlistSnapshot =
        await FirebaseFirestore.instance.collection('wishlist_items').get();

    List<ClothingItem> tempItems = [];

    for (var doc in wishlistSnapshot.docs) {
      final itemId = doc['item_id'];
      if (itemId == null) continue;

      final itemSnapshot = await FirebaseFirestore.instance
          .collection('clothing_items')
          .doc(itemId)
          .get();

      if (itemSnapshot.exists) {
        final itemData = itemSnapshot.data();
        if (itemData != null) {
          final item = ClothingItem.fromMap(itemSnapshot.id, itemData);
          tempItems.add(item);
        }
      }
    }

    setState(() {
      wishlistItems = tempItems;
    });
  }

  Future<void> _removeFromWishlist(String itemId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('wishlist_items')
        .where('item_id', isEqualTo: itemId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    setState(() {
      wishlistItems.removeWhere((item) => item.id == itemId);
    });
  }

  Widget _buildImage(String imageUrl) {
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover);
      } else {
        Uint8List imageBytes = base64Decode(imageUrl);
        return Image.memory(imageBytes, width: 50, height: 50, fit: BoxFit.cover);
      }
    } catch (_) {
      return const Icon(Icons.broken_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: wishlistItems.isEmpty
          ? const Center(child: Text('No items in wishlist.'))
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: _buildImage(item.imageUrl),
                    title: Text(item.category),
                    subtitle: Text('${item.color} - ${item.brand}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFromWishlist(item.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
