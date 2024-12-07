import 'package:flutter/material.dart';
import 'package:imag/auth_page.dart';
import 'package:imag/global_references.dart';
import 'package:imag/sub_pages/accounts_page.dart';
import 'package:imag/sub_pages/inventory_page.dart';
import 'package:imag/sub_pages/shopping_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> subPages = [
    ShoppingPage(),
    InventoryPage(),
    AccountsPage()
  ];

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
            tooltip: 'signout',
            onPressed: () {
              logoutConfig();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const AuthPage();
                  },
                ),
              );
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
                    Icons.shopping_cart_outlined,
                  ),
                  selectedIcon: Icon(
                    Icons.shopping_cart,
                  ),
                  label: Text('Shop'),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Icons.dashboard_outlined,
                  ),
                  selectedIcon: Icon(
                    Icons.dashboard,
                  ),
                  label: Text('Inventory'),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Icons.group_outlined,
                  ),
                  selectedIcon: Icon(
                    Icons.group,
                  ),
                  label: Text('Accounts'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            Expanded(
                child: Card(
              color: Colors.white,
              margin: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: subPages[_selectedIndex],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
