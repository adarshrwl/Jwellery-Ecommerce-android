import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Page',
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'Montserrat-Bold',
          color: Colors.brown,
        ),
      ),
    );
  }
}
