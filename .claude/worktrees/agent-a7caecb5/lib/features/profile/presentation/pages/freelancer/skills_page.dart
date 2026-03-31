import 'package:flutter/material.dart';
import '../../../../../app/theme/design_tokens.dart';
import '../../../data/models/skill.dart';

/// Page Mes Compétences
class MySkillsPage extends StatefulWidget {
  const MySkillsPage({super.key});

  @override
  State<MySkillsPage> createState() => _MySkillsPageState();
}

class _MySkillsPageState extends State<MySkillsPage> {
  // Compétences de l'utilisateur
  final List<Skill> _userSkills = [
    Skill(
      id: '1',
      name: 'Ménage',
      category: 'Entretien',
      icon: Icons.cleaning_services_rounded,
      experienceYears: 4,
      level: SkillLevel.expert,
    ),
    Skill(
      id: '2',
      name: 'Jardinage',
      category: 'Extérieur',
      icon: Icons.grass_rounded,
      experienceYears: 2,
      level: SkillLevel.confirme,
    ),
    Skill(
      id: '3',
      name: 'Bricolage',
      category: 'Travaux',
      icon: Icons.handyman_rounded,
      experienceYears: 3,
      level: SkillLevel.confirme,
    ),
    Skill(
      id: '4',
      name: 'Repassage',
      category: 'Entretien',
      icon: Icons.iron_rounded,
      experienceYears: 4,
      level: SkillLevel.expert,
    ),
  ];

  // Catégories de compétences disponibles
  final List<SkillCategory> _categories = const [
    SkillCategory(
      name: 'Entretien',
      icon: Icons.cleaning_services_rounded,
      color: AppColors.info,
      skills: ['Ménage', 'Repassage', 'Nettoyage vitres', 'Lavage auto'],
    ),
    SkillCategory(
      name: 'Extérieur',
      icon: Icons.grass_rounded,
      color: AppColors.success,
      skills: ['Jardinage', 'Tonte pelouse', 'Taille haies', 'Déneigement'],
    ),
    SkillCategory(
      name: 'Travaux',
      icon: Icons.handyman_rounded,
      color: Colors.orange,
      skills: ['Bricolage', 'Peinture', 'Plomberie', 'Électricité', 'Montage meubles'],
    ),
    SkillCategory(
      name: 'Aide à domicile',
      icon: Icons.favorite_rounded,
      color: Colors.pink,
      skills: ['Garde d\'enfants', 'Aide personnes âgées', 'Courses', 'Préparation repas'],
    ),
    SkillCategory(
      name: 'Déménagement',
      icon: Icons.local_shipping_rounded,
      color: Colors.purple,
      skills: ['Déménagement', 'Transport', 'Manutention', 'Emballage'],
    ),
    SkillCategory(
      name: 'Informatique',
      icon: Icons.computer_rounded,
      color: Colors.teal,
      skills: ['Dépannage PC', 'Installation', 'Formation', 'Réparation smartphone'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mes compétences',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => _showAddSkillSheet(),
          ),
        ],
      ),
      body: _userSkills.isEmpty ? _buildEmptyState() : _buildSkillsList(),
      floatingActionButton: _userSkills.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSkillSheet(),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Ajouter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.build_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune compétence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez vos compétences pour que les clients puissent vous trouver facilement.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddSkillSheet(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter une compétence'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Résumé
        _buildSummaryCard(),

        const SizedBox(height: 20),

        // Titre section
        Row(
          children: [
            const Text(
              'Mes compétences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '${_userSkills.length} compétence${_userSkills.length > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Liste des compétences
        ...List.generate(_userSkills.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSkillCard(_userSkills[index]),
          );
        }),

        const SizedBox(height: 80), // Espace pour le FAB
      ],
    );
  }

