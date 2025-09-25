import 'package:flutter_axios/flutter_axios.dart';

/// 产品模型 - 用于测试多个类的 JSON 映射
@AxiosJson()
class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> tags;
  final bool available;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.tags = const [],
    this.available = true,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    List<String>? tags,
    bool? available,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      available: available ?? this.available,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, available: $available}';
  }
}
