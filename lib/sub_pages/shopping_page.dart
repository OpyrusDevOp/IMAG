import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:imag/components/cart_list.dart';
import 'package:imag/components/product_listing_dialog.dart';
import 'package:imag/components/receipt_pdfview.dart';
import 'package:imag/db_manipulation.dart';
import 'package:path/path.dart' as Path;
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:file_picker/file_picker.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<StatefulWidget> createState() => ShoppingPageState();
}

class ShoppingPageState extends State<ShoppingPage> {
  List<ProductCarting> cart = [];

  void _refreshPage() {
    if (kDebugMode) print(cart);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                child: Text("Reset"),
                onPressed: () {
                  setState(() {
                    cart.clear();
                  });
                },
              ),
            )
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (cart.isNotEmpty)
              FloatingActionButton(
                elevation: 1,
                onPressed: () async {
                 
                  var dir = await FilePicker.platform.saveFile(allowedExtensions: ['pdf'], fileName: 'receipt.pdf');
                  if(dir == null) return;
                  await generatePdfReceipt(cart, dir);
                  await DbManipulation.updateFromSelling(cart);
                  setState(() {
                    cart.clear();
                  });
                },
                tooltip: "Make payment",
                child: const Icon(Icons.description_outlined),
              ),
            const SizedBox(
              width: 20,
            ),
            FloatingActionButton(
              elevation: 0,
              onPressed: () async {
                await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return ProductListingDialog(
                        cart: cart,
                        refreshParent: _refreshPage,
                      );
                    });
              },
              tooltip: "Add product to cart",
              child: const Icon(Icons.add_shopping_cart),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: cart.isEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_shopping_cart_outlined),
                      Text(
                        "Cart is empty !",
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    ],
                  )
                : CartList(
                    products: cart,
                    refreshParent: _refreshPage,
                  ),
          ),
        ),
      );
}