  Widget _buildSummaryCard() {
    final expertCount = _userSkills.where((s) => s.level == SkillLevel.expert).length;
    final totalYears = _userSkills.fold<int>(0, (sum, s) => sum + s.experienceYears);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Votre profil de compétences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem('${_userSkills.length}', 'Compétences'),
              _buildStatDivider(),
              _buildStatItem('$expertCount', 'Expert'),
              _buildStatDivider(),
              _buildStatItem('$totalYears', 'Ans d\'exp.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildSkillCard(Skill skill) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditSkillSheet(skill),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icône
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: skill.level.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(skill.icon, color: skill.level.color, size: 24),
                    ),
                    const SizedBox(width: 14),

                    // Infos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.category_rounded, size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                skill.category,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.schedule_rounded, size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                '${skill.experienceYears} an${skill.experienceYears > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Badge niveau
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: skill.level.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        skill.level.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: skill.level.color,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Barre de progression
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: skill.level.progress,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(skill.level.color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showEditSkillSheet(skill),
                      child: Icon(Icons.edit_rounded, size: 18, color: AppColors.textHint),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showDeleteConfirmation(skill),
                      child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textHint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSkillSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Ajouter une compétence',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Liste des catégories et compétences
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategorySection(category);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(SkillCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header catégorie
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, size: 18, color: category.color),
            ),
            const SizedBox(width: 10),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Skills de la catégorie
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: category.skills.map((skillName) {
            final isSelected = _userSkills.any((s) => s.name == skillName);
            return GestureDetector(
              onTap: isSelected
                  ? null
                  : () {
                      Navigator.pop(context);
                      _showSkillConfigSheet(skillName, category);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.divider : category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: category.color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skillName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.textTertiary : category.color,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.check_rounded, size: 16, color: AppColors.textTertiary),
                    ] else ...[
                      const SizedBox(width: 6),
                      Icon(Icons.add_rounded, size: 16, color: category.color),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  void _showSkillConfigSheet(String skillName, SkillCategory category) {
    int selectedYears = 1;
    SkillLevel selectedLevel = SkillLevel.debutant;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: category.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skillName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Années d'expérience
              const Text(
                'Années d\'expérience',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 1; i <= 5; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedYears = i),
                        child: Container(
                          margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedYears == i
                                ? AppColors.primary
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: selectedYears == i
                                ? null
                                : Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Text(
                              i == 5 ? '5+' : '$i',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: selectedYears == i
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Niveau
              const Text(
                'Niveau de maîtrise',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...SkillLevel.values.map((level) {
                final isSelected = selectedLevel == level;
                return GestureDetector(
                  onTap: () => setModalState(() => selectedLevel = level),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? level.color.withOpacity(0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? level.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? level.color : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? level.color : AppColors.textHint,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.label,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? level.color : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _getLevelDescription(level),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Mini barre de progression
                        SizedBox(
                          width: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: level.progress,
                              backgroundColor: AppColors.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isSelected ? level.color : AppColors.textHint,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Bouton ajouter
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _userSkills.add(Skill(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: skillName,
                        category: category.name,
                        icon: category.icon,
                        experienceYears: selectedYears,
                        level: selectedLevel,
                      ));
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ajouter cette compétence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSkillSheet(Skill skill) {
    int selectedYears = skill.experienceYears;
    SkillLevel selectedLevel = skill.level;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedLevel.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(skill.icon, color: selectedLevel.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          skill.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(skill);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Années d'expérience
              const Text(
                'Années d\'expérience',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 1; i <= 5; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedYears = i),
                        child: Container(
                          margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedYears == i
                                ? AppColors.primary
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: selectedYears == i
                                ? null
                                : Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Text(
                              i == 5 ? '5+' : '$i',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: selectedYears == i
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Niveau
              const Text(
                'Niveau de maîtrise',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...SkillLevel.values.map((level) {
                final isSelected = selectedLevel == level;
                return GestureDetector(
                  onTap: () => setModalState(() => selectedLevel = level),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? level.color.withOpacity(0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? level.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? level.color : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? level.color : AppColors.textHint,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.label,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? level.color : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _getLevelDescription(level),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: level.progress,
                              backgroundColor: AppColors.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isSelected ? level.color : AppColors.textHint,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Bouton sauvegarder
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      skill.experienceYears = selectedYears;
                      skill.level = selectedLevel;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer les modifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Skill skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Supprimer la compétence')),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${skill.name}" de vos compétences ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userSkills.removeWhere((s) => s.id == skill.id);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _getLevelDescription(SkillLevel level) {
    switch (level) {
      case SkillLevel.debutant:
        return 'Je débute dans ce domaine';
      case SkillLevel.intermediaire:
        return 'J\'ai des bases solides';
      case SkillLevel.confirme:
        return 'Je maîtrise bien ce domaine';
      case SkillLevel.expert:
        return 'Je suis expert dans ce domaine';
    }
  }
}