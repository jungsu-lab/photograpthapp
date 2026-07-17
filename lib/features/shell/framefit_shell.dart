import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../home/home_screen.dart';
import '../shooting/shooting_library_screen.dart';
import '../templates/template_screen.dart';

class FrameFitShell extends StatefulWidget {
  const FrameFitShell({
    super.key,
    this.openPhotoPickerOnStart = false,
    this.openCameraOnStart = false,
  });

  final bool openPhotoPickerOnStart;
  final bool openCameraOnStart;

  @override
  State<FrameFitShell> createState() => _FrameFitShellState();
}

class _FrameFitShellState extends State<FrameFitShell> {
  var _index = 0;
  var _homeRefreshToken = 0;
  var _openedInitialCamera = false;

  void _selectIndex(int index) {
    setState(() {
      _index = index;
      if (index == 0) _homeRefreshToken++;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.openCameraOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _openedInitialCamera) return;
        _openedInitialCamera = true;
        Navigator.of(context).pushNamed(AppRoutes.camera);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _index,
      children: [
        HomeScreen(
          key: ValueKey(_homeRefreshToken),
          autoOpenPicker: widget.openPhotoPickerOnStart,
          onOpenShoot: () => _selectIndex(1),
          onOpenEdit: () => _selectIndex(2),
        ),
        const ShootingLibraryScreen(),
        const TemplateScreen(embedded: true),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: _selectIndex,
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
