class WishlistItem {
  final String id;
  final String name;
  final String imageBase64;
  final String brand;
  final String category;
  final String price;
  final String note;

  WishlistItem({
    required this.id,
    required this.name,
    required this.imageBase64,
    required this.brand,
    required this.category,
    required this.price,
    required this.note,
  });

  factory WishlistItem.fromMap(String id, Map<String, dynamic> data) {
    return WishlistItem(
      id: id,
      name: data['name'] ?? '',
      imageBase64: data['imageBase64'] ?? '',
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      price: data['price'] ?? '',
      note: data['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageBase64': imageBase64,
      'brand': brand,
      'category': category,
      'price': price,
      'note': note,
      'timestamp': DateTime.now(),
    };
  }
}
