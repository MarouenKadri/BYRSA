import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  // Push notifications
  bool _pushEnabled = true;
  bool _pushMessages = true;
  bool _pushMissions = true;
  bool _pushCandidatures = true;
  bool _pushReminders = true;
  bool _pushMarketing = false;

  // Email notifications
  bool _emailEnabled = true;
  bool _emailMessages = false;
  bool _emailMissions = true;
  bool _emailCandidatures = true;
  bool _emailNewsletter = true;

  // SMS notifications
  bool _smsEnabled = false;
  bool _smsUrgent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Notifications', style: context.profilePageTitleStyle),
        centerTitle: true,
      ),
      body: AppPageBody(
        padding: AppInsets.a16,
        useSafeAreaBottom: true,
        child: ListView(
          children: [
          // ─── Notifications Push ───
          _SectionHeader(
            icon: Icons.notifications_rounded,
            title: 'Notifications Push',
            subtitle: 'Recevez des alertes sur votre téléphone',
            isEnabled: _pushEnabled,
            onToggle: (value) => setState(() => _pushEnabled = value),
          ),
          if (_pushEnabled) ...[
            _NotificationGroup(
              children: [
                _NotificationSwitch(
                  title: 'Nouveaux messages',
                  subtitle: 'Quand quelqu\'un vous envoie un message',
                  value: _pushMessages,
                  onChanged: (v) => setState(() => _pushMessages = v),
                ),
                _NotificationSwitch(
                  title: 'Nouvelles missions',
                  subtitle: 'Missions correspondant à vos compétences',
                  value: _pushMissions,
                  onChanged: (v) => setState(() => _pushMissions = v),
                ),
                _NotificationSwitch(
                  title: 'Candidatures',
                  subtitle: 'Mises à jour sur vos candidatures',
                  value: _pushCandidatures,
                  onChanged: (v) => setState(() => _pushCandidatures = v),
                ),
                _NotificationSwitch(
                  title: 'Rappels',
                  subtitle: 'Rappels de missions à venir',
                  value: _pushReminders,
                  onChanged: (v) => setState(() => _pushReminders = v),
                ),
                _NotificationSwitch(
                  title: 'Offres et promotions',
                  subtitle: 'Offres spéciales et nouveautés',
                  value: _pushMarketing,
                  onChanged: (v) => setState(() => _pushMarketing = v),
                ),
              ],
            ),
          ],

          AppGap.h24,

          // ─── Notifications Email ───
          _SectionHeader(
            icon: Icons.email_rounded,
            title: 'Notifications Email',
            subtitle: 'Recevez des emails récapitulatifs',
            isEnabled: _emailEnabled,
            onToggle: (value) => setState(() => _emailEnabled = value),
          ),
          if (_emailEnabled) ...[
            _NotificationGroup(
              children: [
                _NotificationSwitch(
                  title: 'Messages non lus',
                  subtitle: 'Récapitulatif des messages non lus',
                  value: _emailMessages,
                  onChanged: (v) => setState(() => _emailMessages = v),
                ),
                _NotificationSwitch(
                  title: 'Nouvelles missions',
                  subtitle: 'Digest hebdomadaire des missions',
                  value: _emailMissions,
                  onChanged: (v) => setState(() => _emailMissions = v),
                ),
                _NotificationSwitch(
                  title: 'Candidatures',
                  subtitle: 'Confirmation et mises à jour',
                  value: _emailCandidatures,
                  onChanged: (v) => setState(() => _emailCandidatures = v),
                ),
                _NotificationSwitch(
                  title: 'Newsletter',
                  subtitle: 'Conseils et actualités Inkern',
                  value: _emailNewsletter,
                  onChanged: (v) => setState(() => _emailNewsletter = v),
                ),
              ],
            ),
          ],

          AppGap.h24,

          // ─── Notifications SMS ───
          _SectionHeader(
            icon: Icons.sms_rounded,
            title: 'Notifications SMS',
            subtitle: 'Pour les alertes urgentes uniquement',
            isEnabled: _smsEnabled,
            onToggle: (value) => setState(() => _smsEnabled = value),
          ),
          if (_smsEnabled) ...[
            _NotificationGroup(
              children: [
                _NotificationSwitch(
                  title: 'Alertes urgentes',
                  subtitle: 'Missions urgentes à proximité',
                  value: _smsUrgent,
                  onChanged: (v) => setState(() => _smsUrgent = v),
                ),
              ],
            ),
          ],

          AppGap.h24,

          // ─── Ne pas déranger ───
          _buildDoNotDisturbSection(),

          AppGap.h24,

          // ─── Sons et vibrations ───
          _buildSoundsSection(),

          AppGap.h32,
          ],
        ),
      ),
    );
  }

  Widget _buildDoNotDisturbSection() {
    return AppSurfaceCard(
      padding: AppInsets.a20,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSurfaceCard(
                padding: AppInsets.a10,
                color: Colors.indigo[50]!,
                borderRadius: BorderRadius.circular(AppDesign.radius12),
                child: Icon(
                  Icons.do_not_disturb_on_rounded,
                  color: Colors.indigo[700]!,
                ),
              ),
              AppGap.w14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ne pas déranger',
                      style: context.profileSectionTitleStyle.copyWith(
                        fontSize: AppFontSize.lg,
                      ),
                    ),
                    Text(
                      'Suspendre les notifications',
                      style: context.profileSecondaryLabelStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGap.h16,
          AppSurfaceCard(
            padding: AppInsets.a12,
            color: context.colors.background,
            borderRadius: BorderRadius.circular(AppDesign.radius10),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: context.colors.textSecondary, size: 20),
                AppGap.w10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horaires silencieux',
                        style: context.profilePrimaryLabelStyle.copyWith(
                          fontSize: AppFontSize.base,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Text(
                        '22h00 - 08h00',
                        style: context.profileSecondaryLabelStyle,
                      ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Modifier',
                  variant: ButtonVariant.ghost,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundsSection() {
    return AppSurfaceCard(
      padding: AppInsets.a20,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppInsets.a10,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha:0.08),
                  borderRadius: BorderRadius.circular(AppDesign.radius12),
                ),
                child: Icon(Icons.volume_up_rounded, color: AppColors.warning),
              ),
              AppGap.w14,
              Text(
                'Sons et vibrations',
                style: context.profileSectionTitleStyle.copyWith(
                  fontSize: AppFontSize.lg,
                ),
              ),
            ],
          ),
          AppGap.h16,
          _SettingRow(
            title: 'Son de notification',
            trailing: Text(
              'Inkern',
              style: context.profileSecondaryLabelStyle.copyWith(fontSize: AppFontSize.body),
            ),
            onTap: () {},
          ),
          const Divider(height: 24),
          _SettingRow(
            title: 'Vibration',
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: AppInsets.a16,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      child: Row(
        children: [
          AppSurfaceCard(
            padding: AppInsets.a10,
            color: AppColors.primary.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(AppDesign.radius12),
            child: Icon(icon, color: AppColors.primary),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.profileSectionTitleStyle.copyWith(
                    fontSize: AppFontSize.lg,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.profileSecondaryLabelStyle,
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  final List<Widget> children;

  const _NotificationGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      margin: const EdgeInsets.only(top: 8),
      padding: AppInsets.a4,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(children: children),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.h12v8,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.profilePrimaryLabelStyle,
                ),
                Text(
                  subtitle,
                  style: context.profileSecondaryLabelStyle,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            title,
            style: context.profilePrimaryLabelStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
