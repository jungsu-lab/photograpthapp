import 'package:flutter/material.dart';

import '../../features/analysis/analysis_screen.dart';
import '../../features/camera/camera_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/preview/preview_screen.dart';
import '../../features/result/result_screen.dart';
import '../../features/templates/template_detail_screen.dart';
import '../../features/templates/template_screen.dart';

class AppRoutes {
  static const home = '/home';
  static const camera = '/camera';
  static const analysis = '/analysis';
  static const templates = '/templates';
  static const templateDetail = '/templates/detail';
  static const preview = '/preview';
  static const result = '/result';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = switch (settings.name) {
      home => (_) => const HomeScreen(),
      camera => (_) => const CameraScreen(),
      analysis => (_) => const AnalysisScreen(),
      templates => (_) => const TemplateScreen(),
      templateDetail => (_) => const TemplateDetailScreen(),
      preview => (_) => const PreviewScreen(),
      result => (_) => const ResultScreen(),
      _ => (_) => const HomeScreen(),
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
