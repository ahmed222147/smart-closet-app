import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        'title': 'View Clothes',
        'icon': Icons.warehouse,
        'route': '/view-clothes',
      },
      {'title': 'Outfit Planner', 'icon': Icons.checkroom, 'route': '/plan'},
      {
        'title': 'Wishlist',
        'icon': Icons.favorite_border,
        'route': '/wishlist',
      },
      {'title': 'Storage', 'icon': Icons.inventory, 'route': '/storage'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Closet'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final feature = features[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, feature['route']);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(feature['icon'], size: 48, color: Colors.pink),
                      const SizedBox(height: 12),
                      Text(
                        feature['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        label: const Text('Add Clothing'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
