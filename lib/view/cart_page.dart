import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import './login_page_view.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cart = [];
  bool isLoading = true;
  String message = '';
  final String baseUrl = 'http://localhost:5000';
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    if (!authService.isAuthenticated()) {
      setState(() {
        message = 'Please log in to view your cart.';
        isLoading = false;
      });
      return;
    }

    try {
      print('Fetching cart with token: ${authService.token}');
      final response = await http.get(
        Uri.parse('$baseUrl/api/cart'),
        headers: {
          'Authorization': 'Bearer ${authService.token}',
          'Content-Type': 'application/json',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          cart = (data['items'] as List<dynamic>? ?? [])
              .map((item) => CartItem.fromJson(item))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load cart: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error fetching cart: $error');
      setState(() {
        message = 'Error fetching cart. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> updateCart(String productId, int quantity) async {
    if (!authService.isAuthenticated()) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/cart'),
        headers: {
          'Authorization': 'Bearer ${authService.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );
      if (response.statusCode == 200) {
        setState(() {
          message = 'Cart updated successfully!';
        });
        Future.delayed(
            const Duration(seconds: 3), () => setState(() => message = ''));
      } else {
        throw Exception('Failed to update cart: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        message = 'Error updating cart. Please try again.';
      });
    }
  }

  Future<void> removeItem(String productId) async {
    if (!authService.isAuthenticated()) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart/$productId'),
        headers: {
          'Authorization': 'Bearer ${authService.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          cart.removeWhere((item) => item.productId == productId);
          message = 'Item removed from cart successfully!';
        });
        Future.delayed(
            const Duration(seconds: 3), () => setState(() => message = ''));
      } else {
        throw Exception('Failed to remove item: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        message = 'Error removing item from cart. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.brown,
        actions: [
          if (authService.isAuthenticated())
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authService.logout();
                setState(() {
                  cart = [];
                  message = 'Logged out successfully.';
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPageView()),
                );
              },
            ),
        ],
      ),
      body: Container(
        color: Colors.grey[800],
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : !authService.isAuthenticated()
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Please log in to view your cart.',
                          style: TextStyle(fontSize: 24, color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => const LoginDialog(),
                            );
                            if (result == true) {
                              fetchCart();
                            }
                          },
                          child: const Text('Log In'),
                        ),
                      ],
                    ),
                  )
                : cart.isEmpty
                    ? const Center(
                        child: Text(
                          'Your cart is empty.',
                          style: TextStyle(fontSize: 24, color: Colors.white70),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: CartItemsList(
                              cart: cart,
                              onUpdateQuantity: updateCart,
                              onRemoveItem: removeItem,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: OrderSummarySidebar(cart: cart),
                          ),
                        ],
                      ),
      ),
      bottomSheet: message.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(8),
              color:
                  message.contains('successfully') ? Colors.green : Colors.red,
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}

// Login Dialog for testing
class LoginDialog extends StatefulWidget {
  const LoginDialog({Key? key}) : super(key: key);

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log In'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              final result = await AuthService().login(
                emailController.text,
                passwordController.text,
              );
              if (result['token'] != null) {
                Navigator.pop(context, true);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login failed: $e')),
              );
            }
          },
          child: const Text('Log In'),
        ),
      ],
    );
  }
}

class CartItem {
  final String productId;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product =
        json['product'] is Map ? json['product'] : {'_id': json['product']};
    return CartItem(
      productId: product['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class CartItemsList extends StatelessWidget {
  final List<CartItem> cart;
  final Function(String, int) onUpdateQuantity;
  final Function(String) onRemoveItem;

  const CartItemsList({
    Key? key,
    required this.cart,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: ListView.separated(
        itemCount: cart.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          final item = cart[index];
          final imageUrl = item.image.startsWith('http')
              ? item.image
              : 'http://localhost:5000${item.image}';
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 130,
                      height: 130,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Rs. ${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          QuantityField(
                            quantity: item.quantity,
                            onChanged: (value) =>
                                onUpdateQuantity(item.productId, value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 28),
                  onPressed: () => onRemoveItem(item.productId),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class QuantityField extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const QuantityField({
    Key? key,
    required this.quantity,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => onChanged(quantity > 1 ? quantity - 1 : 1),
        ),
        SizedBox(
          width: 50,
          child: TextField(
            controller: TextEditingController(text: quantity.toString()),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onSubmitted: (value) => onChanged(int.tryParse(value) ?? quantity),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}

class OrderSummarySidebar extends StatelessWidget {
  final List<CartItem> cart;

  const OrderSummarySidebar({Key? key, required this.cart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtotal =
        cart.fold<double>(0, (sum, item) => sum + item.price * item.quantity);
    const shippingFee = 209.0;
    final total = subtotal + shippingFee;

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', subtotal),
            const Divider(color: Colors.grey),
            _buildSummaryRow('Shipping Fee', shippingFee),
            const Divider(color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  'Rs. ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('Buy Now clicked, total: $total');
                // Implement payment navigation here
                // Navigator.pushNamed(context, '/payment', arguments: {'amount': total});
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Buy Now (${cart.length})'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
