import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category_model.dart';
import '../apis.dart';

class CategoryController extends GetxController {
  // Observable list of categories
  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;

  // Loading state
  final RxBool _isLoading = false.obs;

  // Error state
  final RxString _errorMessage = ''.obs;

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Fetch categories from API
  Future<void> fetchCategories() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await http.get(Uri.parse(categoriesApiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final categoriesResponse = CategoriesResponse.fromJson(jsonData);
        _categories.value = categoriesResponse.categories;
      } else {
        _errorMessage.value =
            'Failed to load categories: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage.value = 'Error fetching categories: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await fetchCategories();
  }
}
