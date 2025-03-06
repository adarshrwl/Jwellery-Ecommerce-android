import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetails extends StatefulWidget {
  final String productId;

  const ProductDetails({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  Map<String, dynamic>? product;
  bool isLoading = true;
  String error = '';
  int quantity = 1;
  Map<String, dynamic> review = {'rating': 0, 'comment': ''};
  bool userHasReviewed = false;
  TextEditingController quantityController = TextEditingController();
  TextEditingController reviewRatingController = TextEditingController();
  TextEditingController reviewCommentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    quantityController.text = '1'; // Initial value
    reviewRatingController.text = '0'; // Initial value for rating
    reviewCommentController.text = ''; // Initial value for comment
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/products/${widget.productId}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          product = jsonDecode(response.body);
          checkUserReview();
          isLoading = false;
          // Update quantity controller if stock is available
          if (product!['stock'] > 0) {
            quantity = 1;
            quantityController.text = quantity.toString();
          }
        });
      } else {
        setState(() {
          error = 'Failed to load product details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching product details: $e';
        isLoading = false;
      });
    }
  }

  void checkUserReview() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && product != null) {
      try {
        final payload = jsonDecode(
            ascii.decode(base64.decode(base64.normalize(token.split('.')[1]))));
        final userId = payload['id'].toString();
        setState(() {
          userHasReviewed =
              product!['reviews'].any((r) => r['user']?.toString() == userId);
        });
      } catch (e) {
        print('Error parsing token: $e');
      }
    }
  }

  Future<void> handleAddToCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to add items to the cart."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': widget.productId,
          'name': product!['name'],
          'price': product!['price'],
          'image': product!['image'],
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${product!['name']} added to cart!"),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add to cart. Please try again."),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${error.toString()}"),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void handleQuantityChange(String value) {
    final newQuantity = int.tryParse(value) ?? 1;
    final maxQuantity = product != null
        ? (product!['stock'] as int? ?? 0)
        : 0; // Safely get stock as int
    setState(() {
      quantity =
          newQuantity.clamp(1, maxQuantity); // Limit to 1 to stock amount
      quantityController.text = quantity.toString();
    });
  }

  void handleReviewChange(String field, String value) {
    setState(() {
      if (field == 'rating') {
        int rating = int.tryParse(value) ?? 0;
        rating = rating.clamp(1, 5); // Ensure rating is between 1 and 5
        review[field] = rating;
        reviewRatingController.text = rating.toString();
      } else {
        review[field] = value;
        reviewCommentController.text = value;
      }
    });
  }

  Future<void> handleSubmitReview() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to leave a review."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:5000/api/products/${widget.productId}/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(review),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Review submitted successfully!"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          review = {'rating': 0, 'comment': ''};
          reviewRatingController.text = '0';
          reviewCommentController.text = '';
        });
        fetchProduct(); // Refresh product data to show the new review
      } else if (jsonDecode(response.body)['message'] ==
          "You have already reviewed this product") {
        setState(() => userHasReviewed = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You have already reviewed this product."),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting review: ${error.toString()}"),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.brown,
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(
                    child: Text(error,
                        style: const TextStyle(color: Colors.black)))
                : product == null
                    ? const Center(
                        child: Text('Product not found',
                            style: TextStyle(color: Colors.black)))
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: AspectRatio(
                                        aspectRatio: 4 / 3,
                                        child: Image.network(
                                          product!['image'].startsWith('http')
                                              ? product!['image']
                                              : 'http://10.0.2.2:5000${product!['image']}',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product!['name'],
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Rs. ${product!['price'].toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Category: ${product!['category']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            product!['stock'] > 0
                                                ? 'In Stock: ${product!['stock']}'
                                                : 'Out of Stock',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Description',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            product!['description'] ??
                                                'No description available',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          if (product!['stock'] > 0) ...[
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Quantity:',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                SizedBox(
                                                  width: 80,
                                                  child: TextFormField(
                                                    controller:
                                                        quantityController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText: '1',
                                                    ),
                                                    onChanged:
                                                        handleQuantityChange,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                ElevatedButton(
                                                  onPressed: handleAddToCart,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 12,
                                                      horizontal: 20,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Add to Cart',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reviews (${product!['reviews']?.length ?? 0})',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (product!['reviews'] == null ||
                                          product!['reviews'].isEmpty)
                                        const Text(
                                          'No reviews yet.',
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )
                                      else
                                        ...product!['reviews']
                                            .map<Widget>((review) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'User ${review['user']?.toString() ?? 'Anonymous'} - ${review['rating'] ?? 'N/A'}/5',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  review['comment'] ??
                                                      'No comment provided',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                const Divider(
                                                    color: Colors.grey),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      const SizedBox(height: 16),
                                      FutureBuilder<String?>(
                                        future: SharedPreferences.getInstance()
                                            .then((prefs) =>
                                                prefs.getString('token')),
                                        builder: (context, snapshot) {
                                          final token = snapshot.data;
                                          if (token == null) {
                                            return const Text(
                                              'Please log in to leave a review.',
                                              style: TextStyle(
                                                  color: Colors.black54),
                                            );
                                          }
                                          if (userHasReviewed) {
                                            return const Text(
                                              'You have already reviewed this product.',
                                              style: TextStyle(
                                                  color: Colors.black54),
                                            );
                                          }
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Leave a Review',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller:
                                                    reviewRatingController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Rating (1-5)',
                                                  labelStyle: TextStyle(
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (value) =>
                                                    handleReviewChange(
                                                        'rating', value),
                                              ),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller:
                                                    reviewCommentController,
                                                maxLines: 3,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Comment',
                                                  labelStyle: TextStyle(
                                                      color: Colors.black54),
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (value) =>
                                                    handleReviewChange(
                                                        'comment', value),
                                              ),
                                              const SizedBox(height: 16),
                                              ElevatedButton(
                                                onPressed: handleSubmitReview,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 12,
                                                    horizontal: 20,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Submit Review',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }
}
