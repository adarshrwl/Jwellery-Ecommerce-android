class Review {
  final String id;
  final String userId;
  final String username;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.username,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'Anonymous',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String description;
  final double averageRating;
  final List<Review>? reviews;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.averageRating,
    this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse reviews if available
    List<Review>? reviewsList;
    if (json['reviews'] != null) {
      reviewsList = (json['reviews'] as List)
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList();
    }

    // Calculate average rating if not provided but reviews are available
    double avgRating = json['averageRating']?.toDouble() ?? 0.0;
    if (avgRating == 0.0 && reviewsList != null && reviewsList.isNotEmpty) {
      avgRating = reviewsList.fold(0.0, (sum, review) => sum + review.rating) /
          reviewsList.length;
    }

    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      averageRating: avgRating,
      reviews: reviewsList,
    );
  }
}
