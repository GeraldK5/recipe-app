import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/controllers/favorites_controller.dart';
import '../constants.dart';
import '../controllers/category_controller.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final CategoryController categoryController = Get.put(CategoryController());
  final FavoritesController favoritesController = Get.put(FavoritesController());

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for categories to load
    await categoryController.fetchCategories();
    await favoritesController.loadFavorites();

    // Add a minimum delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to home screen
    if (mounted) {
      Get.off(() => const Home());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Recipe App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (categoryController.isLoading) {
                return const Text(
                  'Loading recipes...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                );
              } else if (categoryController.errorMessage.isNotEmpty) {
                return Text(
                  categoryController.errorMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
