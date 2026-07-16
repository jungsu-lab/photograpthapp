import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../shooting/shooting_library_screen.dart';
import '../templates/template_screen.dart';

class FrameFitShell extends StatefulWidget {
  const FrameFitShell({super.key, this.openPhotoPickerOnStart = false});

  final bool openPhotoPickerOnStart;

  @override
  State<FrameFitShell> createState() => _FrameFitShellState();
}

class _FrameFitShellState extends State<FrameFitShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _index,
      children: [
        HomeScreen(
          autoOpenPicker: widget.openPhotoPickerOnStart,
          onOpenShoot: () => setState(() => _index = 1),
          onOpenEdit: () => setState(() => _index = 2),
        ),
        const ShootingLibraryScreen(),
        const TemplateScreen(embedded: true),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '홈',
        ),
        NavigationDestination(
          icon: Icon(Icons.camera_alt_outlined),
          selectedIcon: Icon(Icons.camera_alt),
          label: '촬영',
        ),
        NavigationDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune),
          label: '편집',
        ),
      ],
    ),
  );
}
