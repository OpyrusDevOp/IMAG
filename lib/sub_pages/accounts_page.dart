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

  void _addUser(String username, String password, UserRole role) async {
    await DbManipulation.insertUser(
        User(username: username, password: password, role: role, id: 0));

    fetchUser();
  }

  void _modifyUser(
      String username, String newPassword, UserRole newRole) async {
    await DbManipulation.updateUser(
        User(id: 0, username: username, password: newPassword, role: newRole));
  }

  void _deleteUser(int userId) async {
    var result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user ?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'No'),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Yes'),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (result == 'Yes') await DbManipulation.deleteUser(userId);
    fetchUser();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add),
      ),
      body: GridView(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        semanticChildCount: users.length,
        children: users
            .map(
              (user) => InkWell(
                onTap: () => _showModifyUserDialog(user),
                onSecondaryTap: () {
                  if (user.id < 2) return;
                  _deleteUser(user.id);
                },
                child: Card(
                  elevation: 5,
                  color: user.role == UserRole.admin
                      ? Colors.yellow.shade100
                      : Colors.lightBlue.shade100,
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
                        user.role == UserRole.admin
                            ? Icons.person_3_sharp
                            : Icons.person,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ));

  void _showAddUserDialog() {
    String username = '';
    String password = '';
    String role = 'regular';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Username"),
                onChanged: (value) => username = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                onChanged: (value) => password = value,
              ),
              DropdownButtonFormField<String>(
                value: role,
                items: ['admin', 'regular']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) => role = value!,
                decoration: InputDecoration(labelText: "Role"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (username.isNotEmpty && password.isNotEmpty) {
                  var roleValue =
                      role == "admin" ? UserRole.admin : UserRole.regular;
                  _addUser(username, password, roleValue);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showModifyUserDialog(UserDto user) {
    String newPassword = '';
    String newRole = user.role.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modify ${user.username} info"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "New Password"),
                obscureText: true,
                onChanged: (value) => newPassword = value,
              ),
              DropdownButtonFormField<String>(
                value: newRole,
                items: ['admin', 'regular']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) => newRole = value!,
                decoration: InputDecoration(labelText: "New Role"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPassword.isNotEmpty || newRole.isNotEmpty) {
                  var roleValue =
                      newRole == "admin" ? UserRole.admin : UserRole.regular;
                  _modifyUser(user.username, newPassword, roleValue);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Modify"),
            ),
          ],
        );
      },
    );
  }
}
