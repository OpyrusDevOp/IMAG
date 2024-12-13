import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imag/DataTypes/product.dart';
import 'package:imag/DataTypes/user.dart';
import 'package:imag/logger.dart';
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

  static Future<void> insertProduct(
      Product product, BuildContext context) async {
    var values = product.toMap();
    values.remove("id");
    await databaseInstance.insert(tableProduct, values);
    Logger.productCreation(product);
    if (kDebugMode) {
      print("${product.productName} inserted");
    }
  }

  static Future<void> insertUser(User user) async {
    if ((await isUserExists(user.username))) throw Exception();
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
      {int? id, String? productName, int? count}) async {
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
      limit: count,
    );
  }

  static Future<bool> isUserExists(String username) async {
    var result = await databaseInstance
        .query(tableUser, where: "username = ?", whereArgs: [username]);

    return result.isNotEmpty;
  }

  static Future<User?> queryUser(String username) async {
    var result = await databaseInstance
        .query(tableUser, where: "username = ?", whereArgs: [username]);

    if (result.isEmpty) return null;

    return User.fromMap(result[0].cast());
  }

  static Future<List<UserDto>> queryAll() async {
    var result = await databaseInstance.query(tableUser);

    var users = result.map(UserDto.fromMap);

    return users.toList();
  }

  static Future<UserDto?> connexion(String username, String password) async {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    password = digest.toString();

    var user = await queryUser(username);

    if (user == null || user.password != password) return null;

    return UserDto.fromUser(user);
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
      Logger.productModification(product);
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

  static Future<void> updateFromSelling(List<ProductCarting> cart) async {
    List<Product> products = cart.map(Product.fromPurchase).toList();
    var values = products.map((p) => p.toMap()).toList();

    for (var item in values) {
      List<dynamic> whereArgs = [];
      whereArgs.add(item.remove('id'));
      await databaseInstance.update(tableProduct, item,
          where: "id = ?", whereArgs: whereArgs);
      Logger.productSold(ProductCarting.fromMap(item));
    }
  }

  static Future<void> updateUser(User user) async {
    var userMap = user.toMap();

    var id = userMap.remove('id');

    await databaseInstance
        .update(tableUser, userMap, where: "id = ?", whereArgs: [id]);
  }

  static Future<void> deleteProduct(
      Product product, BuildContext context) async {
    try {
      await databaseInstance.delete(tableProduct,
          where: "id = ?", whereArgs: <dynamic>[product.id]);
      Logger.productDelete(product);
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

  static Future<void> deleteUser(int userId) async {
    await databaseInstance
        .delete(tableUser, where: "id = ?", whereArgs: [userId]);
  }

  static Future<void> deleteProducts(
      List<Product> product, BuildContext context) async {}
}
