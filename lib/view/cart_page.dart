import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Cart Page',
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'Montserrat-Bold',
          color: Colors.brown,
        ),
      ),
    );
  }
}
