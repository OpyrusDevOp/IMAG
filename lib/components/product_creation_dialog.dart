import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:imag/db_manipulation.dart';
import 'package:imag/global_references.dart';
import 'package:path/path.dart';

class ProductCreationDialog extends StatefulWidget {
  const ProductCreationDialog({super.key});

  @override
  State<StatefulWidget> createState() => ProductCreationDialogState();
}

class ProductCreationDialogState extends State<ProductCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  String? imagePath;

  TextEditingController productNameController = TextEditingController();
  TextEditingController productQuantityController =
      TextEditingController(text: '0');
  TextEditingController productPriceController =
      TextEditingController(text: '0');
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsOverflowButtonSpacing: 20,
      scrollable: true,
      title: const Text('Add New Product'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Picker (dummy button here for simplicity)
            if (imagePath != null)
              Image.asset(
                imagePath!,
                fit: BoxFit.contain,
                height: 500,
                width: 500,
              ),
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

                setState(() {
                  imagePath = file!.path;
                });
              },
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
            ),
            // Product Name Input
            TextFormField(
              decoration: const InputDecoration(labelText: 'Product Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the product name';
                }
                return null;
              },
              controller: productNameController,
            ),
            // Quantity Input
            TextFormField(
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || int.tryParse(value) == null) {
                  return 'Please enter a valid quantity';
                }

                if (int.parse(value) <= 0) {
                  return 'Value must be greater than 0';
                }
                return null;
              },
              controller: productQuantityController,
            ),

            // Price Input
            TextFormField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || int.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }

                if (int.parse(value) <= 0) {
                  return 'Value must be greater than 0';
                }
                return null;
              },
              controller: productPriceController,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
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

                if (!Directory(imageAssetsPath).existsSync()) {
                  await Directory(imageAssetsPath).create();
                }

                var newPath = join(imageAssetsPath, productImageName);

                await image.copy(newPath);
              }

              var product = Product(0, productName, productPrice,
                  quantity: productQuantity, productImage: productImageName);

              DbManipulation.insertProduct(
                  product, context); // Process the product creation here
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
