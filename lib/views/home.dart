// import 'package:bakery/overview.dart';
import 'package:flutter/material.dart';
import 'package:circular_motion/circular_motion.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/views/overview.dart';
import 'package:recipe_app/widgets/helper.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  final CategoryController categoryController = Get.find<CategoryController>();
  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning ';
    } else if (hour < 18) {
      return 'Good afternoon ';
    } else {
      return 'Good evening ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      backgroundColor: primaryColor,
      drawer: drawer(),
      appBar: appbar(scaffoldkey),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '${greeting()}Hannah,',
                maxLines: 2,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Overview(
                                  ))),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: CircularMotion(
                    behavior: HitTestBehavior.translucent,
                    centerWidget: Container(
                      height: 110,
                      width: 110,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3))
                          ],
                          color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/viewMore.png',
                            height: 80,
                          ),
                          Text('View More', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    children: List.generate(
                        categoryController.categories.length > 5
                            ? 5
                            : categoryController.categories.length, (index) {
                      final category = categoryController.categories[index];
                      return InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Overview(
                                      selectedcategory: category.strCategory,
                                    ))),
                        child: Container(
                          height: 105,
                          width: 105,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3))
                            ],
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  category.strCategoryThumb,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 0,
                                  right: 0,
                                  child: Text(
                                    category.strCategory,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
