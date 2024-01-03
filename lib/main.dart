import 'package:mac_cleaner/pages/photos.dart';
import 'package:mac_cleaner/pages/trash.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mac_cleaner/pages/applications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    // size: Size(400, 600),
    // maximumSize: Size(400, 2000),
    // minimumSize: Size(400, 400),
    titleBarStyle: TitleBarStyle.hidden,
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme),
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const NavRailExample(),
    );
  }
}

class NavRailExample extends StatefulWidget {
  const NavRailExample({super.key});

  @override
  State<NavRailExample> createState() => _NavRailExampleState();
}

class _NavRailExampleState extends State<NavRailExample> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  double groupAlignment = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: Colors.black,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            minExtendedWidth: 190,
            leading: const Padding(
              padding: EdgeInsets.only(top: 40, bottom: 16, left: 0, right: 0),
              child:
                  Text('Simple\nMac\nCleaner', style: TextStyle(fontSize: 32)),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(top: 64.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.recycling),
                label: const Text('Clear data'),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                },
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.favorite_outlined),
                selectedIcon: Icon(Icons.favorite),
                label: Text('Applications'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.delete_outline),
                selectedIcon: Icon(Icons.delete),
                label: Text('Trash'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.camera_outlined),
                selectedIcon: Icon(Icons.camera),
                label: Text('Photos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_suggest_outlined),
                selectedIcon: Icon(Icons.settings_suggest),
                label: Text('Junk files'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
              child: switch (_selectedIndex) {
            2 => const PhotosPage(),
            0 => const ApplicationsPage(),
            1 => const TrashPage(),
            _ => const Placeholder()
          }),
        ],
      ),
    );
  }
}
