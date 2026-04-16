import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../profile_provider.dart';

class MyInformationPage extends StatefulWidget {
  const MyInformationPage({super.key});

  @override
  State<MyInformationPage> createState() => _MyInformationPageState();
}

class _MyInformationPageState extends State<MyInformationPage> {
  int _selectedTabIndex = 0;
  final _emailTabKey = GlobalKey<_EmailInfoTabState>();
  final _phoneTabKey = GlobalKey<_PhoneInfoTabState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text(
          'Mes informations',
          style: context.profilePageTitleStyle,
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
      body: Column(
        children: [
          const SizedBox(height: 10),
          AppSegmentedTabBar(
            selectedIndex: _selectedTabIndex,
            onChanged: (index) => setState(() => _selectedTabIndex = index),
            tabs: const [
              AppSegmentedTab(label: 'Personnel'),
              AppSegmentedTab(label: 'Email'),
              AppSegmentedTab(label: 'Téléphone'),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 0,
                    child: const _PersonalInfoTab(),
                  ),
                ),
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 1,
                    child: _EmailInfoTab(key: _emailTabKey),
                  ),
                ),
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 2,
                    child: _PhoneInfoTab(key: _phoneTabKey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomAction(BuildContext context) {
    if (_selectedTabIndex == 0) return null;

    final isEmailTab = _selectedTabIndex == 1;
    final loading = isEmailTab
        ? context.watch<AuthProvider>().isLoading
        : context.watch<ProfileProvider>().isSaving;

    return AppActionFooter(
      child: AppButton(
        label: 'Enregistrer',
        variant: ButtonVariant.black,
        isLoading: loading,
        onPressed: loading
            ? null
            : () {
                if (isEmailTab) {
                  _emailTabKey.currentState?.submitFromParent();
                } else {
                  _phoneTabKey.currentState?.submitFromParent();
                }
              },
      ),
    );
  }
}

class _PersonalInfoTab extends StatelessWidget {
  const _PersonalInfoTab();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
      children: [
        _InfoCard(
          title: 'Informations personnelles',
          rows: [
            _InfoRowData(
              icon: Icons.person_outline_rounded,
              label: 'Prénom',
              value: profile?.firstName ?? '—',
            ),
            _InfoRowData(
              icon: Icons.person_outline_rounded,
              label: 'Nom',
              value: profile?.lastName ?? '—',
            ),
            _InfoRowData(
              icon: Icons.cake_outlined,
              label: 'Date de naissance',
              value: _formatBirthDate(profile?.birthDate),
            ),
            _InfoRowData(
              icon: Icons.wc_outlined,
              label: 'Genre',
              value: _formatGender(profile?.gender),
            ),
          ],
          helper:
              'Ces informations ne peuvent pas être modifiées après inscription.',
        ),
      ],
    );
  }
}

class _EmailInfoTab extends StatefulWidget {
  const _EmailInfoTab({super.key});

  @override
  State<_EmailInfoTab> createState() => _EmailInfoTabState();
}

