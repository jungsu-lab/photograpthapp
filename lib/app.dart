import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class FrameFitApp extends StatefulWidget {
  const FrameFitApp({super.key});

  @override
  State<FrameFitApp> createState() => _FrameFitAppState();
}

class _FrameFitAppState extends State<FrameFitApp> {
  static const _onboardingKey = 'onboarding-complete-v1';
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (mounted) {
        setState(
          () => _onboardingComplete =
              preferences.getBool(_onboardingKey) ?? false,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _onboardingComplete = false);
    }
  }

  Future<void> _finishOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingKey, true);
    if (mounted) setState(() => _onboardingComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    final home = switch (_onboardingComplete) {
      null => const _LoadingScreen(),
      true => const HomeScreen(),
      false => OnboardingScreen(onCompleted: _finishOnboarding),
    };
    return MaterialApp(
      title: 'FrameFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: home,
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
