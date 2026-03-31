import 'package:flutter/material.dart';
import '../../../../core/design/app_design_system.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🏷️ Inkern - Catégories de Services
/// ═══════════════════════════════════════════════════════════════════════════

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> subServices;
  final List<String> popularTags;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.description = '',
    this.subServices = const [],
    this.popularTags = const [],
  });

  static const List<ServiceCategory> all = [
    menage, jardinage, bricolage, plomberie, electricite, demenagement, petsitting, cours,
  ];

  static const ServiceCategory menage = ServiceCategory(
    id: 'menage', name: 'Ménage', icon: Icons.cleaning_services_rounded, color: Color(0xFF4CAF50),
    description: 'Services de nettoyage et entretien de la maison',
    subServices: ['Ménage complet', 'Nettoyage cuisine', 'Nettoyage salle de bain', 'Vitres', 'Repassage', 'Nettoyage fin de chantier', 'Nettoyage après déménagement'],
    popularTags: ['régulier', 'ponctuel', 'produits fournis', 'écologique'],
  );

  static const ServiceCategory jardinage = ServiceCategory(
    id: 'jardinage', name: 'Jardinage', icon: Icons.grass_rounded, color: Color(0xFF8BC34A),
    description: 'Entretien de jardins, terrasses et espaces verts',
    subServices: ['Tonte pelouse', 'Taille haies', 'Désherbage', 'Plantation', 'Élagage', 'Arrosage', 'Entretien potager', 'Évacuation déchets verts'],
    popularTags: ['petit jardin', 'grand terrain', 'outils fournis', 'régulier'],
  );

  static const ServiceCategory bricolage = ServiceCategory(
    id: 'bricolage', name: 'Bricolage', icon: Icons.handyman_rounded, color: Color(0xFFFF9800),
    description: 'Petits travaux et réparations diverses',
    subServices: ['Montage meubles', 'Petites réparations', 'Peinture', 'Pose étagères', 'Fixations murales', 'Pose rideaux/stores', 'Petite menuiserie'],
    popularTags: ['IKEA', 'rapide', 'outillage complet'],
  );

  static const ServiceCategory plomberie = ServiceCategory(
    id: 'plomberie', name: 'Plomberie', icon: Icons.plumbing_rounded, color: Color(0xFF2196F3),
    description: 'Réparations et installations sanitaires',
    subServices: ['Fuite d\'eau', 'Débouchage', 'Installation robinet', 'Réparation WC', 'Chauffe-eau', 'Raccordement', 'Remplacement joints'],
    popularTags: ['urgence', 'devis gratuit', 'garantie'],
  );

  static const ServiceCategory electricite = ServiceCategory(
    id: 'electricite', name: 'Électricité', icon: Icons.electrical_services_rounded, color: Color(0xFFFFC107),
    description: 'Installations et dépannages électriques',
    subServices: ['Prise électrique', 'Interrupteur', 'Luminaire', 'Dépannage', 'Tableau électrique', 'Mise aux normes', 'Installation domotique'],
    popularTags: ['certifié', 'mise aux normes', 'urgence'],
  );

  static const ServiceCategory demenagement = ServiceCategory(
    id: 'demenagement', name: 'Déménagement', icon: Icons.local_shipping_rounded, color: Color(0xFF9C27B0),
    description: 'Aide au déménagement et transport',
    subServices: ['Aide déménagement', 'Transport meubles', 'Emballage', 'Montage/démontage', 'Portage', 'Location camion avec chauffeur'],
    popularTags: ['petit volume', 'grand volume', 'avec véhicule', 'muscles'],
  );

  static const ServiceCategory petsitting = ServiceCategory(
    id: 'petsitting', name: 'Pet-sitting', icon: Icons.pets_rounded, color: Color(0xFFE91E63),
    description: 'Garde et promenade d\'animaux de compagnie',
    subServices: ['Garde chien', 'Garde chat', 'Promenade', 'Visite à domicile', 'Garde NAC', 'Garde longue durée'],
    popularTags: ['expérimenté', 'à domicile', 'chez le pet-sitter'],
  );

  static const ServiceCategory cours = ServiceCategory(
    id: 'cours', name: 'Cours', icon: Icons.school_rounded, color: Color(0xFF3F51B5),
    description: 'Cours particuliers et soutien scolaire',
    subServices: ['Mathématiques', 'Français', 'Anglais', 'Physique-Chimie', 'SVT', 'Musique', 'Informatique', 'Langues étrangères'],
    popularTags: ['primaire', 'collège', 'lycée', 'supérieur', 'adulte'],
  );

  static ServiceCategory? findById(String id) {
    try { return all.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }

  static ServiceCategory? findByName(String name) {
    try { return all.firstWhere((c) => c.name.toLowerCase() == name.toLowerCase()); } catch (_) { return null; }
  }

  static List<ServiceCategory> search(String query) {
    final lowerQuery = query.toLowerCase();
    return all.where((cat) {
      if (cat.name.toLowerCase().contains(lowerQuery)) return true;
      if (cat.description.toLowerCase().contains(lowerQuery)) return true;
      return cat.subServices.any((s) => s.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  static List<ServiceCategory> get popular => [menage, bricolage, jardinage, plomberie];

  static Map<String, List<ServiceCategory>> get byColorGroup => {
    'green': [menage, jardinage],
    'orange': [bricolage, electricite],
    'blue': [plomberie, cours],
    'purple': [demenagement, petsitting],
  };
}

extension ServiceCategoryX on ServiceCategory {
  Color themedColor(BuildContext context) =>
      context.isIndeedTheme ? context.colors.primary : color;

  Color get lightColor => color.withOpacity(0.1);
  Color get mediumColor => color.withOpacity(0.3);
}
