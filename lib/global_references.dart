import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:imag/DataTypes/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late String dbAssetsPath;
late String imageAssetsPath;
late Database databaseInstance;
late String configFilePath;
const String configFileName = "AppSetting.config";

UserDto? currentUser;

bool configLoaded = false;

void logoutConfig() {
  currentUser = null;
}

Future<bool> checkConfig() async {
  var appDir = await getApplicationSupportDirectory();
  if (kDebugMode) print("App Directory :  ${appDir.path}");

  configFilePath = join(appDir.path, configFileName);

  return await File(configFilePath).exists();
}

Future<void> saveConfig() async {
  var configFile = File(configFilePath);

  if (!configFile.existsSync()) await configFile.create();

  var config = {
    "dbAssetsPath": dbAssetsPath,
    "imageAssetsPath": imageAssetsPath
  };

  var jsonContent = jsonEncode(config);

  await configFile.writeAsString(jsonContent);
}

Future<void> loadConfig() async {
  var configFile = File(configFilePath);
  if (!configFile.existsSync()) return;

  try {
    var content = await configFile.readAsString();
    var config = jsonDecode(content) as Map<String, dynamic>;

    dbAssetsPath = config['dbAssetsPath']!;
    imageAssetsPath = config['imageAssetsPath']!;

    configLoaded = true;
  } on Exception catch (e) {
    if (kDebugMode) print(e);
    await configFile.delete();
  }
}
