// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imag/DataTypes/user.dart';
import 'package:imag/auth_page.dart';
import 'package:imag/db_manipulation.dart';
import 'package:imag/global_references.dart';
import 'package:path/path.dart' as path;

class ConfigAppPage extends StatefulWidget {
  const ConfigAppPage({super.key});

  @override
  State<StatefulWidget> createState() => ConfigAppPageState();
}

class ConfigAppPageState extends State<ConfigAppPage> {
  int _currentPage = 0;
  final _databaseformKey = GlobalKey<FormState>();
  final _rootUserFormKey = GlobalKey<FormState>();

  List<Widget> pages = <Widget>[];
  int _maxPages = 2;
  bool isSaving = false;
  String loadingMessage = "";
  final TextEditingController databasePathInputControl =
      TextEditingController(text: dbAssetsPath);
  final TextEditingController usernameInputControl =
      TextEditingController(text: "root");
  final TextEditingController passworInputControl =
      TextEditingController(text: "root");

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50),
          child: !isSaving
              ? Column(
                  children: [
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: pages[_currentPage]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentPage > 0)
                          ElevatedButton(
                            onPressed: _previousPage,
                            child: const Text('Previous'),
                          ),
                        const SizedBox(width: 16),
                        _currentPage < _maxPages - 1
                            ? ElevatedButton(
                                onPressed: _nextPage,
                                child: const Text('Next'),
                              )
                            : ElevatedButton(
                                onPressed: _saveConfig,
                                child: Text("Save"),
                              ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text(loadingMessage)
                    ],
                  ),
                ),
        ),
      );

  @override
  void initState() {
    pages.add(ConfigForm(
        formKey: _databaseformKey,
        databasePathInputControl: databasePathInputControl));

    pages.add(UserDefaultConfigForm(
      formKey: _rootUserFormKey,
      usernameInputController: usernameInputControl,
      passwordInputController: passworInputControl,
    ));

    setState(
      () {
        _currentPage = 0;
        _maxPages = pages.length;
      },
    );

    super.initState();
  }

  void _nextPage() {
    if (_databaseformKey.currentState == null ||
        !_databaseformKey.currentState!.validate()) return;
    if (_currentPage < _maxPages - 1) {
      _databaseformKey.currentState!.save();
      setState(() {
        _currentPage++;
      });
    }
  }

  // Function to go to the previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _rootUserFormKey.currentState!.save();
      setState(() {
        _currentPage--;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (isSaving || _rootUserFormKey.currentState == null) return;

    if (_rootUserFormKey.currentState!.validate()) {
      setState(() {
        isSaving = true;
        loadingMessage = "Creating Database ...";
      });

      await Future.delayed(Duration(seconds: 2));
      //;
      //_rootUserFormKey.currentState!.save();

      var databasePath = databasePathInputControl.text;
      if (!Directory(databasePath).existsSync()) {
        Directory(databasePath).create();
      }

      dbAssetsPath = databasePath;
      imageAssetsPath = path.join(dbAssetsPath, "Images");

      try {
      setState(() {
        loadingMessage = "Saving Config";
      });
      

      await Future.delayed(Duration(seconds: 1));
      await saveConfig();
      await DbManipulation.setupDatabase();

      setState(() {
        loadingMessage = "Save root user ..";
      });
      await Future.delayed(Duration(seconds: 2));
      DbManipulation.insertUser(User(
          username: usernameInputControl.text,
          password: passworInputControl.text,
          role: UserRole.admin));
      setState(() {
        loadingMessage = "Setup Finished !";
      });
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        isSaving = false;
      });
      if (context.mounted) {
        await Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AuthPage()));
      }
    } on Exception catch (e) {
      if (kDebugMode) print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Error while saving config !"),
      ));

      setState(() {
        isSaving = false;
      });
    }
    }
   
  }
}

class ConfigForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController databasePathInputControl;

  const ConfigForm(
      {super.key,
      required this.formKey,
      required this.databasePathInputControl});

  @override
  State<StatefulWidget> createState() => ConfigFormState();
}

class ConfigFormState extends State<ConfigForm> {
  @override
  Widget build(BuildContext context) => Form(
        key: widget.formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsetsDirectional.symmetric(vertical: 20),
                child: Text(
                  "Configuration",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              TextFormField(
                controller: widget.databasePathInputControl,
                decoration: InputDecoration(
                    label: const Text("Database Path"),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.folder_outlined),
                      onPressed: () async {
                        String? path = await FilesystemPicker.open(
                          title: 'Save to folder',
                          context: context,
                          fsType: FilesystemType.folder,
                          pickText: 'Save file to this folder',
                        );

                        if (path != null) {
                          setState(() {
                            widget.databasePathInputControl.text = path;
                          });
                        }
                      },
                    ),
                    helper: Text("Must exist and be absolute !")),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !Directory(value).isAbsolute ||
                      !Directory(value).parent.existsSync()) {
                    return "Not a valid path";
                  }

                  return null;
                },
              )
            ],
          ),
        ),
      );
}

class UserDefaultConfigForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameInputController;
  final TextEditingController passwordInputController;
  const UserDefaultConfigForm(
      {super.key,
      required this.formKey,
      required this.usernameInputController,
      required this.passwordInputController});

  @override
  State<StatefulWidget> createState() => UserDefaultConfigFormState();
}

class UserDefaultConfigFormState extends State<UserDefaultConfigForm> {
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) => Form(
        key: widget.formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsetsDirectional.symmetric(vertical: 20),
                child: Text(
                  "Admin account",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.symmetric(vertical: 20),
                child: TextFormField(
                  controller: widget.usernameInputController,
                  decoration: InputDecoration(
                    label: const Text("Root username"),
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Not a valid path";
                    }

                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.symmetric(vertical: 20),
                child: TextFormField(
                  controller: widget.passwordInputController,
                  obscureText: !passwordVisible,
                  obscuringCharacter: '*',
                  decoration: InputDecoration(
                    label: const Text("Root password"),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: passwordVisible
                          ? Icon(Icons.visibility_sharp)
                          : Icon(Icons.visibility_off_sharp),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password required !";
                    }

                    return null;
                  },
                ),
              )
            ],
          ),
        ),
      );
}
