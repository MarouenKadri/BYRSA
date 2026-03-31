import 'package:flutter/material.dart';
import '../../../../../app/theme/design_tokens.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Coordonnées bancaires',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Onboarding KYC ───
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configuration des paiements',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Complétez ces étapes pour recevoir vos virements',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
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

          const SizedBox(height: 20),

          // ─── Compte principal ───
          _SectionTitle(title: 'COMPTE BANCAIRE PRINCIPAL'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: Icon(Icons.account_balance_rounded, color: AppColors.success, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Text('Compte principal',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.small),
                                ),
                                child: Text('Vérifié', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Text('FR76 •••• •••• •••• 1234',
                                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                            Text('BNP Paribas · Jean Dupont',
                                style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
                        onSelected: (v) {
                          if (v == 'edit') _showEditIbanSheet(context);
                          if (v == 'remove') _confirmRemove(context);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit',
                              child: Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 10), Text('Modifier')])),
                          const PopupMenuItem(value: 'remove',
                              child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: Colors.red), SizedBox(width: 10),
                                Text('Supprimer', style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 8),
                      Text('Délai de virement : 2–3 jours ouvrés',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── Ajouter un compte ───
          GestureDetector(
            onTap: () => _showAddIbanSheet(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.badge)),
                  child: Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 24),
                ),
                const SizedBox(width: 14),
                Text('Ajouter un compte bancaire',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Préférences de virement ───
          _SectionTitle(title: 'PRÉFÉRENCES DE VIREMENT'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                // Retrait automatique
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Virement automatique',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text('Virement chaque semaine si solde ≥ seuil',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
                Divider(height: 1, indent: 16, color: AppColors.divider),
                // Montant minimum
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text('Seuil minimum de retrait',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const Spacer(),
                        Text('${_minPayout.toInt()} €',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ]),
                      const SizedBox(height: 8),
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
                          Text('10 €', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                          Text('200 €', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Info fiscale ───
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Les virements peuvent être soumis à déclaration fiscale selon votre situation. Conservez vos relevés pour votre déclaration de revenus.',
                    style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              ),
              const Text('Ajouter un compte bancaire', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _buildInput(label: 'IBAN', hint: 'FR76 •••• •••• •••• ••••', icon: Icons.account_balance_rounded),
              const SizedBox(height: 12),
              _buildInput(label: 'BIC / SWIFT', hint: 'BNPAFRPP'),
              const SizedBox(height: 12),
              _buildInput(label: 'Titulaire du compte', hint: 'Jean Dupont'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
                  ),
                  child: const Text('Ajouter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        title: const Text('Supprimer le compte ?'),
        content: const Text('Le compte bancaire FR76 •••• 1234 sera supprimé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildInput({required String label, required String hint, IconData? icon}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide.none),
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
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8));
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
          color: isCompleted ? statusColor.withOpacity(0.1) : AppColors.surfaceAlt,
          shape: BoxShape.circle,
          border: Border.all(color: isCompleted ? statusColor : AppColors.border, width: 1.5),
        ),
        child: Center(child: isCompleted
            ? Icon(Icons.check_rounded, size: 18, color: statusColor)
            : Text('$step', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textTertiary))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Étape $step · $title', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
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
      child: Container(width: 1, height: 16, color: AppColors.divider),
    );
  }
}
