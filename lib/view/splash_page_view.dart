import 'package:flutter/material.dart';

import 'login_page_view.dart';

class SplashPageView extends StatefulWidget {
  const SplashPageView({super.key});

  @override
  State<SplashPageView> createState() => _SplashPageViewState();
}

class _SplashPageViewState extends State<SplashPageView> {
  bool _animateImage = false;

  @override
  void initState() {
    super.initState();
    // Start the animation after a slight delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _animateImage = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background Image
          AnimatedPositioned(
            top: _animateImage ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            bottom: 0,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: Image.asset(
              'assets/images/9.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Gemsera',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat-Bold', // Specify the custom font
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to LoginPageView
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPageView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 95, 57, 43),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
