import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onCompleted});

  final Future<void> Function() onCompleted;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9F8F5),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 12, height: 12),
                ),
                SizedBox(width: 8),
                Text(
                  'FrameFit',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: 270,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE9D3B9),
                    Color(0xFF8CA5B0),
                    Color(0xFF292929),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Stack(
                children: [
                  Positioned.fill(child: _OnboardingGrid()),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'YOUR PHOTO,\nYOUR MOOD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '사진을 고르고,\n원하는 색감을 한 번에 적용하세요.',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '원본은 그대로 두고 프리셋 강도와 기본 보정만 간단하게 조절할 수 있어요.',
              style: TextStyle(
                color: Color(0xFF626262),
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              key: const Key('onboardingPrimaryCta'),
              onPressed: onCompleted,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('사진 편집 시작하기'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFF151515),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onCompleted,
              child: const Center(child: Text('둘러보기 건너뛰기')),
            ),
          ],
        ),
      ),
    ),
  );
}

class _OnboardingGrid extends StatelessWidget {
  const _OnboardingGrid();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _OnboardingGridPainter());
}

class _OnboardingGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..strokeWidth = 1;
    for (var i = 1; i <= 2; i++) {
      canvas.drawLine(
        Offset(size.width * i / 3, 0),
        Offset(size.width * i / 3, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 3),
        Offset(size.width, size.height * i / 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
