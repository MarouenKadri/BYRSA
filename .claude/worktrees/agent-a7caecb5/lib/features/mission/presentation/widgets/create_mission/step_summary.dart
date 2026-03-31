import 'dart:io';
import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';

/// ─────────────────────────────────────────────────────────────
/// ✅ Step 6: Summary
/// ─────────────────────────────────────────────────────────────
class StepSummary extends StatelessWidget {
  final String? service;
  final String? subService;
  final DateTime? date;
  final TimeOfDay? time;
  final String address;
  final String description;
  final List<String> photos;
  final String budgetType;
  final double totalBudget;
  final double estimatedHours;
  final List<Map<String, dynamic>> services;
  final bool isEdit;

  const StepSummary({
    super.key,
    required this.service,
    required this.subService,
    required this.date,
    required this.time,
    required this.address,
    required this.description,
    required this.photos,
    required this.budgetType,
    required this.totalBudget,
    required this.estimatedHours,
    required this.services,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final serviceData = services.firstWhere(
      (s) => s['id'] == service,
      orElse: () => <String, dynamic>{'name': '', 'icon': Icons.help, 'color': Colors.grey},
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé de votre mission',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEdit ? 'Vérifiez les détails avant d\'enregistrer' : 'Vérifiez les détails avant de publier',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Mission card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Service header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (serviceData['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        serviceData['icon'] as IconData,
                        size: 28,
                        color: serviceData['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceData['name'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (subService != null)
                            Text(
                              subService!,
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
                
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                
                // Details
                SummaryRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: date != null 
                      ? '${_getDayName(date!.weekday)} ${date!.day} ${_getMonthName(date!.month)}'
                      : '-',
                ),
                const SizedBox(height: 14),
                SummaryRow(
                  icon: Icons.access_time_rounded,
                  label: 'Heure',
                  value: time != null 
                      ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
                      : '-',
                ),
                const SizedBox(height: 14),
                SummaryRow(
                  icon: Icons.location_on_rounded,
                  label: 'Adresse',
                  value: address.isNotEmpty ? address : '-',
                ),
                
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SummaryRow(
                    icon: Icons.description_rounded,
                    label: 'Description',
                    value: description,
                  ),
                ],
                
                if (photos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.photo_library_rounded, size: 20, color: AppColors.textTertiary),
                      const SizedBox(width: 12),
                      Text(
                        '${photos.length} photo${photos.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        final isLocalFile = !photo.startsWith('http');
                        
                        return Container(
                          width: 70,
                          margin: EdgeInsets.only(right: index < photos.length - 1 ? 8 : 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: isLocalFile
                                ? Image.file(
                                    File(photo),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.divider,
                                        child: Icon(Icons.broken_image, 
                                          color: AppColors.textHint, 
                                          size: 24,
                                        ),
                                      );
                                    },
                                  )
                                : Image.network(
                                    photo,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: AppColors.divider,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.divider,
                                        child: Icon(Icons.broken_image, 
                                          color: AppColors.textHint, 
                                          size: 24,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                
                // Budget
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budgetType == 'hourly' 
                              ? 'Budget estimé'
                              : budgetType == 'fixed' 
                                  ? 'Budget fixe'
                                  : 'Sur devis',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (budgetType == 'hourly')
                          Text(
                            '${estimatedHours.toStringAsFixed(estimatedHours.truncateToDouble() == estimatedHours ? 0 : 1)} heures estimées',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    if (budgetType != 'quote')
                      Text(
                        '${totalBudget.round()}€',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Sur devis',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 22, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEdit
                        ? 'Vos modifications seront visibles immédiatement par les freelancers.'
                        : 'Vous pourrez discuter avec les freelancers intéressés avant de faire votre choix.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.info,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return months[month - 1];
  }
}

/// ─────────────────────────────────────────────────────────────
/// 📋 Widget ligne de résumé
/// ─────────────────────────────────────────────────────────────
class SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}