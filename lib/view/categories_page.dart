import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../widgets/product_card.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String? selectedCategory;
  List<Product> products = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts([String? category]) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      String url = 'http://localhost:5000/api/products';
      if (category != null) {
        url += '?category=${Uri.encodeComponent(category)}';
      }
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          products = data.map((e) => Product.fromJson(e)).toList();
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching products: $e';
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void handleCategoryClick(String category) {
    setState(() {
      selectedCategory = category;
    });
    fetchProducts(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryButton('AD', 'assets/ad.png', 'AD Earrings'),
                    _buildCategoryButton(
                        'Diamond', 'assets/di.png', 'Diamond Earrings'),
                    _buildCategoryButton(
                        'Gold', 'assets/go.png', 'Gold Earrings'),
                    _buildCategoryButton(
                        'Indian', 'assets/in.png', 'Indian Earrings'),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                selectedCategory != null
                    ? '$selectedCategory Earrings'
                    : 'All Earrings',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Montserrat-Bold',
                  color: Colors.brown,
                ),
              ),
            ),
          ),
          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (products.isEmpty)
            const SliverToBoxAdapter(
              child: Center(child: Text('No products found in this category.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
    );
  }

  Widget _buildCategoryButton(String category, String imagePath, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () => handleCategoryClick(category),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: selectedCategory == category
                ? Colors.brown.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            border: Border.all(
              color: selectedCategory == category
                  ? Colors.brown
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selectedCategory == category
                      ? Colors.brown
                      : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
