import '../mock/mock_templates.dart';
import '../models/template.dart';

class TemplateRepository {
  const TemplateRepository();

  List<EditTemplate> all() => mockTemplates;

  List<String> get categories {
    const preferredOrder = ['전체', '프로필', '셀카', '음식', '여행', '상품', '감성'];
    final available = mockTemplates
        .map((template) => template.category)
        .toSet();

    return [
      for (final category in preferredOrder)
        if (category == '전체' || available.contains(category)) category,
    ];
  }

  List<EditTemplate> byCategory(String category) {
    if (category == '전체') {
      return all();
    }
    return all()
        .where((template) => template.category == category)
        .toList(growable: false);
  }

  List<EditTemplate> recommended({int limit = 3}) {
    final templates = all().toList(growable: false)
      ..sort((a, b) {
        final scoreComparison = b.beginnerFriendlyScore.compareTo(
          a.beginnerFriendlyScore,
        );
        if (scoreComparison != 0) {
          return scoreComparison;
        }
        return b.rating.compareTo(a.rating);
      });

    return templates.take(limit).toList(growable: false);
  }

  EditTemplate? byId(String id) {
    for (final template in all()) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }
}
