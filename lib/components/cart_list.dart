import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:imag/global_references.dart';

class CartList extends StatefulWidget {
  final List<ProductCarting> products;
  final Function refreshParent;
  const CartList(
      {super.key, required this.products, required this.refreshParent});

  @override
  State<StatefulWidget> createState() => CartListState();
}

class CartListState extends State<CartList> {
  void deleteProduct(ProductCarting product) {
    setState(() {
      widget.products.remove(product);
    });
    widget.refreshParent();
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
          child: Card(
            child: ListTile(
              leading: (product.productImage != null
                  ? Image.file(
                      File(getImagePath(product.productImage!)),
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                    )),
              title: Text(product.productName),
              subtitle: Text('\$${product.price}'),
              trailing: SizedBox(
                width: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: SpinBox(
                        enabled: true,
                        min: 1,
                        max: product.maxQuantity.toDouble(),
                        value: product.quantity.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            product.quantity = value.toInt();
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () => deleteProduct(product),
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
