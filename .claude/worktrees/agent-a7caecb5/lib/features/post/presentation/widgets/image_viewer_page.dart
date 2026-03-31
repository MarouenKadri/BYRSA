import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// 📷 Inkern - Visionneuse d'images (plein écran)
/// ─────────────────────────────────────────────────────────────

class ImageViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewerPage({super.key, required this.images, required this.initialIndex});

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (_, index) => InteractiveViewer(
          child: Center(
            child: Image.network(widget.images[index], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
