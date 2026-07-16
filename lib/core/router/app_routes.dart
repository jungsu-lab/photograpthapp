import 'package:flutter/material.dart';

import '../../features/camera/camera_screen.dart';
import '../../features/editor/editor_screen.dart';
import '../../features/shell/framefit_shell.dart';
import '../../features/templates/template_screen.dart';

class AppRoutes {
  static const home = '/home';
  static const camera = '/camera';
  static const templates = '/templates';
  static const editor = '/editor';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = switch (settings.name) {
      home => (_) => const FrameFitShell(),
      camera => (_) => const CameraScreen(),
      templates => (_) => const TemplateScreen(),
      editor => (_) => const EditorScreen(),
      _ => (_) => const FrameFitShell(),
    };

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 210),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.035),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
