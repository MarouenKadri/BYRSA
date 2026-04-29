import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_design_system.dart';
import '../auth_provider.dart';
import '../enum/user_role.dart';
import '../widgets/sheet_profile_header.dart';

class RoleSwitchSheet extends StatelessWidget {
  final String firstName;
  final String avatarUrl;
  final VoidCallback? onGoToAccount;

  const RoleSwitchSheet({
    super.key,
    required this.firstName,
    this.avatarUrl = '',
    this.onGoToAccount,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isClient = auth.currentRole == UserRole.client;
    final isLoading = auth.isLoading;
    return AppActionSheet(
      title: 'Mode',
      header: AppSheetProfileHeader(onAccountTap: onGoToAccount),
      children: [
        AppGap.h8,
        _RoleItem(
          icon: Icons.person_outline_rounded,
          label: 'Client',
          subtitle: 'Trouvez des prestataires',
          isSelected: isClient,
          onTap: isClient || isLoading
              ? null
              : () async {
                  Navigator.pop(context);
                  await context.read<AuthProvider>().switchRole(UserRole.client);
                },
        ),
        const Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: AppColors.whiteAlpha12,
        ),
        _RoleItem(
          icon: Icons.handyman_outlined,
          label: 'Prestataire',
          subtitle: 'Proposez vos services',
          isSelected: !isClient,
          onTap: !isClient || isLoading
              ? null
              : () async {
                  Navigator.pop(context);
                  await context.read<AuthProvider>().switchRole(UserRole.provider);
                },
        ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLoadingIndicator(size: AppBarMetrics.loadingIndicatorSize),
                AppGap.w8,
                Text(
                  'Changement en cours...',
                  style: context.appBarMutedMetaStyle.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RoleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 21,
              color: isSelected
                  ? AppColors.snow
                  : AppColors.snow.withValues(alpha: 0.75),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.sheetActionTitleStyle.copyWith(
                      color: AppColors.snow,
                    ),
                  ),
                  AppGap.h2,
                  Text(
                    subtitle,
                    style: context.sheetActionSubtitleStyle.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.snow,
              ),
          ],
        ),
      ),
    );
  }
}
