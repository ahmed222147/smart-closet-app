import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clothe_closet_app/widgets/outfit_detail_screen.dart';

class ViewClothesScreen extends StatelessWidget {
  const ViewClothesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Clothes'),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('outfits').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No outfits found.'));
          }

          final outfits = snapshot.data!.docs;

          return ListView.builder(
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              final outfitName = outfit['name'];
              final itemIds = List<String>.from(outfit['item_ids']);

              return ListTile(
                leading: const Icon(Icons.inventory, color: Colors.pink),
                title: Text(outfitName),
                subtitle: Text('${itemIds.length} items'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OutfitDetailScreen(
                        outfitName: outfitName,
                        itemIds: itemIds,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
