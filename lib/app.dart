import 'package:flutter/material.dart';
import 'package:mobile_final_project/view/onboard_page_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: OnboardingPageView(),
      // home: RegisterPageView(),
      // home: HomePageView(),

      // home: LoginPageView(),
      home: OnboardingPageView(),
    );
  }
}
