import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';

/// ─────────────────────────────────────────────────────────────
/// 📅 Step 2 — Date uniquement
/// ─────────────────────────────────────────────────────────────
class StepDate extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback onCompleted;

  const StepDate({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final quickDates = [
      now,
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 2)),
      now.add(const Duration(days: 3)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quel jour ?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Touchez une date pour continuer',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),

          // Cartes jours rapides
          Row(
            children: quickDates.map((date) {
              final isSelected = selectedDate?.day == date.day &&
                  selectedDate?.month == date.month &&
                  selectedDate?.year == date.year;
              final isToday = date.day == now.day && date.month == now.month;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    onDateSelected(date);
                    Future.delayed(const Duration(milliseconds: 150), onCompleted);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: date != quickDates.last ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Text(
                          isToday ? 'Auj.' : _dayName(date.weekday),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _monthName(date.month),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Autre date
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 90)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (date != null) {
                onDateSelected(date);
                Future.delayed(const Duration(milliseconds: 150), onCompleted);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Autre date',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  String _dayName(int w) =>
      ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][w - 1];
  String _monthName(int m) => [
        'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
        'juil', 'août', 'sep', 'oct', 'nov', 'déc'
      ][m - 1];
}

/// ─────────────────────────────────────────────────────────────
/// ⏰ Step 3 — Heure uniquement
/// ─────────────────────────────────────────────────────────────
class StepTime extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;
  final VoidCallback onCompleted;

  const StepTime({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onTimeSelected,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final quickTimes = [
      const TimeOfDay(hour: 7, minute: 0),
      const TimeOfDay(hour: 8, minute: 0),
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
      const TimeOfDay(hour: 19, minute: 0),
      const TimeOfDay(hour: 20, minute: 0),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'À quelle heure ?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Touchez un créneau pour continuer',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // Grille créneaux
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: quickTimes.map((time) {
              final isSelected = selectedTime?.hour == time.hour &&
                  selectedTime?.minute == time.minute;
              return GestureDetector(
                onTap: () {
                  onTimeSelected(time);
                  Future.delayed(
                      const Duration(milliseconds: 200), onCompleted);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Autre heure
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (time != null) {
                onTimeSelected(time);
                Future.delayed(
                    const Duration(milliseconds: 200), onCompleted);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Autre heure',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

}
