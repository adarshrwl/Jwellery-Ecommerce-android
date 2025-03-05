import 'package:flutter/material.dart';
import 'login_page_view.dart';
import 'categories_page.dart';
import 'top_rated_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import '../services/auth_service.dart';
import './home_content.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({Key? key}) : super(key: key);

  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  int _currentIndex = 0;
  final AuthService authService = AuthService();

  // List of pages for each tab
  final List<Widget> _pages = const [
    HomeContent(), // Home page content
    CategoriesPage(), // Categories page
    TopRatedProductsPage(), // Top Rated page
    CartPage(), // Cart page
    ProfilePage(), // Profile page
  ];

  @override
  void initState() {
    super.initState();
    authService.loadToken(); // Load token on page init
  }

  @override
  Widget build(BuildContext context) {
    if (!authService.isAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPageView()),
        );
      });
      return const SizedBox.shrink(); // Placeholder while redirecting
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        title: const Text(
          'Gemsera',
          style: TextStyle(
            fontFamily: 'Montserrat-Italic',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPageView()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.brown[600],
        unselectedItemColor: Colors.brown[300],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Top Rated',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
