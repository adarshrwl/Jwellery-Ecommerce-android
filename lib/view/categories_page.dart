import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Categories Page',
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'Montserrat-Bold',
          color: Colors.brown,
        ),
      ),
    );
  }
}
