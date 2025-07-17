import 'package:clothe_closet_app/firebase_options.dart';
import 'package:clothe_closet_app/widgets/add_clothing_screen.dart';
import 'package:clothe_closet_app/widgets/clothes_library_screen.dart';
import 'package:clothe_closet_app/widgets/outfit_planing_screen.dart';
import 'package:clothe_closet_app/widgets/view_clothes_screen.dart';
import 'package:clothe_closet_app/widgets/wishlist_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'widgets/welcome_screen.dart';
import 'widgets/home_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartClosetApp());
}

class SmartClosetApp extends StatelessWidget {
  const SmartClosetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Closet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/add': (context) => const AddClothingScreen(),
        '/storage': (context) => const ClothesLibraryScreen(),
        '/plan': (context) => const OutfitPlanningScreen(),
        '/view-clothes': (context) => const ViewClothesScreen(),
        '/wishlist': (context) => const WishlistScreen(), 
      },
    );
  }
}
