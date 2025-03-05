import 'package:flutter/material.dart';

class TopRatedPage extends StatelessWidget {
  const TopRatedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Top Rated Page',
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'Montserrat-Bold',
          color: Colors.brown,
        ),
      ),
    );
  }
}
