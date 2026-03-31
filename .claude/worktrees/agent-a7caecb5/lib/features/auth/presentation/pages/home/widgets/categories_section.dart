import 'package:flutter/material.dart';
import '../../../widgets/category_chip.dart';

class CategoriesRow extends StatelessWidget {
  const CategoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    const categories = [
      (Icons.home_rounded, 'Ménage'),
      (Icons.grass_rounded, 'Jardinage'),
      (Icons.child_care_rounded, "Garde d'enfants"),
      (Icons.bolt_rounded, 'Électricité'),
      (Icons.water_drop_rounded, 'Plomberie'),
      (Icons.handyman_rounded, 'Bricolage'),
    ];

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 4),
            ...categories.map(
              (data) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CategoryChip(icon: data.$1, label: data.$2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
