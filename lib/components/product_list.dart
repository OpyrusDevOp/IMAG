import 'dart:io';

import 'package:flutter/material.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:imag/global_references.dart';

class ProductList extends StatefulWidget {
  final List<Product> products;
  final Function(Product)? showProduct;
  final Function(Product)? deleteProduct;
  final Function(Product)? addProduct;
  const ProductList(
      {super.key,
      required this.products,
      this.addProduct,
      this.showProduct,
      this.deleteProduct});

  @override
  State<StatefulWidget> createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
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
          child: Card(
            child: ListTile(
              leading: SizedBox(
                width: 60, // Set a fixed width
                height: 60, // Set a fixed height
                child: (product.productImage != null
                    ? Image.file(
                        File(getImagePath(product.productImage!)),
                        fit: BoxFit.fill,
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
                  Column(
                    children: [
                      Expanded(
                        child: Text(
                          "Available",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        product.quantity.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  if (widget.addProduct != null)
                    IconButton(
                      onPressed: () => widget.addProduct!(product),
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                    ),
                  if (widget.showProduct != null)
                    IconButton(
                      onPressed: () => widget.showProduct!(product),
                      icon: const Icon(Icons.remove_red_eye_outlined),
                    ),
                  if (widget.deleteProduct != null)
                    IconButton(
                      onPressed: () => widget.deleteProduct!(product),
                      icon: const Icon(Icons.delete),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
