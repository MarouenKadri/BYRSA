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

  @override
  Widget build(BuildContext context) {
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
            'Sélectionnez le type de service dont vous avez besoin',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF98A0A8),
            ),
          ),
          AppGap.h28,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.06,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final isSelected = selectedService == service['id'];
              final icon = service['icon'] as IconData;
              final title = service['name'] as String;

              return GestureDetector(
                onTap: () => _showSubServices(context, service),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1, end: isSelected ? 1.02 : 1),
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: _LuxuryServiceCard(
                    title: title,
                    icon: icon,
                    isSelected: isSelected,
                    subtitle: isSelected ? selectedSubService : null,
                  ),
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSubServices(BuildContext context, Map<String, dynamic> service) {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(16, 20, 24, 0.06),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 34,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DCE0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Icon(
                    service['icon'] as IconData,
                    size: 22,
                    color: AppColors.gray700,
                  ),
                  AppGap.w12,
                  Text(
                    service['name'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkDark,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.gray50),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...(service['subServices'] as List).map((subService) {
                      final isSelected =
                          selectedService == service['id'] &&
                          selectedSubService == subService;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 2,
                        ),
                        title: Text(
                          subService,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.stepBlue
                                : AppColors.gray700,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.stepBlue,
                              )
                            : null,
                        onTap: () {
                          onServiceSelected(
                            service['id'] as String,
                            subService as String,
                          );
                          Navigator.pop(context);
                          Future.delayed(
                            const Duration(milliseconds: 280),
                            onCompleted,
                          );
                        },
                      );
                    }),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final String? subtitle;

  const _LuxuryServiceCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.stepBlue : Colors.transparent,
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color.fromRGBO(24, 71, 168, 0.10)
                : const Color.fromRGBO(16, 20, 24, 0.04),
            blurRadius: isSelected ? 18 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
              duration: const Duration(milliseconds: 220),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 0.06,
                  child: Transform.translate(
                    offset: Offset(0, -1.5 * value),
                    child: child,
                  ),
                );
              },
              child: Icon(icon, size: 31, color: AppColors.gray700),
            ),
            AppGap.h16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: AppColors.inkDark,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              AppGap.h8,
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: const Color(0xFF7E8790),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
