import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/clothing_item.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('clothing_images/$fileName.jpg');
    await ref.putFile(image, SettableMetadata());
    final downloadUrl = await ref.getDownloadURL();
    print(' Image uploaded: $downloadUrl');
    return downloadUrl;
  }

  Future<void> addClothingItem(ClothingItem item) async {
    await _firestore.collection('clothing_items').add(item.toMap());
  }

 Stream<List<ClothingItem>> getClothingItems() {
  return _firestore.collection('clothing_items').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return ClothingItem.fromMap(doc.id, doc.data());
    }).toList();
  });
}

  Future<void> deleteClothingItem(String id) async {
    await _firestore.collection('clothing_items').doc(id).delete();
  }

  Future<void> updateClothingItem(String id, ClothingItem item) async {
    await _firestore.collection('clothing_items').doc(id).update(item.toMap());
  }
    Future<ClothingItem?> getClothingItemById(String itemId) async {
    try {
      final doc = await _firestore.collection('clothing_items').doc(itemId).get();
      if (doc.exists) {
        return ClothingItem.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting clothing item by ID: $e');
      return null;
    }
  }
}
