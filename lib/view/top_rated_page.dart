import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../services/auth_service.dart';

class TopRatedProductsPage extends StatefulWidget {
  const TopRatedProductsPage({Key? key}) : super(key: key);

  @override
  _TopRatedProductsPageState createState() => _TopRatedProductsPageState();
}

class _TopRatedProductsPageState extends State<TopRatedProductsPage> {
  List<Product> products = [];
  bool isLoading = true;
  String error = '';
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchTopRatedProducts();
  }

  Future<void> fetchTopRatedProducts() async {
    if (!authService.isAuthenticated()) {
      setState(() {
        error = 'Please log in to view top rated products';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/products'),
        headers: {'Authorization': 'Bearer ${authService.token}'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Product> productList =
            data.map((e) => Product.fromJson(e)).toList();

        productList.sort((a, b) => b.averageRating.compareTo(a.averageRating));

        setState(() {
          products = productList;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (err) {
      setState(() {
        error = err.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.all(16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Top Rated Products',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Montserrat-Bold',
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'Discover our highest-rated items',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Loading top rated products...'),
                      ],
                    ),
                  ),
                ),
              )
            else if (error.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(15),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onViewDetails: () => _handleViewDetails(product),
                        onAddToCart: () => _handleAddToCart(product),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleViewDetails(Product product) {
    print("View details for: ${product.name}");
  }

  void _handleAddToCart(Product product) {
    print("Add to cart: ${product.name}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} added to cart!"),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
