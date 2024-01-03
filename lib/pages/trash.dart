import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  bool isScanning = false;
  int totalSize = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkForDocker() async {
    try {
      var output = await Process.run('docker', ['-v']);
      print(output.stdout);
      return true;
    } catch (e) {
      return false;
    }
  }

  void onRescanPressed() async {
    setState(() {
      isScanning = true;
    });
    var userDirectory = await getUserDirectory();
    var path = '$userDirectory/.Trash';

    await for (final sizeChunk in _getDirectorySizeStream(path)) {
      setState(() {
        totalSize += sizeChunk;
      });
    }
    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
            padding: const EdgeInsets.all(32.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              const Text(
                'Trash',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Check how much space your Trash is taking up on your disk and find out how to remedy it.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              if (!isScanning) ...[
                FilledButton.icon(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRescanPressed,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    label: const Text('Scan Trash')),
              ] else ...[
                FilledButton.icon(
                    icon: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    label: const Text('Cancel scanning')),
              ],
              const SizedBox(
                height: 32,
              ),
              if (totalSize > 0) ...[
                Text('Total size: ${getFileSizeString(bytes: totalSize)}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (!isScanning) ...[
                  const SizedBox(height: 32),
                  const Text('Whats next?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Open Trash and click Library in the sidebar, go to Edit ➙ Select All (⌘ + A), then hit Backspace. Don’t forget to Empty Trash afterwards!',
                      style: TextStyle(color: Colors.grey))
                ]
              ]
            ])));
  }
}

Stream<int> _getDirectorySizeStream(String path) async* {
  yield 0;

  final entityList = await Directory(path).list(recursive: true).toList();

  for (var entity in entityList) {
    if (entity is File) {
      final fileBytes = await File(entity.path).readAsBytes();
      yield fileBytes.lengthInBytes;
    }
  }
}

Future<String> getUserDirectory() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String homeDirectory = directory.parent.path;
  return homeDirectory;
}

String getFileSizeString({required int bytes}) {
  const suffixes = ["b", "kb", "mb", "gb", "tb"];
  if (bytes == 0) return '0${suffixes[0]}';
  var i = (log(bytes) / log(1024)).floor();
  var decimals = i >= 3 ? 2 : 0;
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}
