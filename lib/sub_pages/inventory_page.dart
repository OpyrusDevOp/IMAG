import 'package:flutter/material.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:imag/components/product_creation_dialog.dart';
import 'package:imag/components/product_list.dart';
import 'package:imag/components/product_viewedit_dialog.dart';
import 'package:imag/db_manipulation.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<StatefulWidget> createState() => InventoryPageSate();
}

class InventoryPageSate extends State<InventoryPage> {
  final List<DropdownMenuEntry<String>> exportOptions = [
    const DropdownMenuEntry<String>(value: 'PDF', label: 'PDF', enabled: true),
    const DropdownMenuEntry(value: 'CSV', label: 'CSV', enabled: true),
  ];
  Future<void> _showProduct(Product product) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ProductVieweditDialog(
            product: product,
            update: fetchInventory,
            canGoEditMode: true,
          );
        });
  }

  void searchProduct({String? name}) async {
    var searchResult =
        await DbManipulation.selectProduct(productName: name, count: 20);
    var productFromResult = searchResult.map(Product.fromMap).toList();
    setState(() {
      _products = productFromResult;
    });
  }

  void _deleteProduct(Product product) async {
    await DbManipulation.deleteProduct(product.id, context);
    fetchInventory();
  }

  // ignore: prefer_final_fields
  List<Product> _products = [];

  int _currentPage = 0; // The current page number
  final int _itemsPerPage = 10; // Number of items per page

  // Get the items to display on the current page
  List<Product> get _currentPageItems {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _products.sublist(
        startIndex, endIndex < _products.length ? endIndex : _products.length);
  }

  // Function to go to the next page
  void _nextPage() {
    if (_currentPage < (_products.length / _itemsPerPage).ceil() - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  // Function to go to the previous page
  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  Future<void> _showProductCreationDialog() => showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ProductCreationDialog();
      });

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    var productsMap = await DbManipulation.selectProduct();
    setState(() {
      _products = productsMap.map((p) {
        return Product.fromMap(p);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: TextField(
            onChanged: (value) => searchProduct(name: value),
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            // ElevatedButton(
            //  onPressed: () async {},
            // child: const Text('Filters'),
            //),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => fetchInventory(),
              child: const Text('Refresh'),
            ),
            const SizedBox(
              width: 16,
            ),
            PopupMenuButton<String>(
              // Replace with Text('Export') if desired
              tooltip: 'Export Options',
              onSelected: (String value) {
                // print('Exporting as: $value');
                // Add export logic here based on the selected value.
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'PDF',
                    child: Text('Export as PDF'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'CSV',
                    child: Text('Export as CSV'),
                  ),
                ];
              },
              icon: const Icon(Icons.import_export),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          onPressed: () => _showProductCreationDialog(),
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and Filter Row,
              // Product Table
              Expanded(
                  flex: 5,
                  child: ProductList(
                    products: _currentPageItems,
                    showProduct: _showProduct,
                    deleteProduct: _deleteProduct,
                  )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  const SizedBox(width: 16),
                  Text(_currentPage.toString()),
                  const SizedBox(width: 16),
                  if (_currentPage <
                      (_products.length / _itemsPerPage).ceil() - 1)
                    ElevatedButton(
                      onPressed: _nextPage,
                      child: const Text('Next'),
                    ),
                ],
              ),
            ],
          ),
        ));
  }
}
