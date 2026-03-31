import 'package:flutter/material.dart';
import '../../../../../app/theme/design_tokens.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sécurité',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Mot de passe ───
          _SectionCard(
            icon: Icons.lock_rounded,
            iconColor: Colors.red,
            title: 'Mot de passe',
            children: [
              _InfoRow(
                label: 'Dernier changement',
                value: 'Il y a 3 mois',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showChangePasswordSheet(context),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Changer le mot de passe'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── Authentification à deux facteurs ───
          _SectionCard(
            icon: Icons.security_rounded,
            iconColor: Colors.deepOrange,
            title: 'Authentification à deux facteurs (2FA)',
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _twoFactorEnabled ? AppColors.verifiedBg : AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _twoFactorEnabled ? Icons.check_circle_rounded : Icons.warning_rounded,
                      color: _twoFactorEnabled ? AppColors.primary : AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _twoFactorEnabled
                            ? 'Votre compte est protégé par la 2FA'
                            : 'Activez la 2FA pour plus de sécurité',
                        style: TextStyle(
                          fontSize: 13,
                          color: _twoFactorEnabled ? AppColors.primary : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                title: 'Activer la 2FA',
                subtitle: 'Recevoir un code par SMS ou email',
                value: _twoFactorEnabled,
                onChanged: (value) {
                  if (value) {
                    _showSetup2FASheet(context);
                  } else {
                    setState(() => _twoFactorEnabled = false);
                  }
                },
              ),
              if (_twoFactorEnabled) ...[
                const Divider(height: 24),
                _MethodTile(
                  icon: Icons.sms_rounded,
                  title: 'SMS',
                  subtitle: '+33 6 ** ** ** 78',
                  isActive: true,
                ),
                const SizedBox(height: 8),
                _MethodTile(
                  icon: Icons.email_rounded,
                  title: 'Email',
                  subtitle: 't.m****@email.com',
                  isActive: false,
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // ─── Biométrie ───
          _SectionCard(
            icon: Icons.fingerprint_rounded,
            iconColor: Colors.purple,
            title: 'Connexion biométrique',
            children: [
              _ToggleRow(
                title: 'Face ID / Touch ID',
                subtitle: 'Se connecter avec la biométrie',
                value: _biometricEnabled,
                onChanged: (value) => setState(() => _biometricEnabled = value),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── Appareils connectés ───
          _SectionCard(
            icon: Icons.devices_rounded,
            iconColor: Colors.cyan,
            title: 'Appareils connectés',
            children: [
              _DeviceTile(
                icon: Icons.phone_iphone_rounded,
                name: 'iPhone 14 Pro',
                location: 'Paris, France',
                lastActive: 'Actif maintenant',
                isCurrent: true,
              ),
              const SizedBox(height: 12),
              _DeviceTile(
                icon: Icons.laptop_mac_rounded,
                name: 'MacBook Pro',
                location: 'Paris, France',
                lastActive: 'Il y a 2 heures',
                isCurrent: false,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _showDisconnectAllDialog(context),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Déconnecter tous les appareils'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── Historique de connexion ───
          _SectionCard(
            icon: Icons.history_rounded,
            iconColor: AppColors.secondary,
            title: 'Historique de connexion',
            children: [
              _LoginHistoryTile(
                date: 'Aujourd\'hui, 14:32',
                location: 'Paris, France',
                device: 'iPhone 14 Pro',
                isSuccess: true,
              ),
              const Divider(height: 16),
              _LoginHistoryTile(
                date: 'Hier, 09:15',
                location: 'Paris, France',
                device: 'MacBook Pro',
                isSuccess: true,
              ),
              const Divider(height: 16),
              _LoginHistoryTile(
                date: '25 Nov, 18:42',
                location: 'Lyon, France',
                device: 'Inconnu',
                isSuccess: false,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Voir tout l\'historique'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Changer le mot de passe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: currentPasswordController,
                obscureText: obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Mot de passe actuel',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setSheetState(() => obscureCurrent = !obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setSheetState(() => obscureNew = !obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _PasswordStrengthIndicator(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Modifier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Mot de passe oublié ?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSetup2FASheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Configurer la 2FA',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez comment recevoir vos codes de vérification',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _Setup2FAOption(
              icon: Icons.sms_rounded,
              title: 'SMS',
              subtitle: 'Recevoir un code par SMS',
              onTap: () {
                Navigator.pop(context);
                setState(() => _twoFactorEnabled = true);
              },
            ),
            const SizedBox(height: 12),
            _Setup2FAOption(
              icon: Icons.email_rounded,
              title: 'Email',
              subtitle: 'Recevoir un code par email',
              onTap: () {
                Navigator.pop(context);
                setState(() => _twoFactorEnabled = true);
              },
            ),
            const SizedBox(height: 12),
            _Setup2FAOption(
              icon: Icons.security_rounded,
              title: 'Application d\'authentification',
              subtitle: 'Google Authenticator, Authy...',
              onTap: () {
                Navigator.pop(context);
                setState(() => _twoFactorEnabled = true);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showDisconnectAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnecter tous les appareils ?'),
        content: const Text(
          'Vous serez déconnecté de tous vos appareils sauf celui-ci.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Widgets auxiliaires
// ═══════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;

  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.verifiedBg : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: isActive ? Border.all(color: AppColors.primary) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Actif',
                style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String location;
  final String lastActive;
  final bool isCurrent;

  const _DeviceTile({
    required this.icon,
    required this.name,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.verifiedBg : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: isCurrent ? Border.all(color: AppColors.primary) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Cet appareil',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$location • $lastActive',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppColors.textHint,
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

class _LoginHistoryTile extends StatelessWidget {
  final String date;
  final String location;
  final String device;
  final bool isSuccess;

  const _LoginHistoryTile({
    required this.date,
    required this.location,
    required this.device,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSuccess ? AppColors.verifiedBg : AppColors.error.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuccess ? Icons.check_rounded : Icons.close_rounded,
            size: 16,
            color: isSuccess ? AppColors.primary : Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '$device • $location',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Text(
          isSuccess ? 'Réussi' : 'Échoué',
          style: TextStyle(
            fontSize: 12,
            color: isSuccess ? AppColors.primary : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _StrengthBar(isActive: true, color: Colors.red)),
            const SizedBox(width: 4),
            Expanded(child: _StrengthBar(isActive: true, color: Colors.orange)),
            const SizedBox(width: 4),
            Expanded(child: _StrengthBar(isActive: true, color: AppColors.success)),
            const SizedBox(width: 4),
            Expanded(child: _StrengthBar(isActive: false, color: AppColors.success)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Force du mot de passe : Bon',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _StrengthBar({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Setup2FAOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Setup2FAOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}