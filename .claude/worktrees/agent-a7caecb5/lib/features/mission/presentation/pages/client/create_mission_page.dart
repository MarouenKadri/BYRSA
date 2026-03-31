import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../theme/design_tokens.dart';
import '../../../data/models/mission.dart';
import '../../../data/models/create_mission_models.dart';
import '../../../mission_provider.dart';
import '../../widgets/create_mission/step_service.dart';
import '../../widgets/create_mission/step_datetime.dart';
import '../../widgets/create_mission/step_address.dart';
import '../../widgets/create_mission/step_details.dart';
import '../../widgets/create_mission/step_budget_type.dart';
import '../../widgets/create_mission/step_tarif.dart';
import '../../widgets/create_mission/step_summary.dart';

/// ─────────────────────────────────────────────────────────────
/// 📝 Post Mission Flow — style BlaBlaCar
///    8 pages séparées, flèche → en bas à droite
/// ─────────────────────────────────────────────────────────────
class PostMissionFlow extends StatefulWidget {
  final Mission? mission;
  const PostMissionFlow({super.key, this.mission});

  @override
  State<PostMissionFlow> createState() => _PostMissionFlowState();
}

class _PostMissionFlowState extends State<PostMissionFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _submitted = false;
  MissionProvider? _providerRef;

  // Données du formulaire
  String? _selectedService;
  String? _selectedSubService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _address = '';
  String _description = '';
  List<String> _photos = [];
  String _budgetType = '';
  double _hourlyRate = 0;
  double _estimatedHours = 2;
  double _fixedBudget = 0;

  // ─── Step indices ────────────────────────────────────────
  static const int _kService    = 0;
  static const int _kDate       = 1;
  static const int _kTime       = 2;
  static const int _kAddress    = 3;
  static const int _kDetails    = 4;
  static const int _kBudgetType = 5;
  static const int _kTarif      = 6;
  static const int _kSummary    = 7;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _providerRef = Provider.of<MissionProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    final m = widget.mission;
    if (m == null) return;
    _selectedService = m.categoryId;
    _selectedSubService = m.title;
    _selectedDate = m.date;
    _selectedTime = _parseTimeSlot(m.timeSlot);
    _address = m.address.fullAddress;
    _description = m.description;
    _photos = List<String>.from(m.images);
    switch (m.budget.type) {
      case BudgetType.hourly:
        _budgetType = CreateBudgetType.hourly;
        _hourlyRate = m.budget.amount ?? 0;
        _estimatedHours = m.budget.estimatedHours ?? 2;
      case BudgetType.fixed:
        _budgetType = CreateBudgetType.fixed;
        _fixedBudget = m.budget.amount ?? 0;
      case BudgetType.quote:
        _budgetType = CreateBudgetType.quote;
    }
  }

  @override
  void dispose() {
    _saveDraftIfNeeded();
    _pageController.dispose();
    super.dispose();
  }

  void _saveDraftIfNeeded() {
    if (_submitted || widget.mission != null || _selectedService == null) return;
    final now = DateTime.now();
    final budget = _buildBudget();
    final serviceLabel = missionServices.firstWhere(
      (s) => s['id'] == _selectedService,
      orElse: () => <String, dynamic>{'name': _selectedService ?? 'Service'},
    )['name'] as String;

    final draft = Mission(
      id: const Uuid().v4(),
      title: _selectedSubService ?? serviceLabel,
      description: _description,
      categoryId: _selectedService!,
      date: _selectedDate ?? now.add(const Duration(days: 1)),
      timeSlot: _formatTimeSlot(_selectedTime),
      address: _address.isNotEmpty
          ? MissionAddress(
              fullAddress: _address,
              shortAddress: _address.contains(',')
                  ? _address.split(',').first.trim()
                  : _address,
            )
          : const MissionAddress(fullAddress: 'Non renseignée', shortAddress: ''),
      budget: budget,
      status: MissionStatus.draft,
      images: List<String>.from(_photos),
      createdAt: now,
      candidatesCount: 0,
    );
    _providerRef?.saveDraft(draft);
  }

  TimeOfDay? _parseTimeSlot(String timeSlot) {
    if (timeSlot.isEmpty) return null;
    final part = timeSlot.split(' - ').first.trim();
    final segments = part.split('h');
    if (segments.length < 2) return null;
    final h = int.tryParse(segments[0]);
    final min = int.tryParse(segments[1]);
    if (h == null) return null;
    return TimeOfDay(hour: h, minute: min ?? 0);
  }

  String _formatTimeSlot(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}h${time.minute.toString().padLeft(2, '0')}';
  }

  BudgetInfo _buildBudget() {
    if (_budgetType == CreateBudgetType.fixed) {
      return BudgetInfo(type: BudgetType.fixed, amount: _fixedBudget);
    } else if (_budgetType == CreateBudgetType.hourly) {
      return BudgetInfo(
          type: BudgetType.hourly,
          amount: _hourlyRate,
          estimatedHours: _estimatedHours);
    }
    return const BudgetInfo(type: BudgetType.quote);
  }

  double get _totalBudget {
    if (_budgetType == CreateBudgetType.hourly) return _hourlyRate * _estimatedHours;
    if (_budgetType == CreateBudgetType.fixed) return _fixedBudget;
    return 0;
  }

  // ─── Navigation ─────────────────────────────────────────
  void _nextStep() {
    final next = _currentStep + 1;
    if (next < missionSteps.length) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = next);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      final prev = _currentStep - 1;
      _pageController.animateToPage(
        prev,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = prev);
    } else {
      Navigator.pop(context);
    }
  }

  bool _canContinue() {
    switch (_currentStep) {
      case _kService:
        return _selectedService != null;
      case _kDate:
        return _selectedDate != null;
      case _kTime:
        return _selectedTime != null;
      case _kAddress:
        return _address.isNotEmpty;
      case _kDetails:
        return true;
      case _kBudgetType:
        return _budgetType.isNotEmpty;
      case _kTarif:
        if (_budgetType == CreateBudgetType.hourly) {
          return _hourlyRate > 0 && _estimatedHours > 0;
        }
        if (_budgetType == CreateBudgetType.fixed) return _fixedBudget > 0;
        return true;
      default:
        return true;
    }
  }

  // ─── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == missionSteps.length - 1;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // 0 — Service
                StepService(
                  services: missionServices,
                  selectedService: _selectedService,
                  selectedSubService: _selectedSubService,
                  onServiceSelected: (service, sub) {
                    setState(() {
                      _selectedService = service;
                      _selectedSubService = sub;
                    });
                  },
                  onCompleted: _nextStep,
                ),
                // 1 — Date
                StepDate(
                  selectedDate: _selectedDate,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                  onCompleted: _nextStep,
                ),
                // 2 — Heure
                StepTime(
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  onTimeSelected: (t) => setState(() => _selectedTime = t),
                  onCompleted: _nextStep,
                ),
                // 3 — Adresse
                StepAddress(
                  address: _address,
                  onAddressChanged: (v) => setState(() => _address = v),
                ),
                // 4 — Détails
                StepDetails(
                  description: _description,
                  photos: _photos,
                  onDescriptionChanged: (v) =>
                      setState(() => _description = v),
                  onPhotosChanged: (p) => setState(() => _photos = p),
                ),
                // 5 — Type de budget
                StepBudgetType(
                  budgetType: _budgetType,
                  onBudgetTypeChanged: (t) =>
                      setState(() => _budgetType = t),
                  onCompleted: _nextStep,
                ),
                // 6 — Tarif
                StepTarif(
                  budgetType: _budgetType,
                  hourlyRate: _hourlyRate,
                  estimatedHours: _estimatedHours,
                  fixedBudget: _fixedBudget,
                  onHourlyRateChanged: (r) =>
                      setState(() => _hourlyRate = r),
                  onEstimatedHoursChanged: (h) =>
                      setState(() => _estimatedHours = h),
                  onFixedBudgetChanged: (b) =>
                      setState(() => _fixedBudget = b),
                ),
                // 7 — Récapitulatif
                StepSummary(
                  service: _selectedService,
                  subService: _selectedSubService,
                  date: _selectedDate,
                  time: _selectedTime,
                  address: _address,
                  description: _description,
                  photos: _photos,
                  budgetType: _budgetType,
                  totalBudget: _totalBudget,
                  estimatedHours: _estimatedHours,
                  services: missionServices,
                  isEdit: widget.mission != null,
                ),
              ],
            ),
          ),
          _buildBottomNav(isLastStep),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: _previousStep,
      ),
      title: Text(
        widget.mission != null ? 'Modifier la mission' : 'Nouvelle mission',
        style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          Row(
            children: List.generate(missionSteps.length, (i) {
              final done = i < _currentStep;
              final current = i == _currentStep;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 3),
                  height: 4,
                  decoration: BoxDecoration(
                    color: done || current
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                missionSteps[_currentStep],
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
              Text(
                '${_currentStep + 1} / ${missionSteps.length}',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isLastStep) {
    final padding = MediaQuery.of(context).padding;
    final canGo = _canContinue();

    if (isLastStep) {
      // Dernière page : bouton plein "Publier"
      return Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitMission,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              widget.mission != null &&
                      widget.mission!.status != MissionStatus.draft
                  ? 'Enregistrer les modifications'
                  : 'Publier la mission',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    // Autres pages : flèche → à droite
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 12 + padding.bottom),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: canGo ? _nextStep : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: canGo ? AppColors.primary : AppColors.border,
                shape: BoxShape.circle,
                boxShadow: canGo
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        )
                      ]
                    : [],
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  void _submitMission() {
    final isEdit = widget.mission != null;
    final original = widget.mission;
    final isPublishingDraft =
        isEdit && original!.status == MissionStatus.draft;
    final now = DateTime.now();

    final budget = _buildBudget();
    final serviceLabel = missionServices
        .firstWhere((s) => s['id'] == _selectedService,
            orElse: () =>
                <String, dynamic>{'name': _selectedService ?? 'Service'})
        ['name'] as String;

    final mission = Mission(
      id: isEdit ? original!.id : const Uuid().v4(),
      title: _selectedSubService ?? serviceLabel,
      description: _description.isNotEmpty
          ? _description
          : 'Mission créée via l\'application.',
      categoryId: _selectedService ?? 'menage',
      date: _selectedDate ?? now.add(const Duration(days: 1)),
      timeSlot: _formatTimeSlot(_selectedTime),
      address: MissionAddress(
        fullAddress: _address,
        shortAddress: _address.contains(',')
            ? _address.split(',').first.trim()
            : _address,
      ),
      budget: budget,
      status: (isEdit && !isPublishingDraft)
          ? original!.status
          : MissionStatus.waitingCandidates,
      images: List<String>.from(_photos),
      createdAt: isEdit ? original!.createdAt : now,
      candidatesCount: isEdit ? original!.candidatesCount : 0,
      client: isEdit ? original!.client : null,
      assignedPresta: isEdit ? original!.assignedPresta : null,
      rating: isEdit ? original!.rating : null,
    );

    _submitted = true;
    if (isPublishingDraft) {
      context.read<MissionProvider>().publishDraft(mission);
    } else if (isEdit) {
      context.read<MissionProvider>().updateMission(mission);
    } else {
      context.read<MissionProvider>().publishMission(mission);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              (isEdit && !isPublishingDraft)
                  ? 'Mission modifiée !'
                  : 'Mission publiée !',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              (isEdit && !isPublishingDraft)
                  ? 'Vos modifications ont bien été enregistrées.'
                  : 'Votre mission est visible par les freelancers. Vous recevrez des propositions très bientôt.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // ferme dialog
                  Navigator.pop(context, isEdit && !isPublishingDraft ? null : 'published');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  (isEdit && !isPublishingDraft)
                      ? 'Voir mes modifications'
                      : 'Voir ma mission',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
