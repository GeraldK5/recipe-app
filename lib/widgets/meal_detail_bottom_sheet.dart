import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/meal_detail_controller.dart';
import '../controllers/favorites_controller.dart';
import '../constants.dart';

class MealDetailBottomSheet extends StatelessWidget {
  final String mealId;

  const MealDetailBottomSheet({Key? key, required this.mealId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MealDetailController());
    final favoritesController = Get.put(FavoritesController());

    // Fetch meal details when bottom sheet opens
    controller.fetchMealDetail(mealId);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error: ${controller.errorMessage}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.fetchMealDetail(mealId),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final meal = controller.currentMealDetail;
              if (meal == null) {
                return Center(child: Text('No meal details available'));
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal Image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          meal.strMealThumb,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Icon(Icons.fastfood, size: 80),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Meal Name and Favorite Button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.strMeal,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Obx(() {
                          final isFavorite = favoritesController.isFavorite(
                            meal.idMeal,
                          );
                          return InkWell(
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              await favoritesController.toggleFavorite(
                                meal.idMeal,
                              );

                              // Show snackbar
                              Get.snackbar(
                                isFavorite ? 'Removed' : 'Added',
                                '${meal.strMeal} ${isFavorite ? 'removed from' : 'added to'} favorites',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: Duration(seconds: 1),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isFavorite
                                    ? Colors.red.shade100
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? Colors.red
                                    : Colors.grey[600],
                                size: 28,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Category, Area, Tags
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildChip(
                          icon: Icons.category,
                          label: meal.strCategory,
                          color: primaryColor,
                        ),
                        _buildChip(
                          icon: Icons.public,
                          label: meal.strArea,
                          color: Colors.blue,
                        ),
                        if (meal.strTags != null && meal.strTags!.isNotEmpty)
                          _buildChip(
                            icon: Icons.label,
                            label: meal.strTags!,
                            color: Colors.green,
                          ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Instructions
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        meal.strInstructions,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    SizedBox(height: 25),

                    // Ingredients
                    Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Ingredients List
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: meal.ingredients.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey[300]),
                        itemBuilder: (context, index) {
                          final ingredient = meal.ingredients[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Ingredient icon
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 20,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),

                                // Ingredient name
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    ingredient.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Arrow
                                Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(width: 10),

                                // Measure
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    ingredient.measure,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    // YouTube Link (if available)
                    if (meal.strYoutube != null && meal.strYoutube!.isNotEmpty)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Open YouTube link
                            Get.snackbar(
                              'YouTube',
                              'Open: ${meal.strYoutube}',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          icon: Icon(Icons.play_circle_outline),
                          label: Text('Watch Video'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
