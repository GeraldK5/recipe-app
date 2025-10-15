class MealModel {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;

  MealModel({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'idMeal': idMeal, 'strMeal': strMeal, 'strMealThumb': strMealThumb};
  }
}

class MealsResponse {
  final List<MealModel> meals;

  MealsResponse({required this.meals});

  factory MealsResponse.fromJson(Map<String, dynamic> json) {
    return MealsResponse(
      meals:
          (json['meals'] as List<dynamic>?)
              ?.map((item) => MealModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'meals': meals.map((meal) => meal.toJson()).toList()};
  }
}
