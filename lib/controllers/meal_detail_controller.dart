import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/meal_detail_model.dart';
import '../apis.dart';

class MealDetailController extends GetxController {
  // Cache for meal details
  final RxMap<String, MealDetailModel> _mealDetailsCache =
      <String, MealDetailModel>{}.obs;

  // Current meal detail
  final Rx<MealDetailModel?> _currentMealDetail = Rx<MealDetailModel?>(null);

  // Loading state
  final RxBool _isLoading = false.obs;

  // Error state
  final RxString _errorMessage = ''.obs;

  // Getters
  MealDetailModel? get currentMealDetail => _currentMealDetail.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  // Fetch meal detail by ID
  Future<void> fetchMealDetail(String mealId) async {
    try {
      // Check cache first
      if (_mealDetailsCache.containsKey(mealId)) {
        _currentMealDetail.value = _mealDetailsCache[mealId];
        return;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await http.get(Uri.parse(getMealDetailApiUrl(mealId)));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final mealDetailResponse = MealDetailResponse.fromJson(jsonData);

        if (mealDetailResponse.meals.isNotEmpty) {
          final mealDetail = mealDetailResponse.meals.first;

          // Cache the result
          _mealDetailsCache[mealId] = mealDetail;
          _currentMealDetail.value = mealDetail;
        } else {
          _errorMessage.value = 'Meal not found';
          _currentMealDetail.value = null;
        }
      } else {
        _errorMessage.value =
            'Failed to load meal details: ${response.statusCode}';
        _currentMealDetail.value = null;
      }
    } catch (e) {
      _errorMessage.value = 'Error fetching meal details: $e';
      _currentMealDetail.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Add meal detail to cache (for search results)
  void addToCache(MealDetailModel mealDetail) {
    _mealDetailsCache[mealDetail.idMeal] = mealDetail;
  }

  // Clear current meal detail
  void clearCurrentMeal() {
    _currentMealDetail.value = null;
    _errorMessage.value = '';
  }

  // Clear cache
  void clearCache() {
    _mealDetailsCache.clear();
  }
}
