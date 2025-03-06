import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_final_project/view/onboard_page_view.dart';
import 'package:mobile_final_project/services/auth_service.dart';
import './view/home_page_view.dart';
import './view/payment_demo.dart';

void main() async {
  // Ensure Flutter bindings are initialized for async operations
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51Qy9TFICDuzmFrlVIFbeDOoHj8e6fHSQlnYw3KdeDJPJHaDgRvuM0C5jR9rryMkrUxhatYPhJijRIN59Jb1qFeRn00lLB4mzmW';

  // Initialize AuthService to load the token from SharedPreferences
  await AuthService().loadToken();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Load token on app start (already done in main, but safe to call again)
    authService.loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemsera',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Montserrat',
      ),
      home: _getInitialPage(),
    );
  }

  Widget _getInitialPage() {
    if (authService.isAuthenticated()) {
      return const HomePageView(); // User is logged in, go to home
    } else {
      return const OnboardingPageView(); // User not logged in, show onboarding
    }
  }
}
