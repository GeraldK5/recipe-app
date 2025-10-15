import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/meal_model.dart';
import '../apis.dart';

class MealController extends GetxController {
  // Map to store meals for each category (for caching)
  final RxMap<String, List<MealModel>> _categoryMeals =
      <String, List<MealModel>>{}.obs;

  // Current category being displayed
  final RxString _currentCategory = ''.obs;

  // Loading state
  final RxBool _isLoading = false.obs;

  // Loading more state (for pagination)
  final RxBool _isLoadingMore = false.obs;

  // Error state
  final RxString _errorMessage = ''.obs;

  // Pagination
  final RxInt _currentPage = 0.obs;
  final int _itemsPerPage = 10;
  final RxBool _hasMore = true.obs;

  // Getters
  List<MealModel> getMealsForCategory(String category) {
    return _categoryMeals[category] ?? [];
  }

  List<MealModel> get currentMeals {
    if (_currentCategory.value.isEmpty) return [];
    return _categoryMeals[_currentCategory.value] ?? [];
  }

  String get currentCategory => _currentCategory.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get errorMessage => _errorMessage.value;
  bool get hasMore => _hasMore.value;
  int get displayedItemsCount => _currentPage.value * _itemsPerPage;

  // All meals fetched from API (not paginated on display)
  final RxList<MealModel> _allFetchedMeals = <MealModel>[].obs;

  // Set current category and fetch meals if not cached
  Future<void> setCategory(String category) async {
    _currentCategory.value = category;
    _currentPage.value = 0;
    _hasMore.value = true;

    // Check if we already have meals for this category
    if (!_categoryMeals.containsKey(category) ||
        _categoryMeals[category]!.isEmpty) {
      await fetchMeals(category);
    } else {
      // Reset pagination for cached data
      _allFetchedMeals.value = _categoryMeals[category]!;
      _hasMore.value = _allFetchedMeals.length > _itemsPerPage;
      _updateDisplayedMeals();
    }
  }

  // Fetch meals from API
  Future<void> fetchMeals(String category, {bool refresh = false}) async {
    try {
      if (refresh) {
        _isLoading.value = true;
      } else if (_categoryMeals.containsKey(category) &&
          _categoryMeals[category]!.isNotEmpty) {
        // Already have data for this category
        return;
      } else {
        _isLoading.value = true;
      }

      _errorMessage.value = '';

      final response = await http.get(Uri.parse(getMealsApiUrl(category)));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final mealsResponse = MealsResponse.fromJson(jsonData);

        // Store all fetched meals
        _allFetchedMeals.value = mealsResponse.meals;
        _categoryMeals[category] = mealsResponse.meals;

        // Initialize pagination
        _currentPage.value = 0;
        _hasMore.value = mealsResponse.meals.length > _itemsPerPage;
        _updateDisplayedMeals();
      } else {
        _errorMessage.value = 'Failed to load meals: ${response.statusCode}';
        _categoryMeals[category] = [];
      }
    } catch (e) {
      _errorMessage.value = 'Error fetching meals: $e';
      _categoryMeals[category] = [];
    } finally {
      _isLoading.value = false;
    }
  }

  // Load more meals (pagination)
  Future<void> loadMore() async {
    if (_isLoadingMore.value || !_hasMore.value) return;

    try {
      _isLoadingMore.value = true;

      // Simulate a small delay for better UX
      await Future.delayed(Duration(milliseconds: 300));

      _currentPage.value++;
      _updateDisplayedMeals();
    } finally {
      _isLoadingMore.value = false;
    }
  }

  // Update the displayed meals based on current page
  void _updateDisplayedMeals() {
    if (_currentCategory.value.isEmpty) return;

    final allMeals = _allFetchedMeals;
    final endIndex = (_currentPage.value + 1) * _itemsPerPage;

    if (endIndex >= allMeals.length) {
      _hasMore.value = false;
    }

    // Update the category meals with paginated data
    final displayedMeals = allMeals
        .take(endIndex.clamp(0, allMeals.length))
        .toList();
    _categoryMeals[_currentCategory.value] = displayedMeals;
  }

  // Refresh meals for current category
  Future<void> refreshCurrentCategory() async {
    if (_currentCategory.value.isEmpty) return;
    _currentPage.value = 0;
    await fetchMeals(_currentCategory.value, refresh: true);
  }

  // Clear cached data for a category
  void clearCategoryCache(String category) {
    _categoryMeals.remove(category);
  }

  // Clear all cached data
  void clearAllCache() {
    _categoryMeals.clear();
    _currentCategory.value = '';
    _currentPage.value = 0;
    _hasMore.value = true;
    _allFetchedMeals.clear();
  }
}
