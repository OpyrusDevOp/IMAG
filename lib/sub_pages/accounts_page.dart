import 'package:data_table_2/data_table_2.dart';
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
        body: DataTable2(
          dataRowColor: WidgetStateColor.transparent,
          headingRowColor: WidgetStateColor.transparent,
          columns: const [
            DataColumn2(label: Text('ID'), size: ColumnSize.S),
            DataColumn2(label: Text('Username'), size: ColumnSize.L),
            DataColumn2(label: Text('Role'), size: ColumnSize.M),
            DataColumn2(
                label: Text('Actions'), size: ColumnSize.M), // Action column
          ],
          rows: users
              .map(
                (user) => DataRow2(
                  cells: [
                    DataCell(Text(user.id.toString())),
                    DataCell(Text(user.username)),
                    DataCell(Text(user.role.name)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      );
}
