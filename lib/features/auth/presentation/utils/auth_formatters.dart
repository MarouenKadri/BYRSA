// Fonctions utilitaires de masquage partagées dans le module auth.

String maskEmail(String email) {
  if (!email.contains('@')) return email;
  final parts = email.split('@');
  final name = parts[0];
  final domain = parts[1];
  if (name.length <= 2) return email;
  return '${name.substring(0, 2)}${'•' * (name.length - 2)}@$domain';
}

String maskPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length < 4) return phone;
  return '+33 ${digits.substring(0, 2)} •• •• •• ${digits.substring(digits.length - 2)}';
}
