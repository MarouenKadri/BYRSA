import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../../auth/data/models/service_type.dart';
import '../../../../profile/profile_provider.dart';
import 'user_common_widgets.dart';

void showFreelancerProfileBottomSheet(BuildContext context) {
  showAppBottomSheet(
    context: context,
    isScrollControlled: true,
    wrapWithSurface: false,
    child: const _FreelancerProfileSheet(),
  );
}

class _FreelancerProfileSheet extends StatefulWidget {
  const _FreelancerProfileSheet();

  @override
  State<_FreelancerProfileSheet> createState() => _FreelancerProfileSheetState();
}

class _FreelancerProfileSheetState extends State<_FreelancerProfileSheet> {
  late final Set<ServiceType> _selectedSkills;
  late final TextEditingController _tarifCtrl;
  late final TextEditingController _bioCtrl;
  double _radius = 15;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _selectedSkills = {
      if (profile != null)
        for (final cat in profile.serviceCategories)
          ServiceType.values.where((s) => s.name == cat || s.label.toLowerCase() == cat.toLowerCase()).firstOrNull
        ?? ServiceType.autre,
    };
    if (_selectedSkills.isEmpty) {
      _selectedSkills.addAll([ServiceType.menage, ServiceType.jardinage, ServiceType.bricolage]);
    }
    _tarifCtrl = TextEditingController(
      text: profile?.hourlyRate != null ? profile!.hourlyRate!.toInt().toString() : '25',
    );
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _tarifCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScrollableSheet(
      title: 'Mon activité',
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      color: AppColors.snow,
      builder: (_, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        children: [
          _buildAboutSection(),
          const SizedBox(height: 28),
          _buildSkillsSection(),
          const SizedBox(height: 28),
          _buildRayonSection(),
          const SizedBox(height: 28),
          _buildTarifSection(),
        ],
      ),
      footer: Column(
        children: [
          ProfileSheetPrimaryAction(
            onPressed: _submit,
            label: "Enregistrer",
          ),
          AppGap.h12,
          Center(
            child: ProfileSheetSecondaryAction(
              label: "Annuler",
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return _ActivitySection(
      title: 'A propos',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller: _bioCtrl,
          maxLines: 5,
          maxLength: 300,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w500,
            color: Color(0xFF20252B),
          ),
          decoration: AppInputDecorations.formField(
            context,
            hintText: 'Parlez de votre experience, de votre approche et de vos specialites.',
            hintStyle: const TextStyle(
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9AA1A8),
            ),
            contentPadding: const EdgeInsets.all(18),
            noBorder: true,
            fillColor: Colors.transparent,
          ).copyWith(
            counterStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9AA1A8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return _ActivitySection(
      title: 'Competences',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: ServiceType.values.map((skill) {
          final selected = _selectedSkills.contains(skill);
          return GestureDetector(
            onTap: () => setState(() {
              selected ? _selectedSkills.remove(skill) : _selectedSkills.add(skill);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: selected ? AppColors.ink : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _mapSkillIcon(skill),
                    size: 14,
                    color: selected ? Colors.white : const Color(0xFF565D65),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    skill.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? Colors.white : const Color(0xFF50565D),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRayonSection() {
    return _ActivitySection(
      title: 'Rayon',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Rayon d'intervention",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF20252B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_radius.toInt()} km',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: AppColors.ink,
              inactiveTrackColor: const Color(0xFFD9DEE3),
              thumbColor: AppColors.ink,
              overlayColor: AppColors.ink.withValues(alpha: 0.08),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _radius,
              min: 1,
              max: 100,
              divisions: 99,
              onChanged: (value) => setState(() => _radius = value),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 km',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF7E858C),
                ),
              ),
              Text(
                '100 km',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF7E858C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarifSection() {
    return _ActivitySection(
      title: 'Tarif',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: TextFormField(
          controller: _tarifCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: AppColors.ink,
            letterSpacing: -0.8,
          ),
          decoration: AppInputDecorations.formField(
            context,
            hintText: '0',
            hintStyle: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Color(0xFFB4BAC1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            noBorder: true,
            fillColor: Colors.transparent,
          ).copyWith(
            suffixText: '€ / h',
            suffixStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7E858C),
            ),
          ),
        ),
      ),
    );
  }

  IconData _mapSkillIcon(ServiceType skill) {
    switch (skill) {
      case ServiceType.menage:
        return Icons.cleaning_services_outlined;
      case ServiceType.jardinage:
        return Icons.yard_outlined;
      case ServiceType.bricolage:
        return Icons.handyman_outlined;
      case ServiceType.gardeEnfants:
        return Icons.child_care_outlined;
      case ServiceType.electricite:
        return Icons.bolt_outlined;
      case ServiceType.plomberie:
        return Icons.plumbing_outlined;
      case ServiceType.peinture:
        return Icons.format_paint_outlined;
      case ServiceType.demenagement:
        return Icons.local_shipping_outlined;
      case ServiceType.coursesLivraison:
        return Icons.shopping_bag_outlined;
      case ServiceType.animaux:
        return Icons.pets_outlined;
      case ServiceType.informatique:
        return Icons.computer_outlined;
      case ServiceType.couture:
        return Icons.content_cut_outlined;
      case ServiceType.cuisine:
        return Icons.restaurant_outlined;
      case ServiceType.autre:
        return Icons.auto_awesome_outlined;
    }
  }

  Future<void> _submit() async {
    final profileProvider = context.read<ProfileProvider>();
    final current = profileProvider.profile;
    if (current == null) {
      Navigator.pop(context);
      return;
    }
    final rate = double.tryParse(_tarifCtrl.text.trim());
    final updated = current.copyWith(
      bio: _bioCtrl.text.trim(),
      hourlyRate: rate,
      serviceCategories: _selectedSkills.map((s) => s.name).toList(),
    );
    final err = await profileProvider.updateProfile(updated);
    if (!mounted) return;
    if (err != null) {
      showAppSnackBar(context, err, type: SnackBarType.error);
    } else {
      Navigator.pop(context);
      showAppSnackBar(context, 'Activité mise à jour', type: SnackBarType.success);
    }
  }
}

class _ActivitySection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ActivitySection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF20252B),
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}
