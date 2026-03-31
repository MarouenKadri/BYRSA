import 'post.dart';

/// ─────────────────────────────────────────────────────────────
/// 📦 Inkern - Données de démonstration (Posts)
/// ─────────────────────────────────────────────────────────────

class PostDemoData {
  static List<Post> getDemoPosts() => [
    Post(
      id: '1',
      authorId: 'user1',
      authorName: 'Thomas Martin',
      authorAvatar: 'https://i.pravatar.cc/150?img=3',
      authorBadge: 'Ambassadeur',
      content: 'Nouvelle réalisation ! 🎨 Rénovation complète d\'une cuisine dans le 11ème arrondissement. Peinture, pose de crédence et installation des meubles. Le client est ravi du résultat !',
      images: [
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600',
        'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=600',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      upvotes: 24, downvotes: 1, userVote: 0, isOwner: false,
    ),
    Post(
      id: '2',
      authorId: 'user2',
      authorName: 'Sophie Laurent',
      authorAvatar: 'https://i.pravatar.cc/150?img=23',
      authorBadge: 'Expert',
      content: 'Entretien de jardin terminé ! 🌿 Taille des haies, tonte de pelouse et désherbage. Prêt pour le printemps ! N\'hésitez pas à me contacter pour vos espaces verts.',
      images: ['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      upvotes: 18, downvotes: 0, userVote: 1, isOwner: true,
    ),
    Post(
      id: '3',
      authorId: 'user3',
      authorName: 'Marc Dubois',
      authorAvatar: 'https://i.pravatar.cc/150?img=12',
      authorBadge: 'Pro',
      content: 'Installation électrique complète dans un appartement neuf. Tableau électrique aux normes, prises et interrupteurs design. La sécurité avant tout ! ⚡',
      images: [
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600',
        'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=600',
        'https://images.unsplash.com/photo-1545259742-b4fd8fea67e4?w=600',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      upvotes: 42, downvotes: 2, userVote: 0, isOwner: false,
    ),
    Post(
      id: '4',
      authorId: 'user4',
      authorName: 'Emma Bernard',
      authorAvatar: 'https://i.pravatar.cc/150?img=45',
      authorBadge: 'Ambassadeur',
      content: 'Grand ménage de printemps dans une maison de 150m² ! 🧹✨ Nettoyage en profondeur, vitres impeccables et repassage du linge. Satisfaite de voir cette maison briller !',
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      upvotes: 31, downvotes: 0, userVote: 0, isOwner: false,
    ),
  ];
}
