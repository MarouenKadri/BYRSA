import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/design/app_design_system.dart';
import '../../../core/design/app_primitives.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Ouvre la caméra et retourne le fichier image
  static Future<File?> pickFromCamera({int imageQuality = 80}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        preferredCameraDevice: CameraDevice.front,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Erreur caméra: $e');
    }
    return null;
  }

  /// Ouvre la galerie et retourne le fichier image
  static Future<File?> pickFromGallery({int imageQuality = 80}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Erreur galerie: $e');
    }
    return null;
  }

  /// Affiche un bottom sheet pour choisir la source
  static Future<File?> showPicker(BuildContext context) async {
    ImageSource? source = await showAppBottomSheet<ImageSource>(
      context: context,
      wrapWithSurface: false,
      builder: (ctx) => _ImagePickerSheet(
        onCameraTap: () => Navigator.pop(ctx, ImageSource.camera),
        onGalleryTap: () => Navigator.pop(ctx, ImageSource.gallery),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.camera) {
      return await pickFromCamera();
    } else {
      return await pickFromGallery();
    }
  }
}

class _ImagePickerSheet extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const _ImagePickerSheet({
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return AppDarkSheet(
      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppBottomSheetHandle(),
              AppGap.h12,
              Padding(
                padding: AppInsets.h20,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choisir une photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.snow,
                    ),
                  ),
                ),
              ),
              AppGap.h8,
              _PickerOptionTile(
                icon: Icons.photo_camera_outlined,
                title: 'Prendre une photo',
                subtitle: 'Utiliser la caméra',
                onTap: onCameraTap,
              ),
              const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0x1FFFFFFF)),
              _PickerOptionTile(
                icon: Icons.photo_library_outlined,
                title: 'Choisir depuis la galerie',
                subtitle: 'Sélectionner une photo',
                onTap: onGalleryTap,
              ),
              SizedBox(height: 12 + bottom),
            ],
      ),
    );
  }
}

class _PickerOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PickerOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            Icon(icon, size: 21, color: const Color(0xFFD5DADE)),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.snow,
                    ),
                  ),
                  AppGap.h2,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
