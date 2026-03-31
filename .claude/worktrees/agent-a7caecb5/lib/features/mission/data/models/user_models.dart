// ─── Modèles utilisateurs ─────────────────────────────────────────────────────

/// Informations client (vue freelancer)
class ClientInfo {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int missionsCount;
  final bool isVerified;

  const ClientInfo({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.rating = 0,
    this.missionsCount = 0,
    this.isVerified = false,
  });
}

/// Informations prestataire (vue client)
class PrestaInfo {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewsCount;
  final int completedMissions;
  final bool isVerified;
  final String? acceptedPrice;

  const PrestaInfo({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.rating = 0,
    this.reviewsCount = 0,
    this.completedMissions = 0,
    this.isVerified = false,
    this.acceptedPrice,
  });
}
