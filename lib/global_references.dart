import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late String dbAssetsPath;
late String imageAssetsPath;
late Database databaseInstance;

const String configFileName = "AppSetting.config";
late String configFilePath;

bool configLoaded = false;
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
    var config = jsonDecode(content) as Map<String, String>;

    dbAssetsPath = config['dbAssetsPath']!;
    imageAssetsPath = config['imageAssetsPath']!;

    configLoaded = true;
  } on Exception catch (e) {
    if (kDebugMode) print(e);
    await configFile.delete();
  }
}
