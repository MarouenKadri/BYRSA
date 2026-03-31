import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';

/// ─────────────────────────────────────────────────────────────
/// 🏦 Inkern - Coordonnées bancaires (Freelancer)
/// ─────────────────────────────────────────────────────────────
class FreelancerPaymentMethodsPage extends StatefulWidget {
  const FreelancerPaymentMethodsPage({super.key});

  @override
  State<FreelancerPaymentMethodsPage> createState() => _FreelancerPaymentMethodsPageState();
}

class _FreelancerPaymentMethodsPageState extends State<FreelancerPaymentMethodsPage> {
  double _minPayout = 20;
  bool _autoPayoutEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Coordonnées bancaires', style: context.profilePageTitleStyle),
      ),
      body: ListView(
        padding: AppInsets.a16,
        children: [
          // ─── Onboarding KYC ───
          AppSurfaceCard(
            padding: AppInsets.a16,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: context.colors.border),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Configuration des paiements',
                    style: context.profileSectionTitleStyle),
                AppGap.h4,
                Text('Complétez ces étapes pour recevoir vos virements',
                    style: context.profileSecondaryLabelStyle),
                AppGap.h16,
                const _OnboardingStep(
                  step: 1,
                  title: 'IBAN',
                  subtitle: 'Coordonnées bancaires',
                  isCompleted: true,
                  statusLabel: 'Vérifié',
                ),
                const _OnboardingDivider(),
                const _OnboardingStep(
                  step: 2,
                  title: 'Identité KYC',
                  subtitle: 'Vérification d\'identité',
                  isCompleted: true,
                  statusLabel: 'Vérifié',
                ),
                const _OnboardingDivider(),
                const _OnboardingStep(
                  step: 3,
                  title: 'Virements actifs',
                  subtitle: 'Prêt à recevoir des paiements',
                  isCompleted: true,
                  statusLabel: 'Actif',
                  statusColor: AppColors.success,
                ),
              ],
            ),
          ),

          AppGap.h20,

          // ─── Compte principal ───
          _SectionTitle(title: 'COMPTE BANCAIRE PRINCIPAL'),
          AppGap.h8,
          AppSurfaceCard(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.primary.withValues(alpha:0.4), width: 1.5),
            child: Column(
              children: [
                Padding(
                  padding: AppInsets.a16,
                  child: Row(
                    children: [
                      Container(
                        padding: AppInsets.a12,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha:0.08),
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: Icon(Icons.account_balance_rounded, color: AppColors.success, size: 28),
                      ),
                      AppGap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text('Compte principal',
                                  style: context.profilePrimaryLabelStyle.copyWith(fontSize: AppFontSize.lg)),
                              AppGap.w8,
                              AppTagPill(
                                label: 'Vérifié',
                                backgroundColor: AppColors.primary.withValues(alpha:0.1),
                                foregroundColor: AppColors.primary,
                                padding: AppInsets.h8v2,
                                fontSize: AppFontSize.tiny,
                                fontWeight: FontWeight.w600,
                              ),
                            ]),
                            AppGap.h4,
                            Text('FR76 •••• •••• •••• 1234',
                                style: context.profileSecondaryLabelStyle.copyWith(fontSize: AppFontSize.base)),
                            Text('BNP Paribas · Jean Dupont',
                                style: context.profileMetaStyle.copyWith(fontSize: AppFontSize.md)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded, color: context.colors.textTertiary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
                        onSelected: (v) {
                          if (v == 'edit') _showEditIbanSheet(context);
                          if (v == 'remove') _confirmRemove(context);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit',
                              child: Row(children: [Icon(Icons.edit_rounded, size: 18), AppGap.w10, Text('Modifier')])),
                          PopupMenuItem(value: 'remove',
                              child: Row(children: [const Icon(Icons.delete_rounded, size: 18, color: Colors.red), AppGap.w10,
                                Text('Supprimer', style: context.text.bodyMedium?.copyWith(color: Colors.red))])),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: context.colors.divider),
                Padding(
                  padding: AppInsets.h16v12,
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16, color: context.colors.textTertiary),
                      AppGap.w8,
                      Text('Délai de virement : 2–3 jours ouvrés',
                          style: context.profileSecondaryLabelStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppGap.h12,

          // ─── Ajouter un compte ───
          GestureDetector(
            onTap: () => _showAddIbanSheet(context),
            child: AppSurfaceCard(
              padding: AppInsets.a16,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: context.colors.border),
              child: Row(children: [
                AppSurfaceCard(
                  padding: AppInsets.a10,
                  color: context.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                  child: Icon(Icons.add_rounded, color: context.colors.textSecondary, size: 24),
                ),
                AppGap.w14,
                Text('Ajouter un compte bancaire',
                    style: context.profilePrimaryLabelStyle.copyWith(color: AppColors.primary)),
              ]),
            ),
          ),

          AppGap.h24,

          // ─── Préférences de virement ───
          _SectionTitle(title: 'PRÉFÉRENCES DE VIREMENT'),
          AppGap.h8,
          AppSurfaceCard(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: context.colors.border),
            child: Column(
              children: [
                // Retrait automatique
                Padding(
                  padding: AppInsets.h16v14,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Virement automatique',
                                style: context.profilePrimaryLabelStyle),
                            Text('Virement chaque semaine si solde ≥ seuil',
                                style: context.profileSecondaryLabelStyle),
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
                // Montant minimum
                Padding(
                  padding: AppInsets.a16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('Seuil minimum de retrait',
                            style: context.profilePrimaryLabelStyle),
                        const Spacer(),
                        Text('${_minPayout.toInt()} €',
                            style: context.profileValueStyle.copyWith(color: AppColors.primary)),
                      ]),
                      AppGap.h8,
                      Slider(
                        value: _minPayout,
                        min: 10,
                        max: 200,
                        divisions: 19,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _minPayout = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('10 €', style: context.profileMetaStyle),
                          Text('200 €', style: context.profileMetaStyle),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppGap.h24,

          // ─── Info fiscale ───
          AppSurfaceCard(
            padding: AppInsets.a16,
            color: AppColors.gold.withValues(alpha:0.08),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.gold.withValues(alpha:0.25)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 22),
                AppGap.w12,
                Expanded(
                  child: Text(
                    'Les virements peuvent être soumis à déclaration fiscale selon votre situation. Conservez vos relevés pour votre déclaration de revenus.',
                    style: context.profileSecondaryLabelStyle.copyWith(
                      color: context.colors.textPrimary,
                      height: 1.5,
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

  void _showAddIbanSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AppSheetSurface(
          padding: AppInsets.a20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSheetHeader(title: 'Ajouter un compte bancaire'),
              AppGap.h20,
              _buildInput(label: 'IBAN', hint: 'FR76 •••• •••• •••• ••••', icon: Icons.account_balance_rounded),
              AppGap.h12,
              _buildInput(label: 'BIC / SWIFT', hint: 'BNPAFRPP'),
              AppGap.h12,
              _buildInput(label: 'Titulaire du compte', hint: 'Jean Dupont'),
              AppGap.h24,
              AppButton(
                label: 'Ajouter',
                variant: ButtonVariant.primary,
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditIbanSheet(BuildContext context) => _showAddIbanSheet(context);

  void _confirmRemove(BuildContext context) {
    showAppDialog(
      context: context,
      title: const Text('Supprimer le compte ?'),
      content: const Text('Le compte bancaire FR76 •••• 1234 sera supprimé.'),
      cancelLabel: 'Annuler',
      confirmLabel: 'Supprimer',
      confirmVariant: ButtonVariant.destructive,
    );
  }

  Widget _buildInput({required String label, required String hint, IconData? icon}) {
    return TextField(
      decoration: AppInputDecorations.formField(
        context,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
      ).copyWith(
        labelText: label,
        labelStyle: context.profileSheetFieldLabelStyle,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: context.profileSheetSectionStyle.copyWith(fontWeight: FontWeight.w600));
  }
}

class _OnboardingStep extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final String statusLabel;
  final Color statusColor;

  const _OnboardingStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.statusLabel,
    this.statusColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isCompleted ? statusColor.withValues(alpha:0.1) : context.colors.surfaceAlt,
          shape: BoxShape.circle,
          border: Border.all(color: isCompleted ? statusColor : context.colors.border, width: 1.5),
        ),
        child: Center(child: isCompleted
            ? Icon(Icons.check_rounded, size: 18, color: statusColor)
            : Text('$step', style: context.profileValueStyle.copyWith(color: context.colors.textTertiary))),
      ),
      AppGap.w14,
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Étape $step · $title', style: context.profilePrimaryLabelStyle.copyWith(fontSize: AppFontSize.base)),
        Text(subtitle, style: context.profileMetaStyle),
      ])),
      AppTagPill(
        label: statusLabel,
        backgroundColor: statusColor.withValues(alpha:0.1),
        foregroundColor: statusColor,
        padding: AppInsets.h10v4,
        fontSize: AppFontSize.sm,
        fontWeight: FontWeight.w600,
      ),
    ]);
  }
}

class _OnboardingDivider extends StatelessWidget {
  const _OnboardingDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 6, bottom: 6),
      child: Container(width: 1, height: 16, color: context.colors.divider),
    );
  }
}
