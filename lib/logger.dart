import 'dart:io';

import 'package:imag/DataTypes/product.dart';
import 'package:imag/global_references.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Logger {
  static late String logFilePath;
  static const String logFileName = "Log";
  static void setupLogger() async {
    var logFileDir = (await getApplicationSupportDirectory()).path;
    logFilePath = join(logFileDir, logFileName);
  }

  static void userLogged() {
    createLogLine("logged in");
  }

  static void productSold(ProductCarting product) async {
    var actionInfo = "selled ${product.quantity} of ${product.productName}";

    createLogLine(actionInfo);
  }

  static void productDelete(Product product) async {
    var actionInfo = "delete item - ${product.productName}";

    createLogLine(actionInfo);
  }

  static void productCreation(Product product) async {
    var actionInfo = "added item - ${product.productName}";

    createLogLine(actionInfo);
  }

  static void productModification(Product product) async {
    var actionInfo = "modified item - ${product.productName}";

    createLogLine(actionInfo);
  }

  static Future<void> createLogLine(String actionInfo) async {
    if (currentUser == null) throw Exception("No user logged !");
    var message =
        "${DateTime.now().toString()} : ${currentUser!.username} $actionInfo \n";

    var fileBuffer = File(logFilePath);

    await fileBuffer.writeAsString(message, mode: FileMode.append);
  }
}
