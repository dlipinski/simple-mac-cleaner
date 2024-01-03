import 'package:flutter/material.dart';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mac_cleaner/helpers/global.dart';

Expanded renderAppsListWithTitle(List<AppData> apps, String title, Icon icon) {
  return Expanded(
    child: Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(2.0),
              title: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                  'Total ${getFileSizeString(bytes: apps.fold(0, (value, element) => value += element.size))}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const Divider(height: 1),
            renderAppsList(apps),
          ],
        ),
      ),
    ]),
  );
}

Expanded renderAppsList(List<AppData> apps) {
  return Expanded(
    child: ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final item = apps[index];

        return ListTile(
          contentPadding: const EdgeInsets.all(2.0),
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          leading: Image.file(
            File(
              item.iconPath,
            ),
          ),
          title: Text(item.name, style: const TextStyle(fontSize: 14)),
          subtitle: Text(
              '${item.readableSize}, used ${timeago.format(item.lastAccessed)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        );
      },
    ),
  );
}

class AppData {
  final String name;
  final String path;
  final int size;
  final String readableSize;
  final String iconPath;
  final DateTime lastAccessed;

  AppData(
      {required this.name,
      required this.path,
      required this.size,
      required this.readableSize,
      required this.iconPath,
      required this.lastAccessed});

  toJSONEncodable() {
    Map<String, dynamic> m = {
      'name': name,
      'path': path,
      'size': size.toString(),
      'readableSize': readableSize,
      'iconPath': iconPath,
      'lastAccessed': lastAccessed.toString()
    };
    return m;
  }
}

AppData appDataFromJson(Map<String, dynamic> json) => AppData(
    name: json["name"] as String,
    path: json["path"] as String,
    size: int.parse(json["size"]),
    readableSize: json["readableSize"] as String,
    iconPath: json["iconPath"] as String,
    lastAccessed: DateTime.parse(json["lastAccessed"]));

class AppDataList {
  List<AppData> apps = [];

  toJSONEncodable() {
    return apps.map((item) {
      return item.toJSONEncodable().toString();
    }).toList();
  }
}

Future<List<FileSystemEntity>> getApplications() async {
  var directory = Directory('/Applications');
  if (directory.existsSync()) {
    return directory.listSync().whereType<Directory>().toList();
  } else {
    return [];
  }
}

Stream<AppData> scanApplication(String path) async* {
  var name = path.split('/').last.replaceAll('.app', '');
  var iconPath = _getIconPath(path, name);
  var directory = Directory('$path/Contents/MacOS');
  var lastAccessed = DateTime(2024);
  if (directory.existsSync()) {
    var exec = directory.listSync()[0];
    var file = File(exec.path);
    if (file.existsSync()) {
      lastAccessed = await file.lastAccessed();
    }
  }
  var totalSize = 0;
  await for (final sizeChunk in getDirectorySizeStream(path)) {
    totalSize += sizeChunk;
    var readableSize = getFileSizeString(bytes: totalSize);
    var appData = AppData(
        name: name,
        path: path,
        size: totalSize,
        readableSize: readableSize,
        iconPath: iconPath,
        lastAccessed: lastAccessed);
    yield appData;
  }
}

bool isOlderThanOneMonth(DateTime dateTime) {
  // Get the current date and time
  DateTime now = DateTime.now();

  // Calculate the difference in months
  int differenceInMonths =
      now.month - dateTime.month + (now.year - dateTime.year) * 12;

  // Check if the difference is greater than 1
  return differenceInMonths > 1;
}

String _getIconPath(String appPath, String appName) {
  var options = [
    'MacAppIcon',
    'icon',
    'Icon',
    'App',
    'app',
    'AppIcon',
    'electron',
    appName,
    appName.toLowerCase(),
    appName.replaceAll(' ', '-'),
    ...appName.split(' '),
    '${appName}Document'
  ];
  for (var option in options) {
    var iconPath = '$appPath/Contents/Resources/$option.icns';
    var file = File(iconPath);
    if (file.existsSync()) {
      return iconPath;
    }
  }
  return '/Applications/Melodics.app/Contents/Resources/icon.icns';
}

String convertToJsonStringQuotes({required String raw}) => raw
    .replaceAll('{', '{"')
    .replaceAll(': ', '": "')
    .replaceAll(', ', '", "')
    .replaceAll('}', '"}')
    .replaceAll('"{"', '{"')
    .replaceAll('"}"', '"}')
    .replaceAll('"[{', '[{')
    .replaceAll('}]"', '}]');
