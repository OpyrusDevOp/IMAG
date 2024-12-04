import 'package:flutter/material.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:imag/components/product_viewedit_dialog.dart';
import 'package:imag/db_manipulation.dart';

class ProductList extends StatefulWidget {
  List<Product> products;
  Function fetchProduct;
  ProductList({super.key, required this.products, required this.fetchProduct});

  @override
  State<StatefulWidget> createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  Future<void> _showProduct(BuildContext context, Product product) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ProductVieweditDialog(
            product: product,
            update: widget.fetchProduct,
          );
        });
  }

  void deleteProductAction(Product product) async {
    await DbManipulation.deleteProduct(product.id, context);
    widget.fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.products.length,
      prototypeItem: Padding(
        padding: const EdgeInsets.all(5),
        child: Card(
          child: ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Icon(Icons.help, size: 40),
            ),
            title: Text('Product Name'),
            subtitle: Text('\$0'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.remove_red_eye_outlined),
                SizedBox(width: 8),
                Icon(Icons.delete),
              ],
            ),
          ),
        ),
      ),
      itemBuilder: (context, index) {
        final product = widget.products[index];
        return Padding(
          padding: const EdgeInsets.all(5),
          child: InkWell(
            onTap: () => _showProduct(context, product),
            borderRadius: BorderRadius.circular(12),
            child: Card(
              child: ListTile(
                leading: SizedBox(
                  width: 60, // Set a fixed width
                  height: 60, // Set a fixed height
                  child: (product.productImage != null
                      ? Image.asset(
                          product.productImage!,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                        )),
                ),
                title: Text(product.productName),
                subtitle: Text('\$${product.price}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showProduct(context, product),
                      icon: const Icon(Icons.remove_red_eye_outlined),
                    ),
                    IconButton(
                      onPressed: () => deleteProductAction(product),
                      icon: const Icon(Icons.delete),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
