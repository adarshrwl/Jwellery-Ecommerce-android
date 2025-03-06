import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_final_project/view/onboard_page_view.dart';
import 'package:mobile_final_project/services/auth_service.dart';
import './view/home_page_view.dart';
import './view/payment_demo.dart';
import './view//PaymentSuccess.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51Qy9TFICDuzmFrlVIFbeDOoHj8e6fHSQlnYw3KdeDJPJHaDgRvuM0C5jR9rryMkrUxhatYPhJijRIN59Jb1qFeRn00lLB4mzmW';
  await Stripe.instance.applySettings();
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
      initialRoute: authService.isAuthenticated() ? '/home' : '/onboard',
      routes: {
        '/onboard': (context) => const OnboardingPageView(),
        '/home': (context) => const HomePageView(),
        '/payment': (context) => const PaymentDemoPage(),
        '/payment-success': (context) => const PaymentSuccessPage(),
      },
      home: _getInitialPage(),
    );
  }

  Widget _getInitialPage() {
    return authService.isAuthenticated()
        ? const HomePageView()
        : const OnboardingPageView();
  }
}
