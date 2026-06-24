import 'template.dart';

class PreviewArgs {
  const PreviewArgs({required this.template});

  final EditTemplate template;
}

class ResultArgs {
  const ResultArgs({required this.template, required this.previewStyle});

  final EditTemplate template;
  final String previewStyle;
}
