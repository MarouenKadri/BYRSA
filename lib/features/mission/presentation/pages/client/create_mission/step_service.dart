import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../../../core/design/app_primitives.dart';

class StepService extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final String? selectedService;
  final String? selectedSubService;
  final Function(String, String?) onServiceSelected;
  final VoidCallback onCompleted;

  const StepService({
    super.key,
    required this.services,
    required this.selectedService,
    required this.selectedSubService,
    required this.onServiceSelected,
    required this.onCompleted,
  });

  Map<String, dynamic>? _selectedServiceMeta() {
    for (final service in services) {
      if (service['id'] == selectedService) return service;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedMeta = _selectedServiceMeta();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quel service recherchez-vous ?',
            style: TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w700,
              height: 1.16,
              color: AppColors.inkDark,
              letterSpacing: -0.7,
            ),
          ),
          AppGap.h10,
          Text(
            'Choisissez votre catégorie puis un sous-service précis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF98A0A8),
            ),
          ),
          if (selectedMeta != null) ...[
            AppGap.h16,
            _SelectedServiceSummary(
              title: selectedMeta['name'] as String? ?? 'Service',
              icon: selectedMeta['icon'] as IconData? ?? Icons.category_rounded,
              color: selectedMeta['color'] as Color? ?? AppColors.primary,
              subtitle: selectedSubService ?? 'Sous-service à confirmer',
            ),
          ],
          AppGap.h20,
          _buildServiceGrid(context, services),
        ],
      ),
    );
  }

  void _showSubServices(BuildContext context, Map<String, dynamic> service) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => _SubServicesSheet(
        serviceName: service['name'] as String? ?? 'Service',
        serviceIcon: service['icon'] as IconData? ?? Icons.category_rounded,
        serviceColor: service['color'] as Color? ?? AppColors.primary,
        subServices: _readSubServices(service['subServices']),
        selectedSubService:
            selectedService == service['id'] ? selectedSubService : null,
        onSelected: (subService) {
          onServiceSelected(
            service['id'] as String,
            subService,
          );
          Navigator.pop(context);
          Future.delayed(
            const Duration(milliseconds: 240),
            onCompleted,
          );
        },
      ),
    );
  }

  Widget _buildServiceGrid(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.02,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final service = items[index];
        final isSelected = selectedService == service['id'];
        final color = service['color'] as Color? ?? AppColors.primary;
        final subServices = _readSubServices(service['subServices']);
        return GestureDetector(
          onTap: () => _showSubServices(context, service),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1, end: isSelected ? 1.015 : 1),
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: _ServiceCategoryCard(
              title: service['name'] as String? ?? 'Service',
              icon: service['icon'] as IconData? ?? Icons.category_rounded,
              color: color,
              isSelected: isSelected,
              subtitle: isSelected
                  ? selectedSubService
                  : '${subServices.length} options',
            ),
          ),
        );
      },
    );
  }

  List<String> _readSubServices(dynamic raw) {
    if (raw is List) {
      return raw
          .map((entry) => '$entry'.trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

class _SubServicesSheet extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;
  final List<String> subServices;
  final String? selectedSubService;
  final ValueChanged<String> onSelected;

  const _SubServicesSheet({
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
    required this.subServices,
    required this.selectedSubService,
    required this.onSelected,
  });

  @override
  State<_SubServicesSheet> createState() => _SubServicesSheetState();
}

class _SubServicesSheetState extends State<_SubServicesSheet> {
  @override
  Widget build(BuildContext context) {
    final subServices = widget.subServices;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 20, 24, 0.08),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DCE0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.serviceColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.serviceIcon,
                    size: 19,
                    color: widget.serviceColor,
                  ),
                ),
                AppGap.w10,
                Expanded(
                  child: Text(
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppColors.inkDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Sélectionnez le service exact pour votre mission',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: subServices.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 28,
                              color: context.colors.textTertiary,
                            ),
                            AppGap.h8,
                            Text(
                              'Aucun sous-service disponible',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subServices.map((subService) {
                        final isSelected = widget.selectedSubService == subService;
                        return AppPillChip(
                          label: subService,
                          selected: isSelected,
                          onTap: () => widget.onSelected(subService),
                          backgroundColor: widget.serviceColor.withValues(
                            alpha: 0.10,
                          ),
                          foregroundColor: AppColors.inkDark,
                          selectedBackgroundColor: widget.serviceColor,
                          selectedForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedServiceSummary extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SelectedServiceSummary({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          AppGap.w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkDark,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _ServiceCategoryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;

  const _ServiceCategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.10)
            : context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? color : context.colors.border,
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? color.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isSelected ? 14 : 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 19, color: color),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: color,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: AppColors.inkDark,
                letterSpacing: -0.2,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              AppGap.h5,
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? color : context.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
