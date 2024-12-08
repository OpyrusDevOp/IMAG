import 'package:flutter/material.dart';
import 'package:imag/db_manipulation.dart';

import '../DataTypes/user.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<StatefulWidget> createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  List<UserDto> users = [];

  Future<void> fetchUser() async {
    var queryResult = await DbManipulation.queryAll();

    setState(() {
      users = queryResult;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: GridView(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        semanticChildCount: users.length,
        children: users
            .map(
              (user) => InkWell(
                onTap: () {},
                child: Card(
                  elevation: 5,
                  color: Colors.grey,
                  child: GridTile(
                    footer: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(user.username,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.person_3_sharp,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ));
}
