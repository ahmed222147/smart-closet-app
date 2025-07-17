class Outfit {
  final String id;
  final String name;
  final List<String> clothingItemIds; // Firestore document IDs
  final String? notes;

  Outfit({
    required this.id,
    required this.name,
    required this.clothingItemIds,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'clothingItemIds': clothingItemIds,
      'notes': notes,
    };
  }

  factory Outfit.fromMap(String id, Map<String, dynamic> map) {
    return Outfit(
      id: id,
      name: map['name'],
      clothingItemIds: List<String>.from(map['clothingItemIds']),
      notes: map['notes'],
    );
  }
}
