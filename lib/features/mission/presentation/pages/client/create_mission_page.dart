import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../core/design/app_primitives.dart';
import '../../../data/models/mission.dart';
import 'create_mission/create_mission_models.dart';
import '../../mission_provider.dart';
import 'create_mission/step_service.dart';
import 'create_mission/step_datetime.dart';
import 'create_mission/step_address.dart';
import 'create_mission/step_details.dart';
import 'create_mission/step_budget_type.dart';
import 'create_mission/step_tarif.dart';
import 'create_mission/step_summary.dart';

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
    final serviceLabel = missionServices.firstWhere(
      (s) => s['id'] == _selectedService,
      orElse: () => <String, dynamic>{'name': 'Nouvelle mission'},
    )['name'] as String;
    final headerTitle = widget.mission != null
        ? (_selectedSubService ?? serviceLabel)
        : (_selectedSubService ?? (_selectedService != null ? serviceLabel : 'Nouvelle mission'));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: AppPageBody(
        useSafeAreaTop: true,
        child: Column(
          children: [
            AppFlowHeader(
              title: headerTitle,
              onBack: _previousStep,
              trailing: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.textSecondary,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Annuler'),
              ),
            ),
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
      ),
    );
  }

  Widget _buildProgressBar() {
    return AppSection(
      color: context.colors.surface,
      padding: EdgeInsets.zero,
      child: AppProgressBar(
        currentStep: _currentStep + 1,
        totalSteps: missionSteps.length,
        stepLabel: missionSteps[_currentStep],
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      ),
    );
  }

  Widget _buildBottomNav(bool isLastStep) {
    final canGo = _canContinue();

    if (isLastStep) {
      return AppActionFooter(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: AppButton(
            label: widget.mission != null &&
                    widget.mission!.status != MissionStatus.draft
                ? 'Enregistrer les modifications'
                : 'Publier la mission',
            variant: ButtonVariant.black,
            onPressed: _submitMission,
          ),
        ),
      );
    }

    return AppActionFooter(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Continuer',
              variant: ButtonVariant.black,
              onPressed: canGo ? _nextStep : null,
            ),
          ),
          AppGap.h10,
          Text(
            'Paiement securise. Aucun debit avant la fin de la mission.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: context.colors.textTertiary,
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

    Navigator.pop(context, isEdit && !isPublishingDraft ? null : 'published');
  }
}
