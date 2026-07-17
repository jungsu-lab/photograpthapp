import 'package:flutter/material.dart';

import 'app.dart';
import 'services/community_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CommunityBackend.initialize();
  runApp(const FrameFitApp());
}
