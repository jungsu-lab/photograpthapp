import 'package:flutter/material.dart';

import '../../features/analysis/analysis_screen.dart';
import '../../features/camera/camera_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/preview/preview_screen.dart';
import '../../features/result/result_screen.dart';
import '../../features/templates/template_screen.dart';

class AppRoutes {
  static const home = '/home';
  static const camera = '/camera';
  static const analysis = '/analysis';
  static const templates = '/templates';
  static const preview = '/preview';
  static const result = '/result';

  static Map<String, WidgetBuilder> get routes => {
    home: (_) => const HomeScreen(),
    camera: (_) => const CameraScreen(),
    analysis: (_) => const AnalysisScreen(),
    templates: (_) => const TemplateScreen(),
    preview: (_) => const PreviewScreen(),
    result: (_) => const ResultScreen(),
  };
}
