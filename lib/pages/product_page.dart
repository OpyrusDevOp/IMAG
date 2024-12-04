import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipido'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          const CircleAvatar(child: Text('SN')),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(title: const Text('Products'), onTap: () {}),
            ListTile(title: const Text('Orders'), onTap: () {}),
            ListTile(title: const Text('Customers'), onTap: () {}),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter Row
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Filters'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Export'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('New Product'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Product Table
            Expanded(
              child: PaginatedDataTable(
                header: const Text('Products'),
                columns: const [
                  DataColumn(label: Text('Product Name')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('SKU')),
                  DataColumn(label: Text('Variant')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Status')),
                ],
                source: ProductDataSource(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mock Data Source for PaginatedDataTable
class ProductDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _products = List.generate(
    20,
    (index) => {
      'name': 'Product $index',
      'category': 'Category $index',
      'sku': 'SKU$index',
      'variant': 'Variant $index',
      'price': '\$${(index + 1) * 10}',
      'status': index % 2 == 0 ? 'Active' : 'Out of Stock',
    },
  );

  @override
  DataRow? getRow(int index) {
    if (index >= _products.length) return null;
    final product = _products[index];
    return DataRow(cells: [
      DataCell(Text(product['name'])),
      DataCell(Text(product['category'])),
      DataCell(Text(product['sku'])),
      DataCell(Text(product['variant'])),
      DataCell(Text(product['price'])),
      DataCell(Text(product['status'])),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _products.length;

  @override
  int get selectedRowCount => 0;
}
