class ClothingItem {
  final String id;
  final String category;
  final String season;
  final String color;
  final String brand;
  final String notes;
  final String imageUrl; // URL for the 2D image
 

  ClothingItem({
    required this.id,
    required this.category,
    required this.season,
    required this.color,
    required this.brand,
    required this.notes,
    required this.imageUrl,
 
  });

  Map<String, dynamic> toMap() => {
        'category': category,
        'season': season,
        'color': color,
        'brand': brand,
        'notes': notes,
        'imageUrl': imageUrl,
 
      };

  factory ClothingItem.fromMap(String id, Map<String, dynamic> map) {
    return ClothingItem(
      id: id,
      category: map['category'] ?? '',
      season: map['season'] ?? '',
      color: map['color'] ?? '',
      brand: map['brand'] ?? '',
      notes: map['notes'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
  
    );
  }
}
