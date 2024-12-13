import 'package:flutter/material.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:imag/components/product_list.dart';
import 'package:imag/db_manipulation.dart';

class ProductListingDialog extends StatefulWidget {
  final List<ProductCarting> cart;
  final Function refreshParent;
  const ProductListingDialog(
      {super.key, required this.cart, required this.refreshParent});

  @override
  State<StatefulWidget> createState() => ProductListingDialogState();
}

class ProductListingDialogState extends State<ProductListingDialog> {
  List<Product> currentProducts = [];
  TextEditingController searchBarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchProduct();
  }

  void searchProduct({String? name}) async {
    var searchResult =
        await DbManipulation.selectProduct(productName: name, count: 20);
    var productFromResult = searchResult.map(Product.fromMap).toList();
    productFromResult.removeWhere(
        (p) => widget.cart.contains(ProductCarting.fromProduct(p)));
    setState(() {
      currentProducts = productFromResult;
    });
  }

  void addProductToCart(Product product) {
    setState(() {
      widget.cart.add(ProductCarting.fromProduct(product));
      currentProducts.remove(product);
    });

    widget.refreshParent();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: TextField(
                  controller: searchBarController,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                  ),
                  onChanged: (value) => searchProduct(name: value),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () async {},
                    child: const Text('Filters'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Refresh'),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                ],
              ),
              body: currentProducts.isEmpty
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_sharp,
                            size: 30,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "No item !",
                            style: Theme.of(context).textTheme.headlineLarge,
                          )
                        ],
                      ),
                    )
                  : ProductList(
                      products: currentProducts,
                      addProduct: addProductToCart,
                    ),
            ),
          ),
        ),
      );
}
