import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../core/design/app_design_system.dart';
import '../../../../../../core/design/app_primitives.dart';

/// ─────────────────────────────────────────────────────────────
/// 📝 Step 4: Details (Description + Photos) - With Camera
/// ─────────────────────────────────────────────────────────────
class StepDetails extends StatefulWidget {
  final String description;
  final List<String> photos;
  final Function(String) onDescriptionChanged;
  final Function(List<String>) onPhotosChanged;

  const StepDetails({
    super.key,
    required this.description,
    required this.photos,
    required this.onDescriptionChanged,
    required this.onPhotosChanged,
  });

  @override
  State<StepDetails> createState() => _StepDetailsState();
}

class _StepDetailsState extends State<StepDetails> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.description;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Prendre une photo avec la caméra
  Future<void> _takePhoto() async {
    try {
      setState(() => _isLoading = true);
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        final newPhotos = List<String>.from(widget.photos);
        newPhotos.add(image.path);
        widget.onPhotosChanged(newPhotos);
      }
    } catch (e) {
      // error handled silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Choisir une photo depuis la galerie
  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isLoading = true);
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        final newPhotos = List<String>.from(widget.photos);
        newPhotos.add(image.path);
        widget.onPhotosChanged(newPhotos);
      }
    } catch (e) {
      // error handled silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removePhoto(int index) {
    showAppDialog(
      context: context,
      title: const Text('Supprimer la photo ?'),
      content: const Text('Cette action est irréversible.'),
      cancelLabel: 'Annuler',
      confirmLabel: 'Supprimer',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () {
        final newPhotos = List<String>.from(widget.photos);
        newPhotos.removeAt(index);
        widget.onPhotosChanged(newPhotos);
        Navigator.pop(context);
      },
    );
  }

  void _viewPhoto(String photoPath, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerPage(
          photos: widget.photos,
          initialIndex: index,
          onDelete: (idx) {
            final newPhotos = List<String>.from(widget.photos);
            newPhotos.removeAt(idx);
            widget.onPhotosChanged(newPhotos);
          },
        ),
      ),
    );
  }

  void _showAddPhotoOptions() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (sheetCtx) {
        final bottom = MediaQuery.of(sheetCtx).padding.bottom;
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
              _PhotoOptionTile(
                icon: Icons.photo_camera_outlined,
                title: 'Prendre une photo',
                subtitle: 'Utiliser la caméra',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _takePhoto();
                },
              ),
              const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0x1FFFFFFF)),
              _PhotoOptionTile(
                icon: Icons.photo_library_outlined,
                title: 'Choisir depuis la galerie',
                subtitle: 'Sélectionner une photo',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromGallery();
                },
              ),
              SizedBox(height: 12 + bottom),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Décrivez votre besoin',
                  style: TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w600,
                    height: 1.16,
                    color: AppColors.inkDark,
                    letterSpacing: -0.6,
                  ),
                ),
                AppGap.h10,
                Text(
                  'Quelques détails bien choisis aideront les freelancers à vous répondre plus précisément.',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFFACB3BA),
                  ),
                ),
                const SizedBox(height: 28),
                _buildDescriptionSection(),
                const SizedBox(height: 28),
                _buildPhotosSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DESCRIPTION',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.gray600,
            letterSpacing: 1.8,
          ),
        ),
        AppGap.h12,
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _descriptionController,
            onChanged: widget.onDescriptionChanged,
            maxLines: 6,
            maxLength: 500,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.55,
              color: AppColors.inkDark,
            ),
            decoration: AppInputDecorations.formField(
              context,
              hintText:
                  "Ex: Je recherche quelqu'un pour un menage complet de mon appartement. Merci de prevoir les zones difficiles d'acces et les surfaces fragiles.",
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: Color(0xFFB0B6BD),
              ),
              contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              noBorder: true,
              fillColor: Colors.transparent,
            ).copyWith(
              counterStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9BA3AB),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteAll() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      builder: (ctx) => AppSheetSurface(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppBottomSheetHandle(),
            AppGap.h24,
            AppSurfaceCard(
              padding: AppInsets.a16,
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 32),
            ),
            AppGap.h16,
            Text(
              'Supprimer toutes les photos ?',
              style: ctx.text.headlineSmall,
            ),
            AppGap.h8,
            Text(
              '${widget.photos.length} photo${widget.photos.length > 1 ? 's' : ''} seront supprimées.',
              style: ctx.text.bodyMedium,
            ),
            AppGap.h28,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Annuler',
                    variant: ButtonVariant.outline,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: AppButton(
                    label: 'Supprimer',
                    variant: ButtonVariant.destructive,
                    onPressed: () {
                      widget.onPhotosChanged([]);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'PHOTOS ${widget.photos.length}/10',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
                letterSpacing: 1.8,
              ),
            ),
            AppGap.w10,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE7EAEE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_border_rounded, size: 14, color: AppColors.gray600),
                  AppGap.w4,
                  Text(
                    'Conseillé',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (widget.photos.isNotEmpty)
              GestureDetector(
                onTap: _confirmDeleteAll,
                child: Text(
                  'Tout supprimer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFB75C5C),
                  ),
                ),
              ),
          ],
        ),
        AppGap.h12,
        if (_isLoading)
          _buildLoadingState()
        else if (widget.photos.isEmpty)
          _buildEmptyPhotoState()
        else
          _buildPhotoGrid(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 152,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EDF0)),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildEmptyPhotoState() {
    return GestureDetector(
      onTap: widget.photos.length < 10 ? _showAddPhotoOptions : null,
      child: Container(
        height: 156,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EDF0)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                size: 30,
                color: AppColors.gray600,
              ),
              AppGap.h12,
              Text(
                'Ajouter des photos',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkDark,
                ),
              ),
              AppGap.h4,
              Text(
                "Camera ou galerie, jusqu'a 10 images",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9BA3AB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      children: [
        SizedBox(
          height: 118,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.photos.length + (widget.photos.length < 10 ? 1 : 0),
            itemBuilder: (context, index) {
              // Add button
              if (index == 0 && widget.photos.length < 10) {
                return _buildAddPhotoButton();
              }
              
              final photoIndex = widget.photos.length < 10 ? index - 1 : index;
              return _buildPhotoThumbnail(photoIndex);
            },
          ),
        ),
        
        // Photo count indicator
        if (widget.photos.isNotEmpty) ...[
          AppGap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.photos.length > 5 ? 5 : widget.photos.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index == 0 ? AppColors.info : context.colors.border,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _showAddPhotoOptions,
      child: SizedBox(
        width: 110,
        height: 118,
        child: AppSurfaceCard(
          margin: const EdgeInsets.only(right: 10),
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EDF0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_camera_outlined, size: 28, color: AppColors.gray600),
              AppGap.h6,
              Text(
                'Ajouter',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: const Color(0xFF6E757D)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(int index) {
    final photo = widget.photos[index];
    final isLocalFile = !photo.startsWith('http');
    
    return GestureDetector(
      onTap: () => _viewPhoto(photo, index),
      child: Container(
        width: 110,
        height: 118,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              isLocalFile
                  ? Image.file(
                      File(photo),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stackTrace) {
                        return Container(
                          color: ctx.colors.divider,
                          child: Icon(Icons.broken_image, color: ctx.colors.textHint),
                        );
                      },
                    )
                  : Image.network(
                      photo,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: ctx.colors.divider,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (ctx, error, stackTrace) {
                        return Container(
                          color: ctx.colors.divider,
                          child: Icon(Icons.broken_image, color: ctx.colors.textHint),
                        );
                      },
                    ),
              
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Index badge
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: AppInsets.h8v4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Delete button
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: Container(
                    padding: AppInsets.a6,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
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

}

/// ─────────────────────────────────────────────────────────────
/// 📷 Photo Option Tile
/// ─────────────────────────────────────────────────────────────
class _PhotoOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PhotoOptionTile({
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

/// ─────────────────────────────────────────────────────────────
/// 🖼️ Photo Viewer Page (Fullscreen)
/// ─────────────────────────────────────────────────────────────
class PhotoViewerPage extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final Function(int)? onDelete;

  const PhotoViewerPage({
    super.key,
    required this.photos,
    required this.initialIndex,
    this.onDelete,
  });

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppPageAppBar(
        backgroundColor: Colors.black,
        title: '${_currentIndex + 1} / ${widget.photos.length}',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppColors.error),
              onPressed: () {
                showAppDialog(
                  context: context,
                  title: const Text('Supprimer cette photo ?'),
                  content: const SizedBox.shrink(),
                  cancelLabel: 'Annuler',
                  confirmLabel: 'Supprimer',
                  confirmVariant: ButtonVariant.destructive,
                  onConfirm: () {
                    Navigator.pop(context);
                    widget.onDelete!(_currentIndex);
                    if (widget.photos.length == 1) {
                      Navigator.pop(context);
                    } else if (_currentIndex >= widget.photos.length - 1) {
                      setState(() {
                        _currentIndex = widget.photos.length - 2;
                      });
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final photo = widget.photos[index];
          final isLocalFile = !photo.startsWith('http');
          
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: isLocalFile
                  ? Image.file(
                      File(photo),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 64, color: context.colors.textSecondary),
                            AppGap.h16,
                            Text(
                              'Impossible de charger l\'image',
                              style: context.text.bodyMedium?.copyWith(color: context.colors.textHint),
                            ),
                          ],
                        );
                      },
                    )
                  : Image.network(
                      photo,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 64, color: context.colors.textSecondary),
                            AppGap.h16,
                            Text(
                              'Impossible de charger l\'image',
                              style: context.text.bodyMedium?.copyWith(color: context.colors.textHint),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.photos.length > 1
          ? Container(
              color: Colors.black,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.photos.length,
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    final isLocalFile = !photo.startsWith('http');
                    final isSelected = index == _currentIndex;
                    
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.tag),
                          child: Opacity(
                            opacity: isSelected ? 1.0 : 0.5,
                            child: isLocalFile
                                ? Image.file(
                                    File(photo),
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    photo,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          : null,
    );
  }
}
