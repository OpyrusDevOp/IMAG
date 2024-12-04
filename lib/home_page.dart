import 'package:flutter/material.dart';
import 'package:imag/pages/inventory_page.dart';
//import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        titleSpacing: 80,
        title: const Text('IMAG'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.red,
              size: 30,
            ),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar')));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Row(
          children: <Widget>[
            NavigationRail(
              minWidth: 100,
              selectedIndex: _selectedIndex,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              //trailing: IconButton(
              //  onPressed: () {
              // Add your onPressed code here!
              // },
              // icon: const Icon(Icons.more_horiz_rounded),
              //),
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(
                    Icons.dashboard_outlined,
                    size: 30,
                  ),
                  selectedIcon: Icon(
                    Icons.dashboard,
                    size: 30,
                  ),
                  label: Text('Inventory'),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    size: 30,
                  ),
                  selectedIcon: Icon(
                    Icons.shopping_cart,
                    size: 30,
                  ),
                  label: Text('Shop'),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Icons.group_outlined,
                    size: 30,
                  ),
                  selectedIcon: Icon(
                    Icons.group,
                    size: 30,
                  ),
                  label: Text('Third'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            const Expanded(
                child: Card(
              color: Colors.white,
              margin: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: InventoryPage(),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// Mock Data Source for PaginatedDataTable
class ProductDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _products = List.generate(
    5,
    (index) => {
      'name': 'Product $index',
      'category': 'Category $index',
      'sku': 'SKU$index',
      'variant': 'Variant $index',
      'price': '${(index + 1) * 10}',
      'status': index % 2 == 0 ? 'Active' : 'Out of Stock',
    },
  );

  @override
  DataRow? getRow(int index) {
    if (index >= _products.length) return null;
    final product = _products[index];
    return DataRow(cells: [
      _buildStretchableCell(product['name']),
      _buildStretchableCell(product['category']),
      _buildStretchableCell(product['sku']),
      _buildStretchableCell(product['variant']),
      _buildStretchableCell(product['price']),
      _buildStretchableCell(product['status']),
    ]);
  }

  DataCell _buildStretchableCell(String text) {
    return DataCell(
      SizedBox(
        width: double.infinity, // Ensures the cell stretches
        child: Text(
          text,
          textAlign: TextAlign.center, // Optional: Center align the text
        ),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _products.length;

  @override
  int get selectedRowCount => 0;
}
