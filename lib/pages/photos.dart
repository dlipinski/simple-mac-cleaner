import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mac_cleaner/helpers/global.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  bool isScanning = false;
  DateTime lastScanned = DateTime.now();
  int totalSize = 0;
  int currentTotalSize = 0;
  bool closeStream = false;
  int totalFiles = 0;
  int currentPhoto = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalSize = prefs.getInt('photos:totalSize') ?? 0;
      lastScanned = DateTime.parse(
          prefs.getString('photos:lastScanned') ?? DateTime.now().toString());
    });
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
    var path = '$userDirectory/Pictures/Photos Library.photoslibrary';
    setState(() {
      currentTotalSize = 0;
      totalFiles = getDirectoryFilesAmount(path: path);
      currentPhoto++;
    });
    await for (final sizeChunk in getDirectorySizeStream(path)) {
      if (closeStream) {
        setState(() {
          isScanning = false;
          closeStream = false;
        });
        return;
      }
      setState(() {
        currentTotalSize += sizeChunk;
      });
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('photos:totalSize', currentTotalSize);
    prefs.setString('photos:lastScanned', DateTime.now().toString());
    setState(() {
      totalSize = currentTotalSize;
      totalFiles = 0;
      currentTotalSize = 0;
      isScanning = false;
    });
  }

  void onClosePressed() {
    setState(() {
      closeStream = true;
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
                'Photos',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Check how much space your photos are taking up on your disk and find out how to remedy it.',
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
                    label: Text('${totalSize > 0 ? 'Rescan' : 'Scan'} Photos')),
                const SizedBox(height: 8),
                if (totalSize > 0)
                  Text('Last scan: ${timeago.format(lastScanned)}',
                      style: const TextStyle(color: Colors.grey)),
                const SizedBox(
                  height: 32,
                ),
                const Text('Scanned',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Total ${getFileSizeString(bytes: totalSize)}',
                    style: const TextStyle(color: Colors.grey)),
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
                    onPressed: onClosePressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    label: const Text('Cancel scanning')),
                const SizedBox(
                  height: 60,
                ),
                ...renderProgress('Scanning photos',
                    'Total: ${getFileSizeString(bytes: currentTotalSize)}', -1)
              ],
              if (totalSize > 0) ...[
                if (!isScanning) ...[
                  const SizedBox(height: 32),
                  const Text('Whats next?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Open Photos and click Library in the sidebar, go to Edit ➙ Select All (⌘ + A), then hit Backspace. Don’t forget to Empty Trash afterwards!',
                      style: TextStyle(color: Colors.grey))
                ]
              ]
            ])));
  }
}
