import 'package:imag/global_references.dart';
import 'package:path/path.dart';

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
}
