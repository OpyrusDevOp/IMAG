import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imag/DataTypes/product.dart';
import 'global_references.dart';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String tableProduct = "products";

class DbManipulation {
  static Future<void> setupDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
    }

    databaseFactory = databaseFactoryFfi;
    dbAssetsPath = await getApplicationSupportDirectory();
    String fileName = 'data.db';

    var filePath = join(dbAssetsPath.path, fileName);
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
            print("Database created");
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
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product ${product.productName} saved')),
    );
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
}
