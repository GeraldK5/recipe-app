import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesController extends GetxController {
  // Observable list of favorite meal IDs
  RxList<String> favoriteMealIds = <String>[].obs;

  // Key for SharedPreferences
  static const String _favoritesKey = 'favorite_meals';

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  // Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString(_favoritesKey);

      if (favoritesString != null) {
        final List<dynamic> favoritesList = json.decode(favoritesString);
        favoriteMealIds.value = favoritesList.cast<String>();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = json.encode(favoriteMealIds.toList());
      await prefs.setString(_favoritesKey, favoritesString);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Add meal to favorites
  Future<void> addToFavorites(String mealId) async {
    if (!favoriteMealIds.contains(mealId)) {
      favoriteMealIds.add(mealId);
      await _saveFavorites();
    }
  }

  // Remove meal from favorites
  Future<void> removeFromFavorites(String mealId) async {
    if (favoriteMealIds.contains(mealId)) {
      favoriteMealIds.remove(mealId);
      await _saveFavorites();
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String mealId) async {
    if (isFavorite(mealId)) {
      await removeFromFavorites(mealId);
    } else {
      await addToFavorites(mealId);
    }
  }

  // Check if meal is favorite
  bool isFavorite(String mealId) {
    return favoriteMealIds.contains(mealId);
  }

  // Get all favorite meal IDs
  List<String> getAllFavorites() {
    return favoriteMealIds.toList();
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    favoriteMealIds.clear();
    await _saveFavorites();
  }
}
