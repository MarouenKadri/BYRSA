import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/design/app_design_system.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quel jour ?',
            style: GoogleFonts.inter(
              fontSize: 31,
              fontWeight: FontWeight.w600,
              height: 1.16,
              color: const Color(0xFF101418),
              letterSpacing: -0.6,
            ),
          ),
          AppGap.h12,
          Text(
            'Choisissez une date pour planifier votre mission.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: const Color(0xFFACB3BA),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: quickDates.map((date) {
              final isSelected = selectedDate?.day == date.day &&
                  selectedDate?.month == date.month &&
                  selectedDate?.year == date.year;
              final isToday = date.day == now.day && date.month == now.month;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDateSelected(date);
                    Future.delayed(const Duration(milliseconds: 150), onCompleted);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(right: date != quickDates.last ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0F1720)
                            : const Color(0xFFE9EDF0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(16, 20, 24, 0.035),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          isToday ? 'AUJ.' : _dayName(date.weekday).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.8,
                            color: const Color(0xFF98A0A8),
                          ),
                        ),
                        AppGap.h10,
                        Text(
                          '${date.day}',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF101418),
                            height: 1,
                          ),
                        ),
                        AppGap.h6,
                        Text(
                          _monthName(date.month).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.8,
                            color: const Color(0xFF98A0A8),
                          ),
                        ),
                        AppGap.h10,
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1847A8) : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          AppGap.h18,
          OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 90)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF1847A8),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Color(0xFF101418),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (date != null) {
                HapticFeedback.selectionClick();
                onDateSelected(date);
                Future.delayed(const Duration(milliseconds: 150), onCompleted);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2C3137),
              side: const BorderSide(color: Color(0xFFE4E8EC), width: 1),
              backgroundColor: Colors.transparent,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text(
              'Autre date',
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2C3137),
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
        'jan', 'fev', 'mar', 'avr', 'mai', 'juin',
        'juil', 'aout', 'sep', 'oct', 'nov', 'dec'
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
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À quelle heure ?',
            style: GoogleFonts.inter(
              fontSize: 31,
              fontWeight: FontWeight.w600,
              height: 1.16,
              color: const Color(0xFF101418),
              letterSpacing: -0.6,
            ),
          ),
          AppGap.h12,
          Text(
            'Choisissez le créneau qui vous convient le mieux.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: const Color(0xFFACB3BA),
            ),
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: quickTimes.map((time) {
              final isSelected = selectedTime?.hour == time.hour &&
                  selectedTime?.minute == time.minute;
              final isUnavailable = false;
              return Opacity(
                opacity: isUnavailable ? 0.22 : 1,
                child: GestureDetector(
                  onTap: isUnavailable
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          onTimeSelected(time);
                          Future.delayed(const Duration(milliseconds: 180), onCompleted);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0F1720)
                            : const Color(0xFFE9EDF0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(16, 20, 24, 0.03),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF1847A8)
                              : const Color(0xFF101418),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          AppGap.h18,
          OutlinedButton.icon(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF1847A8),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Color(0xFF101418),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (time != null) {
                HapticFeedback.selectionClick();
                onTimeSelected(time);
                Future.delayed(const Duration(milliseconds: 180), onCompleted);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2C3137),
              side: const BorderSide(color: Color(0xFFE4E8EC), width: 1),
              backgroundColor: Colors.transparent,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.schedule_outlined, size: 18),
            label: Text(
              'Autre heure',
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2C3137),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
