import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
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
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Mes compétences', style: context.profilePageTitleStyle),
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
              label: Text(
                'Ajouter',
                style: context.text.titleSmall,
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppInsets.a32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppInsets.a24,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.build_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            AppGap.h24,
            Text(
              'Aucune compétence',
              style: context.text.headlineMedium,
            ),
            AppGap.h8,
            Text(
              'Ajoutez vos compétences pour que les clients puissent vous trouver facilement.',
              style: context.text.bodyMedium?.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            AppGap.h24,
            AppButton(
              label: 'Ajouter une compétence',
              variant: ButtonVariant.primary,
              icon: Icons.add_rounded,
              onPressed: () => _showAddSkillSheet(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsList() {
    return ListView(
      padding: AppInsets.a16,
      children: [
        // Résumé
        _buildSummaryCard(),

        AppGap.h20,

        // Titre section
        Row(
          children: [
            Text(
              'Mes compétences',
              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '${_userSkills.length} compétence${_userSkills.length > 1 ? 's' : ''}',
              style: context.text.bodySmall,
            ),
          ],
        ),

        AppGap.h12,

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
      padding: AppInsets.a20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha:0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppInsets.a10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
              ),
              AppGap.w14,
              Expanded(
                child: Text(
                  'Votre profil de compétences',
                  style: context.text.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          AppGap.h20,
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
            style: context.text.displaySmall?.copyWith(color: Colors.white),
          ),
          AppGap.h4,
          Text(
            label,
            style: context.text.labelMedium?.copyWith(color: Colors.white.withValues(alpha:0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha:0.3),
    );
  }

  Widget _buildSkillCard(Skill skill) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditSkillSheet(skill),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: AppInsets.a16,
            child: Column(
              children: [
                Row(
                  children: [
                    // Icône
                    Container(
                      padding: AppInsets.a12,
                      decoration: BoxDecoration(
                        color: skill.level.color.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      child: Icon(skill.icon, color: skill.level.color, size: 24),
                    ),
                    AppGap.w14,

                    // Infos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.name,
                            style: context.text.titleMedium,
                          ),
                          AppGap.h4,
                          Row(
                            children: [
                              Icon(Icons.category_rounded, size: 14, color: context.colors.textTertiary),
                              AppGap.w4,
                              Text(
                                skill.category,
                                style: context.text.bodySmall,
                              ),
                              AppGap.w12,
                              Icon(Icons.schedule_rounded, size: 14, color: context.colors.textTertiary),
                              AppGap.w4,
                              Text(
                                '${skill.experienceYears} an${skill.experienceYears > 1 ? 's' : ''}',
                                style: context.text.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Badge niveau
                    Container(
                      padding: AppInsets.h10v6,
                      decoration: BoxDecoration(
                        color: skill.level.color.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text(
                        skill.level.label,
                        style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: skill.level.color),
                      ),
                    ),
                  ],
                ),

                AppGap.h12,

                // Barre de progression
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        child: LinearProgressIndicator(
                          value: skill.level.progress,
                          backgroundColor: context.colors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(skill.level.color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    AppGap.w12,
                    GestureDetector(
                      onTap: () => _showEditSkillSheet(skill),
                      child: Icon(Icons.edit_rounded, size: 18, color: context.colors.textHint),
                    ),
                    AppGap.w8,
                    GestureDetector(
                      onTap: () => _showDeleteConfirmation(skill),
                      child: Icon(Icons.delete_outline_rounded, size: 18, color: context.colors.textHint),
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
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: AppScrollableSheet(
        title: 'Ajouter une compétence',
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        trailing: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        builder: (context, scrollController) => ListView.builder(
          controller: scrollController,
          padding: AppInsets.a16,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategorySection(category);
          },
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
              padding: AppInsets.a8,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(category.icon, size: 18, color: category.color),
            ),
            AppGap.w10,
            Text(
              category.name,
              style: context.text.titleMedium,
            ),
          ],
        ),

        AppGap.h12,

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
                padding: AppInsets.h14v10,
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.divider : category.color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                  border: isSelected
                      ? null
                      : Border.all(color: category.color.withValues(alpha:0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skillName,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? context.colors.textTertiary : category.color,
                      ),
                    ),
                    if (isSelected) ...[
                      AppGap.w6,
                      Icon(Icons.check_rounded, size: 16, color: context.colors.textTertiary),
                    ] else ...[
                      AppGap.w6,
                      Icon(Icons.add_rounded, size: 16, color: category.color),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        AppGap.h20,
      ],
    );
  }

  void _showSkillConfigSheet(String skillName, SkillCategory category) {
    int selectedYears = 1;
    SkillLevel selectedLevel = SkillLevel.debutant;

    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AppFormSheet(
            title: 'Configurer la compétence',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkillSheetIdentity(
                  icon: category.icon,
                  color: category.color,
                  title: skillName,
                  subtitle: category.name,
                ),
                AppGap.h24,
                _buildYearsSelector(
                  selectedYears: selectedYears,
                  onSelected: (value) => setModalState(() => selectedYears = value),
                ),
                AppGap.h24,
                _buildLevelSelector(
                  selectedLevel: selectedLevel,
                  onSelected: (value) => setModalState(() => selectedLevel = value),
                ),
              ],
            ),
            footer: AppButton(
              label: 'Ajouter cette compétence',
              variant: ButtonVariant.primary,
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
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSkillSheet(Skill skill) {
    int selectedYears = skill.experienceYears;
    SkillLevel selectedLevel = skill.level;

    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AppFormSheet(
            title: 'Modifier la compétence',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSkillSheetIdentity(
                        icon: skill.icon,
                        color: selectedLevel.color,
                        title: skill.name,
                        subtitle: skill.category,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(skill);
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                AppGap.h24,
                _buildYearsSelector(
                  selectedYears: selectedYears,
                  onSelected: (value) => setModalState(() => selectedYears = value),
                ),
                AppGap.h24,
                _buildLevelSelector(
                  selectedLevel: selectedLevel,
                  onSelected: (value) => setModalState(() => selectedLevel = value),
                ),
              ],
            ),
            footer: AppButton(
              label: 'Enregistrer les modifications',
              variant: ButtonVariant.primary,
              onPressed: () {
                setState(() {
                  skill.experienceYears = selectedYears;
                  skill.level = selectedLevel;
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillSheetIdentity({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: AppInsets.a12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        AppGap.w14,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.headlineMedium),
              Text(subtitle, style: context.text.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYearsSelector({
    required int selectedYears,
    required ValueChanged<int> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Années d\'expérience', style: context.text.titleSmall),
        AppGap.h12,
        Row(
          children: [
            for (int i = 1; i <= 5; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(i),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                    padding: AppInsets.v12,
                    decoration: BoxDecoration(
                      color: selectedYears == i
                          ? AppColors.primary
                          : context.colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      border: selectedYears == i
                          ? null
                          : Border.all(color: context.colors.border),
                    ),
                    child: Center(
                      child: Text(
                        i == 5 ? '5+' : '$i',
                        style: context.text.titleSmall?.copyWith(
                          color: selectedYears == i
                              ? Colors.white
                              : context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelSelector({
    required SkillLevel selectedLevel,
    required ValueChanged<SkillLevel> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Niveau de maîtrise', style: context.text.titleSmall),
        AppGap.h12,
        ...SkillLevel.values.map((level) {
          final isSelected = selectedLevel == level;
          return GestureDetector(
            onTap: () => onSelected(level),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: AppInsets.a14,
              decoration: BoxDecoration(
                color: isSelected
                    ? level.color.withValues(alpha: 0.1)
                    : context.colors.background,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(
                  color: isSelected ? level.color : context.colors.border,
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
                        color: isSelected ? level.color : context.colors.textHint,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.label,
                          style: context.text.titleSmall?.copyWith(
                            color: isSelected ? level.color : null,
                          ),
                        ),
                        Text(
                          _getLevelDescription(level),
                          style: context.text.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: LinearProgressIndicator(
                        value: level.progress,
                        backgroundColor: context.colors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSelected ? level.color : context.colors.textHint,
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
      ],
    );
  }

  void _showDeleteConfirmation(Skill skill) {
    showAppDialog(
      context: context,
      title: Row(
        children: [
          Container(
            padding: AppInsets.a8,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
          ),
          AppGap.w12,
          const Expanded(child: Text('Supprimer la compétence')),
        ],
      ),
      content: Text(
        'Êtes-vous sûr de vouloir supprimer "${skill.name}" de vos compétences ?',
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Supprimer',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () {
        setState(() {
          _userSkills.removeWhere((s) => s.id == skill.id);
        });
      },
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
