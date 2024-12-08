import 'package:imag/global_references.dart';
import 'package:path/path.dart';

class ProductCarting {
  int id;
  String? productImage;
  String productName;
  int quantity;
  int maxQuantity;
  int price;

  ProductCarting(this.id, this.productName, this.price,
      {this.productImage, this.maxQuantity = 1, this.quantity = 1});
  factory ProductCarting.fromMap(Map<String, dynamic> map) {
    return ProductCarting(
      map['id'] as int,
      map['productName'],
      map['price'] as int,
      productImage: map['productImage'] != null
          ? join(dbAssetsPath, "Images", map['productImage']!)
          : null,
      maxQuantity: map['quantity'] ?? 0, // Default to 0 if null
    );
  }

  factory ProductCarting.fromProduct(Product product) =>
      ProductCarting(product.id, product.productName, product.price,
          productImage: product.productImage, maxQuantity: product.quantity);

  // Optional: toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productImage': productImage,
      'productName': productName,
      'price': price,
      'maxQuantity': maxQuantity,
      'quantity': quantity,
    };
  }

  // Override equality to compare by id
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Product) return id == other.id;
    if (other is ProductCarting) return id == other.id;

    return false;
  }

  // Override hashCode to ensure uniqueness based on id
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $productName)';
}

class Product {
  int id;
  String? productImage;
  String productName;
  int quantity;
  int price;

  Product(this.id, this.productName, this.price,
      {this.productImage, this.quantity = 0});
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      map['id'] as int,
      map['productName'],
      map['price'] as int,
      productImage: map['productImage'] != null
          ? join(dbAssetsPath, "Images", map['productImage']!)
          : null,
      quantity: map['quantity'] ?? 0, // Default to 0 if null
    );
  }

  // Optional: toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productImage': productImage,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  // Override equality to compare by id
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ProductCarting) return id == other.id;
    if (other is! Product) return false;

    return id == other.id;
  }

  // Override hashCode to ensure uniqueness based on id
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $productName)';
}
