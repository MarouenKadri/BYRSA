import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../widgets/shared/user_common_widgets.dart';

class FreelancerPaymentMethodsPage extends StatefulWidget {
  const FreelancerPaymentMethodsPage({super.key});

  @override
  State<FreelancerPaymentMethodsPage> createState() =>
      _FreelancerPaymentMethodsPageState();
}

class _FreelancerPaymentMethodsPageState
    extends State<FreelancerPaymentMethodsPage> {
  double _minPayout = 20;
  bool _autoPayoutEnabled = false;

  void _showIbanOptions(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: AppDarkSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppBottomSheetHandle(),
            AppGap.h12,
            const Padding(
              padding: AppInsets.h20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Compte bancaire',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.snow),
                ),
              ),
            ),
            AppGap.h8,
            _SheetRow(
              icon: Icons.edit_outlined,
              label: 'Modifier l\'IBAN',
              onTap: () { Navigator.pop(context); _showEditIbanSheet(context); },
            ),
            const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0x1FFFFFFF)),
            _SheetRow(
              icon: Icons.delete_outline_rounded,
              label: 'Supprimer le compte',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                showAppBottomSheet(
                  context: context,
                  wrapWithSurface: false,
                  child: _DeleteConfirmSheet(
                    title: 'Supprimer le compte ?',
                    subtitle: 'Le compte FR76 •••• 1234 sera supprimé définitivement.',
                    onConfirm: () {},
                  ),
                );
              },
            ),
            SizedBox(height: 12 + bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Moyens de paiement', style: context.profilePageTitleStyle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [

          // ─── Statut paiements ──────────────────────────────────────────────
          _StatusBanner(),
          AppGap.h24,

          // ─── Compte IBAN ───────────────────────────────────────────────────
          Text('COMPTE BANCAIRE', style: _sectionStyle(context)),
          AppGap.h10,
          _IbanCard(onTap: () => _showIbanOptions(context)),
          AppGap.h10,
          _AddButton(
            label: 'Ajouter un compte bancaire',
            onTap: () => _showAddIbanSheet(context),
          ),

          AppGap.h28,

          // ─── Préférences ───────────────────────────────────────────────────
          Text('PRÉFÉRENCES DE VIREMENT', style: _sectionStyle(context)),
          AppGap.h10,
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.divider),
            ),
            child: Column(
              children: [
                // Auto virement
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: context.colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.autorenew_rounded, size: 20, color: context.colors.textSecondary),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Virement automatique',
                                style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text('Chaque semaine si solde ≥ seuil',
                                style: context.text.bodySmall?.copyWith(color: context.colors.textSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _autoPayoutEnabled,
                        onChanged: (v) => setState(() => _autoPayoutEnabled = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 16, color: context.colors.divider),
                // Seuil
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: context.colors.surfaceAlt,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.tune_rounded, size: 20, color: context.colors.textSecondary),
                          ),
                          AppGap.w14,
                          Expanded(
                            child: Text('Seuil minimum de retrait',
                                style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          Text(
                            '${_minPayout.toInt()} €',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                      AppGap.h10,
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                        ),
                        child: Slider(
                          value: _minPayout,
                          min: 10,
                          max: 200,
                          divisions: 19,
                          activeColor: context.colors.primary,
                          inactiveColor: context.colors.divider,
                          onChanged: (v) => setState(() => _minPayout = v),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('10 €', style: context.text.labelSmall?.copyWith(color: context.colors.textTertiary)),
                          Text('200 €', style: context.text.labelSmall?.copyWith(color: context.colors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppGap.h28,

          // ─── Info fiscale ──────────────────────────────────────────────────
          Container(
            padding: AppInsets.a16,
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: context.colors.textTertiary),
                AppGap.w12,
                Expanded(
                  child: Text(
                    'Les virements peuvent être soumis à déclaration fiscale. Conservez vos relevés pour votre déclaration de revenus.',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _sectionStyle(BuildContext context) =>
      context.text.labelSmall!.copyWith(
        color: context.colors.textTertiary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      );

  void _showAddIbanSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _IbanSheet(isEdit: false),
    );
  }

  void _showEditIbanSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: _IbanSheet(isEdit: true),
    );
  }
}

// ─── Bannière statut ──────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success.withValues(alpha: 0.12), AppColors.success.withValues(alpha: 0.04)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.success, size: 22),
          ),
          AppGap.w14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Compte actif', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.success)),
                Text('Virements activés · délai 2–3 jours',
                    style: context.text.bodySmall?.copyWith(color: AppColors.success.withValues(alpha: 0.75))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte IBAN ───────────────────────────────────────────────────────────────

class _IbanCard extends StatelessWidget {
  final VoidCallback onTap;
  const _IbanCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_rounded, color: AppColors.success, size: 22),
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('Compte principal',
                        style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    AppGap.w8,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Vérifié',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                  ]),
                  AppGap.h3,
                  Text('FR76 •••• •••• •••• 1234',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      )),
                  Text('BNP Paribas · Jean Dupont',
                      style: context.text.labelSmall?.copyWith(color: context.colors.textTertiary)),
                ],
              ),
            ),
            Icon(Icons.more_vert_rounded, color: context.colors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Bouton ajouter ───────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 20, color: context.colors.primary),
            AppGap.w8,
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.primary)),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet row ────────────────────────────────────────────────────────────────

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetRow({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color     = isDestructive ? const Color(0xFFE57373) : AppColors.snow;
    final iconColor = isDestructive ? const Color(0xFFE57373) : const Color(0xFFD5DADE);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Icon(icon, size: 21, color: iconColor),
            AppGap.w14,
            Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color))),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet IBAN ───────────────────────────────────────────────────────────────

