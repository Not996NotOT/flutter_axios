import 'package:flutter_axios/flutter_axios.dart';

/// 产品模型 - 演示复杂类型的 JSON 映射
@JsonSerializable()
class Product {
  final String id;
  final String productName;
  final String description;
  final double price;
  final double originalPrice;
  final bool isAvailable;
  final int stockCount;
  final double rating;
  final int reviewCount;
  final String categoryId;
  final String categoryName;
  final String brandName;
  final List<String> imageUrls;
  final List<String> tags;
  final Map<String, dynamic> specifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.productName,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.isAvailable,
    required this.stockCount,
    required this.rating,
    required this.reviewCount,
    required this.categoryId,
    required this.categoryName,
    required this.brandName,
    required this.imageUrls,
    required this.tags,
    required this.specifications,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 获取折扣百分比
  double get discountPercentage {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - price) / originalPrice * 100);
  }

  /// 是否有折扣
  bool get hasDiscount => price < originalPrice;

  /// 是否有库存
  bool get inStock => stockCount > 0;

  /// 评分描述
  String get ratingDescription {
    if (rating >= 4.5) return '优秀';
    if (rating >= 4.0) return '很好';
    if (rating >= 3.5) return '好';
    if (rating >= 3.0) return '一般';
    return '较差';
  }

  Product copyWith({
    String? id,
    String? productName,
    String? description,
    double? price,
    double? originalPrice,
    bool? isAvailable,
    int? stockCount,
    double? rating,
    int? reviewCount,
    String? categoryId,
    String? categoryName,
    String? brandName,
    List<String>? imageUrls,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isAvailable: isAvailable ?? this.isAvailable,
      stockCount: stockCount ?? this.stockCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brandName: brandName ?? this.brandName,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, productName: $productName, price: ¥$price, rating: $rating}';
  }
}

