import 'package:flutter/material.dart';

/// Fixed, centred crops keep the MVP editor predictable while using the exact
/// same crop state for the preview and the original-resolution export.
class CropPanel extends StatelessWidget {
  const CropPanel({
    super.key,
    required this.aspectRatio,
    required this.onChanged,
  });

  final double? aspectRatio;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = <(String, double?)>[
      ('원본', null),
      ('1:1', 1),
      ('4:5', .8),
      ('16:9', 16 / 9),
    ];
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(option.$1),
              selected: aspectRatio == option.$2,
              onSelected: (_) => onChanged(option.$2),
              selectedColor: Colors.white,
              labelStyle: TextStyle(
                color: aspectRatio == option.$2 ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: const Color(0xFF333333),
            ),
          ),
      ],
    );
  }
}
