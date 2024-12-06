import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:imag/DataTypes/user.dart';
import 'global_references.dart';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String tableProduct = "products";
const String tableUser = "users";
const String fileName = 'data.db';

class DbManipulation {
  static Future<void> setupPreparation({String? path}) async {
    databaseFactory = databaseFactoryFfi;

    dbAssetsPath = path ?? (await getApplicationSupportDirectory()).path;
    imageAssetsPath = join(dbAssetsPath, "Images");
  }

  static Future<void> setupDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
    }

    var filePath = join(dbAssetsPath, fileName);
    if (kDebugMode) {
      print(filePath);
    }
    OpenDatabaseOptions options = OpenDatabaseOptions(
      version: 3,
      onCreate: (db, version) async {
        await db
            .execute(
                "CREATE TABLE $tableProduct (id INTEGER PRIMARY KEY AUTOINCREMENT,productImage TEXT,productName TEXT NOT NULL,price INTEGER NOT NULL,quantity INTEGER DEFAULT 0)")
            .then((value) {
          if (kDebugMode) {
            print("$tableProduct table created");
          }
        });

        await db
            .execute(
                "CREATE TABLE $tableUser (id INTEGER PRIMARY KEY AUTOINCREMENT,username TEXT NOT NULL,password TEXT NOT NULL,role INTEGER NOT NULL)")
            .then((value) {
          if (kDebugMode) {
            print("$tableUser table created");
          }
        });
      },
    );
    databaseInstance =
        await databaseFactory.openDatabase(filePath, options: options);
  }

  static void insertProduct(Product product, BuildContext context) async {
    var values = product.toMap();
    values.remove("id");
    await databaseInstance.insert(tableProduct, values);
    if (kDebugMode) {
      print("${product.productName} inserted");
    }
  }

  static void insertUser(User user) async {
    var bytes = utf8.encode(user.password);
    var digest = sha256.convert(bytes);
    user.password = digest.toString();
    var values = user.toMap();
    values.remove("id");
    await databaseInstance.insert(tableUser, values);
    if (kDebugMode) {
      print("${user.username} inserted");
    }
  }

  static Future<List<Map<String, dynamic>>> selectProduct(
      {int? id, String? productName}) async {
    // Base query
    String whereClause = '';
    List<dynamic> whereArgs = [];

    // Add conditions dynamically
    if (id != null) {
      whereClause += '${whereClause.isEmpty ? '' : ' AND '}id = ?';
      whereArgs.add(id);
    }
    if (productName != null) {
      whereClause += '${whereClause.isEmpty ? '' : ' AND '}productName LIKE ?';
      whereArgs.add('%$productName%'); // For partial matching
    }

    // Execute query
    return await databaseInstance.query(
      tableProduct,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
  }

  static Future<void> updateProduct(
      Product product, BuildContext context) async {
    try {
      var values = product.toMap();
      List<dynamic> whereArgs = [];
      if (kDebugMode) print(product);
      whereArgs.add(values.remove('id'));
      await databaseInstance.update(tableProduct, values,
          where: "id = ?", whereArgs: whereArgs);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item ${product.productName} saved')),
      );
    } catch (e) {
      if (kDebugMode) print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error while saving !'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> deleteProduct(int id, BuildContext context) async {
    try {
      await databaseInstance
          .delete(tableProduct, where: "id = ?", whereArgs: <dynamic>[id]);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item deleted')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while deleting !')),
      );
    }
  }

  static Future<void> deleteProducts(
      List<Product> product, BuildContext context) async {}
}
