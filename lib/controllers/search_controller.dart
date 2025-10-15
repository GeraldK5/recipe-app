import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/meal_detail_model.dart';
import '../apis.dart';

class SearchController extends GetxController {
  // Search results
  final RxList<MealDetailModel> _searchResults = <MealDetailModel>[].obs;

  // Loading state
  final RxBool _isLoading = false.obs;

  // Error state
  final RxString _errorMessage = ''.obs;

  // Search query
  final RxString _searchQuery = ''.obs;

  // Debounce timer
  Timer? _debounceTimer;

  // Getters
  List<MealDetailModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  bool get hasResults => _searchResults.isNotEmpty;

  // Search with debouncing
  void searchMeals(String query) {
    _searchQuery.value = query;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // If query is empty, clear results
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _errorMessage.value = '';
      return;
    }

    // Set debounce timer (500ms)
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  // Perform actual search
  Future<void> _performSearch(String query) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await http.get(Uri.parse(getSearchMealsApiUrl(query)));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final mealsResponse = MealDetailResponse.fromJson(jsonData);

        if (mealsResponse.meals.isNotEmpty) {
          _searchResults.value = mealsResponse.meals;
        } else {
          _searchResults.clear();
          _errorMessage.value = 'No meals found for "$query"';
        }
      } else {
        _errorMessage.value = 'Failed to search: ${response.statusCode}';
        _searchResults.clear();
      }
    } catch (e) {
      _errorMessage.value = 'Error searching meals: $e';
      _searchResults.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
    _errorMessage.value = '';
    _debounceTimer?.cancel();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
