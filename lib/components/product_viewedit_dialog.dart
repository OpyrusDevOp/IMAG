import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:path/path.dart';

import '../db_manipulation.dart';
import '../global_references.dart';

class ProductVieweditDialog extends StatefulWidget {
  final Product product;
  final Function update;
  const ProductVieweditDialog(
      {super.key, required this.product, required this.update});

  @override
  State<ProductVieweditDialog> createState() => _ProductVieweditDialogState();
}

class _ProductVieweditDialogState extends State<ProductVieweditDialog> {
  final _formKey = GlobalKey<FormState>();
  bool editMode = false;
  String? imagePath;

  late TextEditingController productNameController;
  late TextEditingController productQuantityController;
  late TextEditingController productPriceController;

  @override
  void initState() {
    super.initState();
    productNameController =
        TextEditingController(text: widget.product.productName);
    productQuantityController =
        TextEditingController(text: widget.product.quantity.toString());
    productPriceController =
        TextEditingController(text: widget.product.price.toString());
    imagePath = widget.product.productImage;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsOverflowButtonSpacing: 20,
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(editMode ? 'Edit Product' : 'View Product'),
          IconButton(
            icon: Icon(editMode ? Icons.visibility : Icons.edit),
            onPressed: () {
              setState(() {
                editMode = !editMode;
              });
            },
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section

            SizedBox(
              height: 500,
              width: 500,
              child: (imagePath != null)
                  ? Image.asset(
                      imagePath!,
                      fit: BoxFit.contain,
                      height: 500,
                      width: 500,
                    )
                  : Icon(Icons.image_not_supported),
            ),
            if (editMode)
              TextButton.icon(
                onPressed: () async {
                  var file = (await FilePicker.platform.pickFiles(
                    compressionQuality: 30,
                    type: FileType.image,
                    allowMultiple: false,
                    onFileLoading: (FilePickerStatus status) => print(status),
                    lockParentWindow: true,
                  ))
                      ?.files[0];

                  if (file != null) {
                    setState(() {
                      imagePath = file.path;
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
              ),

            // Product Name
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(),
                    )),
                readOnly: !editMode,
                controller: productNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
              ),
            ),

            // Quantity
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(),
                    )),
                keyboardType: TextInputType.number,
                readOnly: !editMode,
                controller: productQuantityController,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
            ),

            // Price
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(),
                    ),
                    contentPadding: EdgeInsets.all(10)),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                readOnly: !editMode,
                controller: productPriceController,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        if (editMode)
          TextButton(
            onPressed: () => saveEdition(context),
            child: const Text('Save'),
          ),
      ],
    );
  }

  Future<void> saveEdition(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var productName = productNameController.text;
      var productQuantity = int.parse(productQuantityController.text);
      var productPrice = int.parse(productPriceController.text);

      String? productImageName;
      if (imagePath != null) {
        var image = File(imagePath!);
        productImageName =
            "${productName.replaceAll(" ", "_")}_${Guid.generate()}.png";
        var newPath = join(dbAssetsPath, "Images");

        if (!Directory(newPath).existsSync()) {
          await Directory(newPath).create();
        }

        newPath = join(newPath, productImageName);

        await image.copy(newPath);
      }

      var updatedProduct = Product(
        widget.product.id,
        productName,
        productPrice,
        quantity: productQuantity,
        productImage: productImageName,
      );

      // Update the product in the database
      DbManipulation.updateProduct(updatedProduct, context);

      widget.update();
    }
  }
}
