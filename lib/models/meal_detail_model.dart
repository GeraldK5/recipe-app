class MealDetailModel {
  final String idMeal;
  final String strMeal;
  final String? strMealAlternate;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String? strTags;
  final String? strYoutube;
  final List<Ingredient> ingredients;
  final String? strSource;

  MealDetailModel({
    required this.idMeal,
    required this.strMeal,
    this.strMealAlternate,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    this.strTags,
    this.strYoutube,
    required this.ingredients,
    this.strSource,
  });

  factory MealDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse ingredients and measures
    List<Ingredient> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;

      if (ingredient != null &&
          ingredient.isNotEmpty &&
          ingredient.trim().isNotEmpty) {
        ingredients.add(
          Ingredient(name: ingredient.trim(), measure: measure?.trim() ?? ''),
        );
      }
    }

    return MealDetailModel(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealAlternate: json['strMealAlternate'],
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strTags: json['strTags'],
      strYoutube: json['strYoutube'],
      ingredients: ingredients,
      strSource: json['strSource'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealAlternate': strMealAlternate,
      'strCategory': strCategory,
      'strArea': strArea,
      'strInstructions': strInstructions,
      'strMealThumb': strMealThumb,
      'strTags': strTags,
      'strYoutube': strYoutube,
      'strSource': strSource,
    };

    // Add ingredients and measures
    for (int i = 0; i < ingredients.length; i++) {
      json['strIngredient${i + 1}'] = ingredients[i].name;
      json['strMeasure${i + 1}'] = ingredients[i].measure;
    }

    return json;
  }
}

class Ingredient {
  final String name;
  final String measure;

  Ingredient({required this.name, required this.measure});
}

class MealDetailResponse {
  final List<MealDetailModel> meals;

  MealDetailResponse({required this.meals});

  factory MealDetailResponse.fromJson(Map<String, dynamic> json) {
    return MealDetailResponse(
      meals:
          (json['meals'] as List<dynamic>?)
              ?.map(
                (item) =>
                    MealDetailModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'meals': meals.map((meal) => meal.toJson()).toList()};
  }
}