class _EmailInfoTabState extends State<_EmailInfoTab> {
  final _formKey = GlobalKey<FormState>();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final email = profile?.email ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
      children: [
        _InfoCard(
          title: 'Adresse email',
          rows: [
            _InfoRowData(
              icon: Icons.mail_outline_rounded,
              label: 'Email actuel',
              value: email.isNotEmpty ? email : '—',
            ),
          ],
          helper:
              'Un email de confirmation vous sera envoyé après modification.',
        ),
        AppGap.h16,
        _FormCard(
          title: 'Nouveau email',
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _newCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  style: TextStyle(
                    fontSize: AppFontSize.body,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textPrimary,
                  ),
                  decoration: AppInputDecorations.profileField(
                    context,
                    hintText: 'Nouvel email',
                    radius: 18,
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      size: 16,
                      color: Color(0xFFB0BAC4),
                    ),
                  ).copyWith(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    errorStyle: context.profileErrorStyle,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Champ requis';
                    final normalized = v.trim();
                    if (!RegExp(
                      r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(normalized)) {
                      return 'Adresse email invalide';
                    }
                    if (normalized == email) {
                      return "Doit être différent de l'email actuel";
                    }
                    return null;
                  },
                ),
                AppGap.h12,
                TextFormField(
                  controller: _confirmCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  style: TextStyle(
                    fontSize: AppFontSize.body,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textPrimary,
                  ),
                  decoration: AppInputDecorations.profileField(
                    context,
                    hintText: 'Confirmer le nouvel email',
                    radius: 18,
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      size: 16,
                      color: Color(0xFFB0BAC4),
                    ),
                  ).copyWith(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    errorStyle: context.profileErrorStyle,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Champ requis';
                    if (v.trim() != _newCtrl.text.trim()) {
                      return 'Les emails ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> submitFromParent() => _submit();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final newEmail = _newCtrl.text.trim();
    final err = await context.read<AuthProvider>().updateEmail(newEmail);
    if (!mounted) return;

    if (err != null) {
      showAppSnackBar(context, err, type: SnackBarType.error);
      return;
    }

    _newCtrl.clear();
    _confirmCtrl.clear();
    showAppSnackBar(
      context,
      'Email mis à jour. Confirmez via le lien envoyé.',
      type: SnackBarType.success,
    );
  }
}

class _PhoneInfoTab extends StatefulWidget {
  const _PhoneInfoTab({super.key});

  @override
  State<_PhoneInfoTab> createState() => _PhoneInfoTabState();
}

class _PhoneInfoTabState extends State<_PhoneInfoTab> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final phone = profile?.phone?.isNotEmpty == true ? profile!.phone! : '—';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
      children: [
        _InfoCard(
          title: 'Numéro de téléphone',
          rows: [
            _InfoRowData(
              icon: Icons.phone_outlined,
              label: 'Numéro actuel',
              value: phone,
            ),
          ],
          helper: 'Ce numéro est utilisé pour les notifications importantes.',
        ),
        AppGap.h16,
        _FormCard(
          title: 'Nouveau numéro',
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                    fontSize: AppFontSize.body,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textPrimary,
                  ),
                  decoration: AppInputDecorations.profileField(
                    context,
                    hintText: 'Nouveau numéro',
                    radius: 18,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Color(0xFFB0BAC4),
                    ),
                  ).copyWith(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    errorStyle: context.profileErrorStyle,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Champ requis';
                    final normalized = v.trim();
                    final digits = normalized.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 8 || digits.length > 15) {
                      return 'Numéro de téléphone invalide';
                    }
                    final current =
                        context.read<ProfileProvider>().profile?.phone ?? '';
                    if (normalized == current) {
                      return 'Doit être différent du numéro actuel';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> submitFromParent() => _submit();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final profileProvider = context.read<ProfileProvider>();
    final current = profileProvider.profile;
    if (current == null) return;

    final updated = current.copyWith(phone: _phoneCtrl.text.trim());
    final err = await profileProvider.updateProfile(updated);
    if (!mounted) return;

    if (err != null) {
      showAppSnackBar(context, err, type: SnackBarType.error);
      return;
    }

    _phoneCtrl.clear();
    showAppSnackBar(
      context,
      'Numéro de téléphone mis à jour',
      type: SnackBarType.success,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRowData> rows;
  final String? helper;

  const _InfoCard({
    required this.title,
    required this.rows,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppGap.h16,
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            return Column(
              children: [
                _InfoRow(data: row),
                if (index < rows.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(
                      height: 1,
                      color: context.colors.divider,
                    ),
                  ),
              ],
            );
          }),
          if (helper != null) ...[
            AppGap.h16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.border),
              ),
              child: Text(
                helper!,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final _InfoRowData data;

  const _InfoRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(data.icon, size: 20, color: context.colors.textSecondary),
        ),
        AppGap.w14,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              AppGap.h4,
              Text(
                data.value,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _FormCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _FormCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppGap.h16,
          child,
        ],
      ),
    );
  }
}

class _AnimatedTabPane extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _AnimatedTabPane({
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        opacity: visible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          offset: visible ? Offset.zero : const Offset(0.02, 0),
          child: child,
        ),
      ),
    );
  }
}

String _formatBirthDate(DateTime? birthDate) {
  if (birthDate == null) return '—';
  return DateFormat('dd/MM/yyyy', 'fr_FR').format(birthDate);
}

String _formatGender(String? gender) {
  switch (gender) {
    case 'homme':
      return 'Homme';
    case 'femme':
      return 'Femme';
    case 'autre':
      return 'Autre';
    default:
      return '—';
  }
}
