import 'template.dart';

class TemplateDetailArgs {
  const TemplateDetailArgs({required this.template});

  final EditTemplate template;
}

class TemplateLibraryArgs {
  const TemplateLibraryArgs({this.initialCategory});

  final String? initialCategory;
}

class CameraArgs {
  const CameraArgs({this.template});

  final EditTemplate? template;
}

class PreviewArgs {
  const PreviewArgs({required this.template});

  final EditTemplate template;
}

class ResultArgs {
  const ResultArgs({required this.template, required this.previewStyle});

  final EditTemplate template;
  final String previewStyle;
}
