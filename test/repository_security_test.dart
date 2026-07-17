import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('project tree does not include credentials or signing material', () async {
    final sensitiveFile = RegExp(
      r'(^|/)(\.env(?:\..*)?|.*\.(?:jks|keystore|p8|pem|key|mobileprovision)|'
      r'google-services\.json|.*(?:service-account|firebase-adminsdk).*\.json)$',
      caseSensitive: false,
    );
    final ignoredDirectories = <String>{'.dart_tool', '.git', 'build'};
    final findings = <String>[];

    await for (final entity in Directory.current.list(recursive: true)) {
      final path = entity.path.replaceAll('\\', '/');
      if (path.split('/').any(ignoredDirectories.contains)) continue;
      if (sensitiveFile.hasMatch(path)) findings.add(path);
    }

    expect(findings, isEmpty);
  });

  test('application source contains no obvious credential literals', () async {
    final credential = RegExp(
      r'(AIza[0-9A-Za-z_-]{20,}|AKIA[0-9A-Z]{16}|'
      r'gh[pousr]_[A-Za-z0-9_]{20,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----)',
    );
    final source = Directory('lib');
    final findings = <String>[];

    await for (final entity in source.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final contents = await entity.readAsString();
      if (credential.hasMatch(contents)) findings.add(entity.path);
    }

    expect(findings, isEmpty);
  });

  test('community schema enables RLS and never embeds an admin key', () async {
    final migration = await File(
      'supabase/migrations/202607170001_create_community.sql',
    ).readAsString();

    expect(migration, contains('enable row level security'));
    expect(migration, contains("bucket_id = 'community-photos'"));
    expect(migration, contains('(select auth.uid())'));
    expect(migration.toLowerCase(), isNot(contains('service_role')));
  });
}
