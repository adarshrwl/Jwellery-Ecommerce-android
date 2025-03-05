import 'package:flutter/material.dart';

import 'splash_page_view.dart';

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/1.jpeg',
      'title': 'Discover Gems',
      'description': 'Explore the best collections tailored for you.',
    },
    {
      'image': 'assets/images/3.jpeg',
      'title': 'Shop Seamlessly',
      'description': 'Experience smooth and secure shopping.',
    },
    {
      'image': 'assets/images/7.jpeg',
      'title': 'Fast Delivery',
      'description': 'Get your favorite items delivered swiftly.',
    },
  ];

  void _onSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashPageView()),
    );
  }

  void _onNext() {
    if (_currentPage == _onboardingData.length - 1) {
      _onSkip();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background images
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              final data = _onboardingData[index];
              return Image.asset(
                data['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          // Text content and navigation buttons
          Positioned(
            bottom: 100, // Adjusts position for text at the lower part
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  _onboardingData[_currentPage]['title']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat-Bold', // Montserrat-Bold
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _onboardingData[_currentPage]['description']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat-Bold', // Montserrat-Bold
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Skip and Next buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat-Italic', // Montserrat-Italic
                      color: Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.black
                            : Colors.black38,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _onNext,
                  child: Text(
                    _currentPage == _onboardingData.length - 1
                        ? 'Finish'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat-Italic', // Montserrat-Italic
                      color: Colors.black,
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
