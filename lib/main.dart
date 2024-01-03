import 'package:mac_cleaner/pages/photos.dart';
import 'package:mac_cleaner/pages/trash.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'package:mac_cleaner/pages/applications.dart';
import 'dart:io';

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
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.acrylic,
    color: const Color(0xCC222222),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const NavRailCustom(),
    );
  }
}

class NavRailCustom extends StatefulWidget {
  const NavRailCustom({super.key});

  @override
  State<NavRailCustom> createState() => _NavRailCustomState();
}

class _NavRailCustomState extends State<NavRailCustom> {
  int _selectedIndex = 0;

  OutlinedButton renderItem(
      {required String label, required int index, required FaIcon icon}) {
    return OutlinedButton.icon(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor:
              _selectedIndex == index ? Colors.white12 : Colors.transparent,
          side: const BorderSide(color: Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        icon: icon,
        label: Padding(
          padding: const EdgeInsets.only(left: 0, top: 8.0, bottom: 8.0),
          child: Align(alignment: Alignment.topLeft, child: Text(label)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black45,
        body: Row(children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, bottom: 16, right: 16, top: 40),
            child: SizedBox(
              width: 190,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Simple Mac Cleaner',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            renderItem(
                                index: 0,
                                label: 'Applications',
                                icon: const FaIcon(
                                  FontAwesomeIcons.appStore,
                                  size: 21,
                                )),
                            const SizedBox(height: 4),
                            renderItem(
                                index: 1,
                                label: 'Photos',
                                icon: const FaIcon(FontAwesomeIcons.photoFilm,
                                    size: 16)),
                            const SizedBox(height: 4),
                            renderItem(
                                index: 2,
                                label: 'Trash',
                                icon: const FaIcon(
                                  FontAwesomeIcons.trashCan,
                                  size: 23,
                                ))
                          ]),
                    ],
                  ),
                  const Text('Hot Soft Dawid Lipiński',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
          Expanded(
              child: switch (_selectedIndex) {
            1 => const PhotosPage(),
            0 => const ApplicationsPage(),
            2 => const TrashPage(),
            _ => const Placeholder()
          })
        ]));
  }
}
