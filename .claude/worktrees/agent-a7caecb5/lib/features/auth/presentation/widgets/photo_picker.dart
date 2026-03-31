import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../services/image_picker_service.dart';

class PhotoPicker extends StatelessWidget {
  final File? photo;
  final double size;
  final bool isCircle;
  final Function(File?) onPhotoChanged;
  final String? placeholder;

  const PhotoPicker({
    super.key,
    this.photo,
    this.size = 160,
    this.isCircle = true,
    required this.onPhotoChanged,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickPhoto(context),
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  isCircle ? null : BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: photo != null ? AppColors.primary : AppColors.border,
                width: 2.5,
              ),
              image: photo != null
                  ? DecorationImage(
                      image: FileImage(photo!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photo == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCircle
                            ? Icons.person_rounded
                            : Icons.add_photo_alternate_rounded,
                        size: size * 0.38,
                        color: AppColors.textHint,
                      ),
                      if (placeholder != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          placeholder!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  )
                : null,
          ),

          // ─── Badge caméra ───
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: Icon(
                photo != null ? Icons.edit_rounded : Icons.camera_alt_rounded,
                color: Colors.white,
                size: size * 0.11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final file = await ImagePickerService.showPicker(context);
    if (file != null) {
      onPhotoChanged(file);
    }
  }
}

/// Widget compact pour afficher la photo avec option de suppression
class PhotoPreview extends StatelessWidget {
  final File photo;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  final double size;

  const PhotoPreview({
    super.key,
    required this.photo,
    required this.onRemove,
    required this.onEdit,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.primary, width: 2),
              image: DecorationImage(
                image: FileImage(photo),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
