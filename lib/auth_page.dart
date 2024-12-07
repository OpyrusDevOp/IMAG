import 'package:flutter/material.dart';
import 'package:imag/db_manipulation.dart';
import 'package:imag/global_references.dart';
import 'package:imag/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<StatefulWidget> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController usernameEditControl = TextEditingController();
  TextEditingController passwordEditControl = TextEditingController();
  bool passwordVisible = false;
  bool isAuthenticating = false;
  String loadingMessage = "";

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      isAuthenticating = true;
      loadingMessage = "Login ..";
    });

    await Future.delayed(Duration(seconds: 2));
    var username = usernameEditControl.text;
    var password = passwordEditControl.text;

    var user = await DbManipulation.connexion(username, password);

    if (user == null) {
      setState(() {
        loadingMessage = "Wrong username or password ...";
      });

      await Future.delayed(Duration(seconds: 2));

      setState(() {
        usernameEditControl.text = "";
        passwordEditControl.text = "";
        isAuthenticating = false;
      });

      return;
    }

    currentUser = user;
    if (context.mounted) {
      await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: isAuthenticating
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), Text(loadingMessage)],
                ),
              )
            : Form(
                key: formKey,
                child: Container(
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsetsDirectional.symmetric(vertical: 50),
                        child: Text(
                          "Welcome",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      TextFormField(
                        controller: usernameEditControl,
                        decoration: InputDecoration(
                          label: const Text("Username"),
                          prefixIcon: Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Not a valid";
                          }

                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsetsDirectional.symmetric(vertical: 20),
                        child: TextFormField(
                          controller: passwordEditControl,
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password required !";
                            }

                            return null;
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsetsDirectional.symmetric(
                            horizontal: 20, vertical: 60),
                        child: FilledButton(
                          onPressed: () => login(),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 5),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
}
