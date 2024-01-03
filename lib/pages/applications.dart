import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mac_cleaner/helpers/applications.dart';
import 'package:mac_cleaner/helpers/global.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  AppDataList appsList = AppDataList();
  var appsLength = 1;
  var currentAppIndex = 0;
  var selectedView = 'Applications';
  int diskFreeSpace = 0;
  int diskTotalSpace = 0;
  DateTime lastScanned = DateTime.now();
  AppData currentApp = AppData(
      name: '',
      path: '',
      size: 0,
      readableSize: '',
      iconPath: '',
      lastAccessed: DateTime(2024));
  bool isScanning = false;
  int test = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime prefsLastScanned = DateTime.parse(prefs.getString('lastScanned')!);
    List<AppData> prefsApps = prefs
        .getStringList('apps')!
        .map((el) => convertToJsonStringQuotes(raw: el))
        .map((e) => appDataFromJson(jsonDecode(e)))
        .toList();
    setState(() {
      appsList.apps = prefsApps;
      lastScanned = prefsLastScanned;
    });
  }

  void setTest1() {
    setState(() {
      test = 1;
    });
  }

  void _onRescanPressed() async {
    setState(() {
      appsList.apps = [];
      isScanning = true;
    });
    var newApps = await getApplications();
    setState(() {
      appsLength = newApps.length;
    });
    for (var app in newApps) {
      var name = app.path.split('/').last.replaceAll('.app', ''); // TODO remove
      //if (['Xcode', 'iMovie'].contains(name)) continue; // TODO remove
      if (!app.path.endsWith('.app')) continue;
      await for (final appDataChunk in scanApplication(app.path)) {
        if (test == 1) {
          setState(() {
            currentAppIndex = 0;
            lastScanned = DateTime.now();
            isScanning = false;
            test = 0;
          });
          load();
          return;
        }
        ;
        setState(() {
          currentApp = appDataChunk;
        });
      }
      setState(() {
        currentAppIndex++;
        appsList.apps.add(currentApp);
        appsList.apps.sort((app1, app2) => app2.size.compareTo(app1.size));
      });
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('apps', appsList.toJSONEncodable());
    prefs.setString('lastScanned', DateTime.now().toString());
    setState(() {
      currentAppIndex = 0;
      lastScanned = DateTime.now();
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
                'Applications',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Review long-unused apps and decide if you still need them. Also see which apps take up the most space.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              if (!isScanning) ...NotScanning else ...Scanning
            ])));
  }

  List<Widget> get Scanning {
    return [
      FilledButton.icon(
          icon: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          ),
          onPressed: setTest1,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          label: const Text('Cancel scanning')),
      const SizedBox(height: 62),
      ...renderProgress(
          'Scanned $currentAppIndex of $appsLength apps',
          '${currentApp.name} ${currentApp.readableSize}',
          currentAppIndex / appsLength),
    ];
  }

  List<Widget> get NotScanning {
    return [
      FilledButton.icon(
          icon: const Icon(Icons.refresh),
          onPressed: _onRescanPressed,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          label: Text(
              '${appsList.apps.isNotEmpty ? 'Rescan' : 'Scan'} Applications')),
      const SizedBox(height: 8),
      if (appsList.apps.isNotEmpty)
        Text('Last scan: ${timeago.format(lastScanned)}',
            style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 16),
      if (appsList.apps.isNotEmpty)
        Expanded(
            child: Row(
          children: [
            renderAppsListWithTitle(
                appsList.apps
                    .where(
                        (element) => isOlderThanOneMonth(element.lastAccessed))
                    .toList(),
                'Long unused',
                const Icon(
                  Icons.schedule,
                  size: 40,
                )),
            const SizedBox(width: 32),
            renderAppsListWithTitle(
                appsList.apps
                    .where((element) => element.size > 5 * pow(10, 8))
                    .toList(),
                'Large',
                const Icon(
                  Icons.expand,
                  size: 40,
                )),
          ],
        ))
    ];
  }
}
