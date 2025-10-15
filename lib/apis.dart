const String categoriesApiUrl =
    'https://www.themealdb.com/api/json/v1/1/categories.php';

// Meals API - use category name as parameter
String getMealsApiUrl(String category) =>
    'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category';

// Meal Detail API - use meal ID as parameter
String getMealDetailApiUrl(String mealId) =>
    'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId';

// Search Meals API - use search query as parameter
String getSearchMealsApiUrl(String query) =>
    'https://www.themealdb.com/api/json/v1/1/search.php?s=$query';
