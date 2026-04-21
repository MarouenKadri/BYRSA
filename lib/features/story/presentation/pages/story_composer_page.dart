import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../core/design/app_primitives.dart';
import '../../../../features/mission/data/models/service_category.dart';
import '../../story_provider.dart';

class StoryComposerPage extends StatefulWidget {
  final File mediaFile;
  const StoryComposerPage({super.key, required this.mediaFile});

  @override
  State<StoryComposerPage> createState() => _StoryComposerPageState();
}

class _StoryComposerPageState extends State<StoryComposerPage> with SingleTickerProviderStateMixin {
  final _captionController = TextEditingController();
  late List<File> _mediaFiles;
  int _currentMediaIndex = 0;
  bool _isPosting = false;
  bool _showCaption = false;
  String? _selectedCategoryId;
  bool _didAutoOpenCategorySheet = false;
  late final AnimationController _sendController;
  late final Animation<Offset> _sendSlide;
  late final Animation<double> _sendFade;

  @override
  void initState() {
    super.initState();
    _mediaFiles = [widget.mediaFile];
    _sendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _sendSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.34, -0.24),
    ).animate(CurvedAnimation(parent: _sendController, curve: Curves.easeOutCubic));
    _sendFade = Tween<double>(begin: 1, end: 0.16).animate(
      CurvedAnimation(parent: _sendController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final preferred = _preferredCategoryId();
      if (preferred != null && _selectedCategoryId == null) {
        setState(() => _selectedCategoryId = preferred);
      }

      if (_didAutoOpenCategorySheet) return;
      _didAutoOpenCategorySheet = true;
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      await _openCategoryPicker();
    });
  }

  @override
  void dispose() {
    _sendController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_isPosting || _selectedCategoryId == null || _mediaFiles.isEmpty) return;
    HapticFeedback.lightImpact();
    await _sendController.forward(from: 0);
    if (!mounted) return;
    setState(() => _isPosting = true);

    final provider = context.read<StoryProvider>();
    var successCount = 0;
    for (final file in _mediaFiles) {
      final story = await provider.createStory(
        imageFile: file,
        caption: _captionController.text.trim(),
        serviceCategory: _selectedCategoryId ?? '',
      );
      if (story != null) successCount++;
    }

    if (!mounted) return;
    if (successCount == _mediaFiles.length) {
      Navigator.pop(context);
    } else {
      setState(() => _isPosting = false);
      showAppSnackBar(context, 'Erreur lors de la publication');
    }
  }

  Future<void> _openCategoryPicker() async {
    final selected = await showAppBottomSheet<String>(
      context: context,
      wrapWithSurface: false,
      child: _CategoryPickerSheet(selected: _selectedCategoryId),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedCategoryId = selected);
  }

  String? _preferredCategoryId() {
    final provider = context.read<StoryProvider>();
    final recent = provider.myStoryGroups;
    if (recent.isEmpty) return null;
    return recent.first.categoryId;
  }

  Future<void> _replaceMedia() async {
    if (_isPosting) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted || picked == null) return;
    setState(() => _mediaFiles[_currentMediaIndex] = File(picked.path));
  }

  Future<void> _addMoreMedia() async {
    if (_isPosting) return;
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (!mounted || picked.isEmpty) return;
    setState(() {
      _mediaFiles.addAll(picked.map((f) => File(f.path)));
      _currentMediaIndex = _mediaFiles.length - 1;
    });
  }

  void _selectMedia(int index) {
    if (_currentMediaIndex == index) return;
    setState(() => _currentMediaIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final currentMedia = _mediaFiles[_currentMediaIndex];
    final selectedCat = _selectedCategoryId != null
        ? ServiceCategory.findById(_selectedCategoryId!)
        : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(currentMedia, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    AppColors.background.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: AppStoryMetrics.composerBottomGradientHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: bottom),
                child: Column(
                  children: [
                    // ── Top bar ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _isPosting ? null : () => Navigator.pop(context),
                            splashRadius: 20,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.snow,
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          _isPosting
                              ? const SizedBox(
                                  width: AppStoryMetrics.composerLoaderSize,
                                  height: AppStoryMetrics.composerLoaderSize,
                                  child: Center(
                                    child: SizedBox(
                                      width: AppStoryMetrics.composerLoaderInnerSize,
                                      height: AppStoryMetrics.composerLoaderInnerSize,
                                      child: CircularProgressIndicator(
                                        color: AppColors.snow,
                                        strokeWidth: 2.2,
                                      ),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  onPressed: _selectedCategoryId != null ? _share : null,
                                  splashRadius: 20,
                                  icon: FadeTransition(
                                    opacity: _sendFade,
                                    child: SlideTransition(
                                      position: _sendSlide,
                                      child: Icon(
                                        Icons.send_outlined,
                                        color: _selectedCategoryId != null
                                            ? context.colors.secondary
                                            : AppColors.gray500,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // ── Category + Caption ───────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_mediaFiles.length > 1)
                            SizedBox(
                              height: 68,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _mediaFiles.length + 1,
                                separatorBuilder: (_, __) => AppGap.w8,
                                itemBuilder: (context, index) {
                                  if (index == _mediaFiles.length) {
                                    return GestureDetector(
                                      onTap: _addMoreMedia,
                                      child: Container(
                                        width: 52,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: AppColors.snow.withValues(alpha: 0.14),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: AppColors.snow.withValues(alpha: 0.72),
                                          size: 20,
                                        ),
                                      ),
                                    );
                                  }
                                  final active = index == _currentMediaIndex;
                                  return GestureDetector(
                                    onTap: () => _selectMedia(index),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      width: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: active
                                              ? context.colors.secondary
                                              : AppColors.snow.withValues(alpha: 0.10),
                                          width: active ? 1.2 : 1,
                                        ),
                                        boxShadow: active
                                            ? [
                                                BoxShadow(
                                                  color: context.colors.secondary.withValues(alpha: 0.22),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.file(
                                        _mediaFiles[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (_mediaFiles.length > 1) AppGap.h12,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: _replaceMedia,
                                style: TextButton.styleFrom(
                                  foregroundColor: context.colors.textSecondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                                  textStyle: TextStyle(
                                    fontSize: AppFontSize.smHalf,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                icon: const Icon(Icons.image_outlined, size: 16),
                                label: const Text("Modifier l'image"),
                              ),
                              AppGap.w12,
                              TextButton.icon(
                                onPressed: _addMoreMedia,
                                style: TextButton.styleFrom(
                                  foregroundColor: context.colors.textSecondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                                  textStyle: TextStyle(
                                    fontSize: AppFontSize.smHalf,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                                label: const Text('Ajouter des images'),
                              ),
                            ],
                          ),
                          AppGap.h6,
                          if (selectedCat != null) ...[
                            GestureDetector(
                              onTap: _openCategoryPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.snow.withValues(alpha: 0.34),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _storyCategoryIcon(selectedCat.id),
                                      color: AppColors.snow,
                                      size: 16,
                                    ),
                                    AppGap.w8,
                                    Text(
                                      selectedCat.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.snow,
                                      ),
                                    ),
                                    AppGap.w6,
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.snow,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AppGap.h14,
                          ],
                          _showCaption
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.snow.withValues(alpha: 0.20),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _captionController,
                                    autofocus: true,
                                    maxLines: 3,
                                    minLines: 1,
                                    maxLength: 200,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.snow,
                                      height: 1.45,
                                    ),
                                    decoration: AppInputDecorations.formField(
                                      context,
                                      hintText: 'Ajouter un commentaire...',
                                      hintStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.gray500,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      noBorder: true,
                                      fillColor: Colors.transparent,
                                    ).copyWith(
                                      isDense: true,
                                      counterStyle: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => setState(() => _showCaption = true),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors.snow.withValues(alpha: 0.16),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Ajouter un commentaire...',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category picker bottom sheet ──────────────────────────────
class _CategoryPickerSheet extends StatelessWidget {
  final String? selected;
  const _CategoryPickerSheet({this.selected});

  @override
  Widget build(BuildContext context) {
    return AppPickerSheet(
      title: "Quel talent montrez-vous aujourd'hui ?",
      dark: true,
      child: Flexible(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemCount: ServiceCategory.all.length,
          itemBuilder: (_, i) {
            final cat = ServiceCategory.all[i];
            final isSelected = selected == cat.id;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSelected ? 1 : 0.72,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, cat.id),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: isSelected ? 1.05 : 1,
                  curve: Curves.easeOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? context.colors.secondary.withValues(alpha: 0.60)
                            : Colors.transparent,
                        width: isSelected ? 1.1 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: context.colors.secondary.withValues(alpha: 0.24),
                                blurRadius: 14,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _storyCategoryIcon(cat.id),
                          size: 24,
                          color: isSelected
                              ? AppColors.snow
                              : context.colors.textSecondary,
                        ),
                        AppGap.h8,
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: AppFontSize.xsHalf,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.snow
                                : context.colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

IconData _storyCategoryIcon(String categoryId) {
  switch (categoryId) {
    case 'cleaning':
      return Icons.cleaning_services_outlined;
    case 'gardening':
      return Icons.local_florist_outlined;
    case 'plumbing':
      return Icons.plumbing_outlined;
    case 'electrical':
      return Icons.electrical_services_outlined;
    case 'moving':
      return Icons.local_shipping_outlined;
    case 'babysitting':
      return Icons.child_friendly_outlined;
    case 'pets':
      return Icons.pets_outlined;
    case 'it':
      return Icons.laptop_mac_outlined;
    default:
      return Icons.category_outlined;
  }
}
