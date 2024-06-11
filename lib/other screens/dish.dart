import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class DishScreen extends StatefulWidget {
  const DishScreen({super.key});

  @override
  State<DishScreen> createState() => _DishState();
}

class _DishState extends State<DishScreen> {
  String dishName = 'Dish Name';
  bool isHeartColored = false;
  bool isDishSaved = false;
  List<String> tags = ['tags1', 'tags2'];
  final List<String> items = [
    'Ingredient 1',
    'Ingredient 2',
    'Ingredient 3',
    'Ingredient 4',
    'Ingredient 5',
    'Ingredient 6',
    'Ingredient 7',
    'Ingredient 8',
    'Ingredient 9',
    'Ingredient 10',
  ];

  void _toggleHeartColor() {
    setState(() {
      isHeartColored = !isHeartColored;
    });
  }

  void _toggleSavedColor() {
    setState(() {
      isDishSaved = !isDishSaved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white,

        ),
        child: Column(
                children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.grey,


          ),
          child: Stack(
            children: [
              Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Ionicons.close),
                    color: Colors.white,
                  )),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -50),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Ionicons.checkmark_circle,
                            color: Colors.grey,
                          ),
                          Text(
                            'Hurray, we found a Recipe for you!',
                            style: TextStyle(
                                color: Colors.grey,
                                overflow: TextOverflow.fade),
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: _toggleHeartColor,
                          icon: Icon(
                            isHeartColored
                                ? Ionicons.heart
                                : Ionicons.heart_outline,
                            color: isHeartColored
                                ? const Color(0xFFD0AD6D)
                                : Colors.grey,
                          ))
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                //Make this on Dynamic
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    dishName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF83ABD1)),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: tags.map((tag) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: const Color(0xFFF0F3F6),
                          ),
                          child: Text(tag,
                              style: const TextStyle(
                                  color: Color(0xFFD0AD6D), fontSize: 14.0)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Recipe',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF333333))),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Extra flaky and buttery homemade chocolate croissants',
                      style: TextStyle(color: Color(0xFF8C8C8C)),
                    )),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text('Ingredients: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF564F4F))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Text(
                        '•   $item',
                        style: const TextStyle(
                            fontSize: 14.0,
                            color: Color(0xFF515151)), // Customize text style
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              //Row ng Calories
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF7E8),
                                    borderRadius: BorderRadius.circular(12.0),
                                    image: const DecorationImage(
                                        image: AssetImage(
                                            'assets/Calories.png')),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                const Column(
                                  children: [
                                    Text(
                                      'Calories',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4B8364),
                                          fontSize: 12),
                                    ),
                                    Text(
                                      '15 kcal',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF333333)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              //Row ng Protein
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8E8F8),
                                    borderRadius: BorderRadius.circular(12.0),
                                    image: const DecorationImage(
                                        image: AssetImage(
                                            'assets/Proteins.png')),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                const Column(
                                  children: [
                                    Text(
                                      'Protein',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFA559D9),
                                          fontSize: 12),
                                    ), //mkae it dynamic
                                    Text(
                                      '4 g',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF333333)),
                                    ) //dynamic
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              //Row ng Calories
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6EAFA),
                                    borderRadius: BorderRadius.circular(12.0),
                                    image: const DecorationImage(
                                        image: AssetImage(
                                            'assets/Carbohydrates.png')),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 24.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Carbs',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF5676DC),
                                            fontSize: 12),
                                      ),
                                      Text(
                                        '94 g',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF333333)),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              //Row ng Protein
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCF1E3),
                                    borderRadius: BorderRadius.circular(12.0),
                                    image: const DecorationImage(
                                        image: AssetImage('assets/Fats.png')),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                const Column(
                                  children: [
                                    Text(
                                      'Fats',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE6B44C),
                                          fontSize: 12),
                                    ),
                                    Text(
                                      '12 g',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF333333)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
                ],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: GestureDetector(
          onTap: _toggleSavedColor,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF83ABD1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _toggleSavedColor,
                  icon: Icon(
                    isDishSaved ? Ionicons.bookmark : Ionicons.bookmark_outline,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Save this Recipe',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
