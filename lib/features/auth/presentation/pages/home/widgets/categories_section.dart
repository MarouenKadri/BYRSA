import 'package:flutter/material.dart';

class CategoriesRow extends StatelessWidget {
  const CategoriesRow({super.key});

  static const _items = [
    (Icons.home_rounded, 'Ménage'),
    (Icons.grass_rounded, 'Jardinage'),
    (Icons.child_care_rounded, "Garde d'enfants"),
    (Icons.bolt_rounded, 'Électricité'),
    (Icons.water_drop_rounded, 'Plomberie'),
    (Icons.handyman_rounded, 'Bricolage'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final (icon, label) = _items[index];
          return Padding(
            padding: const EdgeInsets.only(top: 9, bottom: 7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: const Color(0xFF646B73)),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                        color: const Color(0xFF646B73),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Container(
                  width: (label.length * 6).toDouble(),
                  height: 1,
                  color: const Color(0xFFD2D7DD),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
