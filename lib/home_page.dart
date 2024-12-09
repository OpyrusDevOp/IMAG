import 'package:flutter/material.dart';
import 'package:imag/DataTypes/user.dart';
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

  void onDestinationSelected(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
            if (currentUser!.role == UserRole.admin)
              Container(
                width: 80, // Adjust width for the sidebar
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildDestination(
                      index: 0,
                      icon: Icons.shopping_cart_outlined,
                      label: 'Shop',
                      isSelected: _selectedIndex == 0,
                    ),
                    _buildDestination(
                      index: 1,
                      icon: Icons.dashboard_outlined,
                      label: 'Inventory',
                      isSelected: _selectedIndex == 1,
                    ),
                    _buildDestination(
                      index: 2,
                      icon: Icons.group_outlined,
                      label: 'Accounts',
                      isSelected: _selectedIndex == 2,
                    ),
                  ],
                ),
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

  Widget _buildDestination({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onDestinationSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black,
              size: 30,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
