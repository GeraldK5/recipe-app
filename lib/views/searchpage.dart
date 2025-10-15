import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/views/overview.dart';
import 'package:recipe_app/controllers/meal_detail_controller.dart';
import 'package:recipe_app/controllers/favorites_controller.dart';
import 'package:recipe_app/models/meal_detail_model.dart';
import 'package:recipe_app/apis.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final mealDetailController = Get.put(MealDetailController());
  final favoritesController = Get.put(FavoritesController());
  final TextEditingController textController = TextEditingController();

  // Search state
  List<MealDetailModel> searchResults = [];
  bool isLoading = false;
  String errorMessage = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    textController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Search with debouncing
  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear results if query is empty
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        errorMessage = '';
        isLoading = false;
      });
      return;
    }

    // Set loading state
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // Start new debounce timer (500ms)
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  // Perform actual search
  Future<void> _performSearch(String query) async {
    try {
      final response = await http.get(Uri.parse(getSearchMealsApiUrl(query)));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final mealsResponse = MealDetailResponse.fromJson(jsonData);

        setState(() {
          if (mealsResponse.meals.isNotEmpty) {
            searchResults = mealsResponse.meals;
            errorMessage = '';
          } else {
            searchResults = [];
            errorMessage = 'No meals found for "$query"';
          }
          isLoading = false;
        });
      } else {
        setState(() {
          searchResults = [];
          errorMessage = 'Failed to search meals';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        searchResults = [];
        errorMessage = 'Error searching meals: $e';
        isLoading = false;
      });
    }
  }

  void _clearSearch() {
    textController.clear();
    _debounceTimer?.cancel();
    setState(() {
      searchResults = [];
      errorMessage = '';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  BackButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: primaryColor.withOpacity(0.3),
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: textController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                            : null,
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                        hintText: 'Search meals...',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable search results
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),

                      // Search results
                      if (isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      else if (textController.text.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            'Type to search for meals...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      else if (searchResults.isNotEmpty)
                        ListView.builder(
                          itemCount: searchResults.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final meal = searchResults[index];

                            return ListTile(
                              onTap: () {
                                // Add meal to cache
                                mealDetailController.addToCache(meal);

                                // Navigate to Overview with category and mealId
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Overview(
                                      selectedcategory: meal.strCategory,
                                      selectedMealId: meal.idMeal,
                                    ),
                                  ),
                                );
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  meal.strMealThumb,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.fastfood, size: 25),
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                meal.strMeal,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                meal.strCategory,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Obx(() {
                                    final isFavorite = favoritesController
                                        .isFavorite(meal.idMeal);
                                    return InkWell(
                                      onTap: () async {
                                        HapticFeedback.lightImpact();
                                        await favoritesController
                                            .toggleFavorite(meal.idMeal);

                                        // Show snackbar
                                        Get.snackbar(
                                          isFavorite ? 'Removed' : 'Added',
                                          '${meal.strMeal} ${isFavorite ? 'removed from' : 'added to'} favorites',
                                          snackPosition: SnackPosition.BOTTOM,
                                          duration: Duration(seconds: 1),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey[400],
                                          size: 20,
                                        ),
                                      ),
                                    );
                                  }),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      else
                        SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
