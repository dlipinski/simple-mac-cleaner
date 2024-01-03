import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Stream<int> getDirectorySizeStream(String path) async* {
  yield 0;

  final entityList = await Directory(path).list(recursive: true).toList();

  for (var entity in entityList) {
    if (entity is File) {
      final fileBytes = await File(entity.path).readAsBytes();
      yield fileBytes.lengthInBytes;
    }
  }
}

List<Widget> renderProgress(String title, String subtitle, double progress) {
  return [
    Text(title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    const SizedBox(height: 8),
    SizedBox(
      width: 350,
      child: progress.isNegative || progress == 0
          ? const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
              minHeight: 2,
            )
          : TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              tween: Tween<double>(
                begin: 0,
                end: progress,
              ),
              builder: (context, value, _) => LinearProgressIndicator(
                color: Colors.blueAccent,
                value: value,
                minHeight: 2,
              ),
            ),
    ),
    const SizedBox(height: 8),
    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12))
  ];
}

String getFileSizeString({required int bytes}) {
  const suffixes = ["b", "kb", "mb", "gb", "tb"];
  if (bytes == 0) return '0${suffixes[0]}';
  var i = (log(bytes) / log(1024)).floor();
  var decimals = i >= 3 ? 2 : 0;
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

int getDirectoryFilesAmount({required String path}) {
  return Directory(path).listSync().length;
}

Future<String> getUserDirectory() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String homeDirectory = directory.parent.path;
  return homeDirectory;
}
