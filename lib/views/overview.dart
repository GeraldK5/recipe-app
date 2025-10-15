import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/widgets/helper.dart';
import 'package:recipe_app/controllers/category_controller.dart';
import 'package:recipe_app/controllers/meal_controller.dart';
import 'package:recipe_app/controllers/favorites_controller.dart';
import 'package:recipe_app/widgets/meal_detail_bottom_sheet.dart';

class Overview extends StatefulWidget {
  const Overview({super.key, this.selectedcategory, this.selectedMealId});
  final String? selectedcategory;
  final String? selectedMealId;

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> with TickerProviderStateMixin {
  // TODO: Implement Cart controller when needed
  // final cartcontroller = Get.put(Cart());
  final categoryController = Get.put(CategoryController());
  final mealController = Get.put(MealController());
  final favoritesController = Get.put(FavoritesController());

  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  int selectedCategoryIndex = 0; // Initialize with default value
  late ScrollController _scrollController;

  late AnimationController animationController;
  late Animation<double> size;
  Curve bounce = Curves.bounceInOut;
  double hop = 50;
  bool cart = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // Initialize after the first frame to ensure categories are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categoryController.categories.isNotEmpty) {
        // Use provided category or default to first category
        if (widget.selectedcategory != null &&
            widget.selectedcategory!.isNotEmpty) {
          // Find index of the selected category
          final foundIndex = categoryController.categories.indexWhere(
            (cat) =>
                cat.strCategory.toLowerCase() ==
                widget.selectedcategory!.toLowerCase(),
          );
          setState(() {
            selectedCategoryIndex = foundIndex == -1 ? 0 : foundIndex;
          });
        } else {
          setState(() {
            selectedCategoryIndex = 0;
          });
        }

        // Load meals for the selected category
        final selectedCategory =
            categoryController.categories[selectedCategoryIndex].strCategory;
        mealController.setCategory(selectedCategory);

        // If mealId is provided, show the meal detail bottom sheet
        if (widget.selectedMealId != null &&
            widget.selectedMealId!.isNotEmpty) {
          Future.delayed(Duration(milliseconds: 300), () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) =>
                  MealDetailBottomSheet(mealId: widget.selectedMealId!),
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is near the bottom
      if (mealController.hasMore && !mealController.isLoadingMore) {
        mealController.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: appbar(scaffoldkey),
      drawer: drawer(),
      body: Obx(() {
        // Show loading indicator while fetching categories
        if (categoryController.isLoading &&
            categoryController.categories.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        // Show error if categories failed to load
        if (categoryController.errorMessage.isNotEmpty &&
            categoryController.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${categoryController.errorMessage}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => categoryController.fetchCategories(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Show message if no categories available
        if (categoryController.categories.isEmpty) {
          return Center(child: Text('No categories available'));
        }

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Explorer All Categories',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Categories horizontal list
                  Container(
                    height: MediaQuery.of(context).size.height * 0.17,
                    color: primaryColor.withOpacity(0.3),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryController.categories.length,
                      itemBuilder: (context, index) {
                        final category = categoryController.categories[index];
                        final isSelected = selectedCategoryIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryIndex = index;
                            });
                            mealController.setCategory(category.strCategory);
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 10,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.white,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    category.strCategoryThumb,
                                    height: 100,
                                    width: 100,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.fastfood, size: 40);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                category.strCategory,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: isSelected
                                      ? secondaryColor
                                      : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 35),

                  // Meals section
                  Obx(() {
                    final currentCategory = mealController.currentCategory;

                    if (currentCategory.isEmpty) {
                      return Center(child: Text('Select a category'));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                          ),
                          child: Text(
                            'Check out our $currentCategory',
                            style: TextStyle(fontSize: 25),
                          ),
                        ),

                        // Show loading indicator for meals
                        if (mealController.isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (mealController.errorMessage.isNotEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Text('Error: ${mealController.errorMessage}'),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () =>
                                        mealController.refreshCurrentCategory(),
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (mealController.currentMeals.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text('No meals found for this category'),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                              right: 10.0,
                              top: 15.0,
                            ),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: mealController.currentMeals.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final meal =
                                        mealController.currentMeals[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                // Show meal detail bottom sheet
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) =>
                                                      MealDetailBottomSheet(
                                                        mealId: meal.idMeal,
                                                      ),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                            0,
                                                            3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.network(
                                                        meal.strMealThumb,
                                                        height: 80,
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                height: 80,
                                                                width: 100,
                                                                color: Colors
                                                                    .grey[300],
                                                                child: Icon(
                                                                  Icons
                                                                      .fastfood,
                                                                ),
                                                              );
                                                            },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      meal.strMeal,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Obx(() {
                                            final isFavorite =
                                                favoritesController.isFavorite(
                                                  meal.idMeal,
                                                );
                                            return InkWell(
                                              onTap: () async {
                                                HapticFeedback.lightImpact();
                                                await favoritesController
                                                    .toggleFavorite(
                                                      meal.idMeal,
                                                    );

                                                // Show snackbar
                                                Get.snackbar(
                                                  isFavorite
                                                      ? 'Removed'
                                                      : 'Added',
                                                  '${meal.strMeal} ${isFavorite ? 'removed from' : 'added to'} favorites',
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  duration: Duration(
                                                    seconds: 1,
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: isFavorite
                                                      ? Colors.red.shade100
                                                      : Colors.green.shade100,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  isFavorite
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isFavorite
                                                      ? Colors.red
                                                      : const Color.fromARGB(
                                                          255,
                                                          63,
                                                          145,
                                                          65,
                                                        ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // Loading more indicator
                                if (mealController.isLoadingMore)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                // Show "Load More" button if there are more items
                                if (!mealController.isLoadingMore &&
                                    mealController.hasMore)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            mealController.loadMore(),
                                        child: Text('Load More'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
