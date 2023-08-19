import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewGallery extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return PhotoViewGestureDetectorScope(
      axis: scrollDirection,
      child: PageView.builder(
        controller: pageController,
        reverse: reverse,
        allowImplicitScrolling: allowImplicitScrolling,
        scrollDirection: scrollDirection,
        physics: scrollPhysics,
        onPageChanged: onPageChanged,
        itemCount: itemCount,
        itemBuilder: builder,
      ),
    );
  }
}
