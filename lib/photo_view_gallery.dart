import 'package:flutter/widgets.dart';
import 'package:photo_view/src/core/photo_view_gesture_detector.dart';

class PhotoViewGallery extends StatefulWidget {
  const PhotoViewGallery({
    super.key,
    required this.itemCount,
    required this.builder,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.allowImplicitScrolling = false,
  });

  final int itemCount;
  final IndexedWidgetBuilder builder;
  final ScrollPhysics? scrollPhysics;
  final bool reverse;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;
  final Axis scrollDirection;
  final bool allowImplicitScrolling;

  @override
  State<StatefulWidget> createState() => _PhotoViewGalleryState();
}

class _PhotoViewGalleryState extends State<PhotoViewGallery> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.pageController ?? PageController();
  }

  @override
  void didUpdateWidget(covariant PhotoViewGallery oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.pageController != oldWidget.pageController) {
      if (oldWidget.pageController == null) {
        _controller.dispose();
      }
      _controller = widget.pageController ?? PageController();
    }
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return ClipRect(
      child: widget.builder(context, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PhotoViewGestureDetectorScope(
      axis: widget.scrollDirection,
      child: PageView.builder(
        reverse: widget.reverse,
        controller: _controller,
        onPageChanged: widget.onPageChanged,
        itemCount: widget.itemCount,
        itemBuilder: _itemBuilder,
        scrollDirection: widget.scrollDirection,
        physics: widget.scrollPhysics,
        allowImplicitScrolling: widget.allowImplicitScrolling,
      ),
    );
  }
}
