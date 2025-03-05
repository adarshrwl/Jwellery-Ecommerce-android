import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onViewDetails;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onViewDetails,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Prepend backend URL if needed
    final imageUrl = product.image.startsWith('http')
        ? product.image
        : 'http://localhost:5000${product.image}';
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          Expanded(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat-Bold',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Rs. ${product.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Rating: ${product.averageRating.toStringAsFixed(1)}/5 (${product.reviewCount} reviews)",
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onViewDetails,
                child: const Text("View Details"),
              ),
              ElevatedButton(
                onPressed: onAddToCart,
                child: const Text("Add to Cart"),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
