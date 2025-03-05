import 'package:flutter/material.dart';
import 'home_page_view.dart';
import 'register_page_view.dart';
import '../services/auth_service.dart';

class LoginPageView extends StatefulWidget {
  const LoginPageView({Key? key}) : super(key: key);

  @override
  _LoginPageViewState createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService(); // Get the singleton instance

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Ensure token is loaded
    authService.loadToken();
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      print(response);

      if (response['token'] != null) {
        // Token is already stored in SharedPreferences by AuthService
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePageView()),
        );
      } else {
        setState(() {
          errorMessage = "Login failed: No token returned.";
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/images/gemlogo.jpg',
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Login to Gemsera',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat-Bold',
                color: Color.fromARGB(255, 193, 127, 29),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(fontFamily: 'Montserrat-Italic'),
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(fontFamily: 'Montserrat-Italic'),
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 193, 127, 29),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat-Bold',
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterPageView()),
                );
              },
              child: const Text(
                'Don’t have an account? Register',
                style: TextStyle(
                  fontFamily: 'Montserrat-Italic',
                  color: Color.fromARGB(255, 193, 127, 29),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
