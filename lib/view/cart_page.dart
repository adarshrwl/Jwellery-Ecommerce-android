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
  final String baseUrl = 'http://10.0.2.2:5000';
  final AuthService authService = AuthService();

  // Define new color scheme
  final Color primaryColor = Colors.brown;
  final Color accentColor = Colors.brown.shade700;
  final Color backgroundColor = Colors.white;
  final Color cardColor = Colors.grey.shade50;
  final Color textColor = Colors.grey.shade800;
  final Color priceColor = Colors.brown.shade800;

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
      final response = await http.get(
        Uri.parse('$baseUrl/api/cart'),
        headers: {
          'Authorization': 'Bearer ${authService.token}',
          'Content-Type': 'application/json',
        },
      );

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
        // Update the local cart item
        setState(() {
          final index = cart.indexWhere((item) => item.productId == productId);
          if (index != -1) {
            cart[index].quantity = quantity;
          }
          message = 'Cart updated!';
        });
        Future.delayed(
            const Duration(seconds: 2), () => setState(() => message = ''));
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
          message = 'Item removed!';
        });
        Future.delayed(
            const Duration(seconds: 2), () => setState(() => message = ''));
      } else {
        throw Exception('Failed to remove item: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        message = 'Error removing item. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: primaryColor,
        elevation: 0,
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
      body: SafeArea(
        child: Container(
          color: backgroundColor,
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
              : !authService.isAuthenticated()
                  ? _buildLoginMessage()
                  : cart.isEmpty
                      ? _buildEmptyCart()
                      : _buildCartContent(),
        ),
      ),
      bottomNavigationBar: message.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: message.contains('Error')
                  ? Colors.red[700]
                  : Colors.brown[700],
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            )
          : authService.isAuthenticated() && cart.isNotEmpty
              ? _buildCheckoutBar()
              : null,
    );
  }

  Widget _buildLoginMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Please log in to view your cart',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w500, color: textColor),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) =>
                        LoginDialog(primaryColor: primaryColor),
                  );
                  if (result == true) {
                    fetchCart();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Log In', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 22, color: textColor),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                'Items (${cart.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              ...cart.map((item) => CartItemTile(
                    item: item,
                    onUpdateQuantity: updateCart,
                    onRemoveItem: removeItem,
                    primaryColor: primaryColor,
                    priceColor: priceColor,
                    textColor: textColor,
                    cardColor: cardColor,
                  )),
              const SizedBox(height: 20),
              OrderSummaryCard(
                cart: cart,
                primaryColor: primaryColor,
                priceColor: priceColor,
                textColor: textColor,
                cardColor: cardColor,
              ),
              const SizedBox(height: 70), // Space for bottom checkout bar
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    final subtotal =
        cart.fold<double>(0, (sum, item) => sum + item.price * item.quantity);
    const shippingFee = 209.0;
    final total = subtotal + shippingFee;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Rs. ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: priceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                // Implement checkout navigation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'CHECKOUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Login Dialog - updated with new color scheme
class LoginDialog extends StatefulWidget {
  final Color primaryColor;

  const LoginDialog({Key? key, required this.primaryColor}) : super(key: key);

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log In'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon:
                    Icon(Icons.email_outlined, color: widget.primaryColor),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.primaryColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon:
                    Icon(Icons.lock_outlined, color: widget.primaryColor),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.primaryColor, width: 2),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  setState(() {
                    isLoading = true;
                  });
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
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Log In'),
        ),
      ],
    );
  }
}

// Updated cart item tile with new color scheme
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final Function(String, int) onUpdateQuantity;
  final Function(String) onRemoveItem;
  final Color primaryColor;
  final Color priceColor;
  final Color textColor;
  final Color cardColor;

  const CartItemTile({
    Key? key,
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.primaryColor,
    required this.priceColor,
    required this.textColor,
    required this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.image.startsWith('http')
        ? item.image
        : 'http://10.0.2.2:5000${item.image}';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      color: priceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Adjuster
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Decrease button
                            InkWell(
                              onTap: () => onUpdateQuantity(item.productId,
                                  item.quantity > 1 ? item.quantity - 1 : 1),
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: primaryColor,
                                ),
                              ),
                            ),

                            // Quantity display
                            Container(
                              alignment: Alignment.center,
                              width: 30,
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Increase button
                            InkWell(
                              onTap: () => onUpdateQuantity(
                                  item.productId, item.quantity + 1),
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Remove button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => onRemoveItem(item.productId),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Improved Order Summary Card with new color scheme
class OrderSummaryCard extends StatelessWidget {
  final List<CartItem> cart;
  final Color primaryColor;
  final Color priceColor;
  final Color textColor;
  final Color cardColor;

  const OrderSummaryCard({
    Key? key,
    required this.cart,
    required this.primaryColor,
    required this.priceColor,
    required this.textColor,
    required this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtotal =
        cart.fold<double>(0, (sum, item) => sum + item.price * item.quantity);
    const shippingFee = 209.0;
    final total = subtotal + shippingFee;

    return Card(
      elevation: 1,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Items Total', subtotal),
            const SizedBox(height: 8),
            _buildSummaryRow('Shipping Fee', shippingFee),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Rs. ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: priceColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          'Rs. ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
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
