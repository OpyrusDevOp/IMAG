import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:imag/DataTypes/product.dart';

class ProductList extends StatefulWidget {
  final List<Product> products;

  const ProductList({super.key, required this.products});

  @override
  State<StatefulWidget> createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  Future<void> _dialogBuilder(BuildContext context, Product product) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(product.productName),
            content: const Text(
              'A dialog is a type of modal window that\n'
              'appears in front of app content to\n'
              'provide critical information, or prompt\n'
              'for a decision to be made.',
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Save'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void deleteProductAction(Product product) {
    setState(() {
      widget.products.remove(product);
    });
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
            onTap: () {},
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
                      onPressed: () => _dialogBuilder(context, product),
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
