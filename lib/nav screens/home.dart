import 'package:flutter/material.dart';
import 'package:meal_planner/other%20screens/tags.dart';
import '../other screens/popular.dart';
import '../models/instances.dart';
import '../other screens/dish.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Dish> dishes = [
    Dish(name: 'Pizza', type: 'Italian', tags: ['Soup Lover', 'Vegan']),
    Dish(name: 'Burger', type: 'American', tags: ['Soup Lover']),
    Dish(name: 'Sushi', type: 'Japanese', tags: ['Picky Eater']),
    Dish(name: 'Taco', type: 'Mexican', tags: ['Loves Sweet']),
  ];
  final Map<String, List<String>> tags = {
    'Soup Lover': ['Pizza', 'Burger', 'Taco'],
    'Picky Eater': ['Sushi'],
    'Loves Sweet': ['Taco'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Text(
              'Meal.io',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7E8),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search Recipes',
                hintStyle: TextStyle(color: Color(0xFF9F9B98)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF9F9B98)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              ),
              style: TextStyle(color: Color(0xFF9F9B98)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Popular Food Recipes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PopularListScreen()));
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                      color: Color(0xFFD0AD6D),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(4, (index) {
                final dish = dishes[index];
                return GestureDetector(
                  onTap: () {
                    // Handle onTap event, e.g., navigate to dish details page
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DishScreen()));
                  },
                  child: Card(
                    color: const Color(0xFFBACBDB).withOpacity(.61),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            dish.type ?? 'Type',
                            style: const TextStyle(
                                color: Color(0xFFD0AD6D),
                                overflow: TextOverflow.visible),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dish.name,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.bold,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              thickness: 1,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Tags',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'View all',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                    color: Color(0xFFD0AD6D),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 4.0, // Adjust spacing as needed
                mainAxisSpacing: 4.0, // Adjust spacing as needed
                childAspectRatio:
                    3.0, // Adjust for desired aspect ratio (optional)
              ),
              itemBuilder: (context, index) {
                final tag = tags.entries.elementAt(index).key;
                final dishes = tags.entries.elementAt(index).value;
                return GestureDetector(
                  onTap: () {
                    // Handle onTap event
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TagScreen(),
                        ));
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50, // Set fixed height for consistency
                        decoration: BoxDecoration(
                          color: const Color(0xFFDED8DC).withOpacity(0.61),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      const SizedBox(
                          width: 8.0), // Reduced space between icon and text

                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dishes.length} Foods',
                              style: const TextStyle(
                                  color: Color(0xFF628093),
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(
                                height:
                                    2.0), // Reduced space between text lines

                            Text(
                              tag,
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF333333),
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: tags.length,
            ),
          ),
        ],
      ),
    );
  }
}
