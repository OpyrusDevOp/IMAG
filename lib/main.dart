import 'dart:io';
import 'package:flutter/material.dart';
import 'package:imag/auth_page.dart';
import 'package:imag/config_app_page.dart';
import 'package:imag/global_references.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'db_manipulation.dart';

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }

  await DbManipulation.setupPreparation();
  var exist = await checkConfig();

  if (exist) {
    await loadConfig();
    if (configLoaded) await DbManipulation.setupDatabase();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IMAG',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: configLoaded ? AuthPage() : const ConfigAppPage(),
    );
  }
}