class _IbanSheet extends StatelessWidget {
  final bool isEdit;
  const _IbanSheet({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AppSheetSurface(
        color: AppColors.snow,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppBottomSheetHandle(),
                AppGap.h20,
                Text(
                  isEdit ? 'Modifier l\'IBAN' : 'Ajouter un compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontSize.title,
                    fontWeight: FontWeight.w300,
                    color: context.colors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
                AppGap.h16,
                Divider(color: context.colors.divider, height: 1),
                AppGap.h24,
                _ShadowField(child: TextFormField(
                  style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
                  decoration: AppInputDecorations.profileField(context,
                    hintText: 'IBAN',
                    prefixIcon: const Icon(Icons.account_balance_rounded, size: 16, color: Color(0xFFB0BAC4)),
                  ),
                )),
                AppGap.h16,
                _ShadowField(child: TextFormField(
                  style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
                  decoration: AppInputDecorations.profileField(context, hintText: 'BIC / SWIFT'),
                )),
                AppGap.h16,
                _ShadowField(child: TextFormField(
                  style: TextStyle(fontSize: AppFontSize.body, color: context.colors.textPrimary),
                  decoration: AppInputDecorations.profileField(context,
                    hintText: 'Titulaire du compte',
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFFB0BAC4)),
                  ),
                )),
                AppGap.h32,
                ProfileSheetPrimaryAction(
                  label: isEdit ? 'Enregistrer' : 'Ajouter',
                  onPressed: () => Navigator.pop(context),
                ),
                AppGap.h12,
                Center(child: ProfileSheetSecondaryAction(
                  label: 'Annuler',
                  onTap: () => Navigator.pop(context),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Confirmation suppression ─────────────────────────────────────────────────

class _DeleteConfirmSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onConfirm;

  const _DeleteConfirmSheet({required this.title, required this.subtitle, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AppSheetSurface(
      color: AppColors.snow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppBottomSheetHandle(),
              AppGap.h24,
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28),
                ),
              ),
              AppGap.h16,
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFontSize.title,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              AppGap.h8,
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              AppGap.h28,
              AppButton(
                label: 'Supprimer',
                variant: ButtonVariant.destructive,
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
              ),
              AppGap.h12,
              Center(child: ProfileSheetSecondaryAction(
                label: 'Annuler',
                onTap: () => Navigator.pop(context),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShadowField extends StatelessWidget {
  final Widget child;
  const _ShadowField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
