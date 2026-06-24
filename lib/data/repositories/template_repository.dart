import '../mock/mock_templates.dart';
import '../models/template.dart';

class TemplateRepository {
  const TemplateRepository();

  List<EditTemplate> all() => mockTemplates;

  List<EditTemplate> byCategory(String category) {
    if (category == '전체') {
      return all();
    }
    return mockTemplates
        .where((template) => template.category == category)
        .toList(growable: false);
  }
}
