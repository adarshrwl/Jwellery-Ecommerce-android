class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final double averageRating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.averageRating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double avgRating = 0;
    int reviewsCount = 0;
    if (json['reviews'] != null &&
        json['reviews'] is List &&
        (json['reviews'] as List).isNotEmpty) {
      List reviews = json['reviews'];
      reviewsCount = reviews.length;
      double sum = reviews.fold(
          0, (prev, el) => prev + (el['rating'] is num ? el['rating'] : 0));
      avgRating = sum / reviewsCount;
    }
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] is num ? (json['price'] as num).toDouble() : 0,
      image: json['image'] ?? '',
      averageRating: avgRating,
      reviewCount: reviewsCount,
    );
  }
}
