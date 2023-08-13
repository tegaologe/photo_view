import 'package:flutter/material.dart';
import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/core/photo_view_core.dart';
import 'package:photo_view/src/photo_view_computed_scale.dart';
import 'package:photo_view/src/photo_view_image.dart';
import 'package:photo_view/src/utils/photo_view_hero_attributes.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';

export 'src/controller/photo_view_controller.dart';
export 'src/core/photo_view_gesture_detector.dart'
    show PhotoViewGestureDetectorScope;
export 'src/photo_view_computed_scale.dart';
export 'src/utils/photo_view_hero_attributes.dart';

typedef PhotoViewImageLoadingBuilder = Widget Function(
  BuildContext context,
  ImageChunkEvent? event,
);

Widget _defaultLoadingBuilder(_, __) => const SizedBox();
Widget _defaultErrorBuilder(_, __, ___) => const SizedBox();

class PhotoViewDecoration {
  const PhotoViewDecoration({
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.heroAttributes,
    this.backgroundDecoration = const BoxDecoration(color: Color(0xff000000)),
    this.gestureDetectorBehavior = HitTestBehavior.deferToChild,
    this.basePosition = Alignment.center,
    this.filterQuality = FilterQuality.none,
    this.wantKeepAlive = false,
    this.enableRotation = false,
    this.tightMode = false,
    this.disableGestures = false,
    this.enablePanAlways = false,
    this.strictScale = false,
  });

  final GestureTapUpCallback? onTapUp;
  final GestureTapDownCallback? onTapDown;
  final GestureScaleEndCallback? onScaleEnd;

  final PhotoViewHeroAttributes? heroAttributes;
  final BoxDecoration backgroundDecoration;
  final HitTestBehavior gestureDetectorBehavior;
  final Alignment basePosition;
  final FilterQuality filterQuality;
  final bool wantKeepAlive;
  final bool enableRotation;
  final bool tightMode;
  final bool disableGestures;
  final bool enablePanAlways;

  /// Restricts the scale to the max and mix scale values when enabled.
  final bool strictScale;
}

class PhotoView extends StatefulWidget {
  const PhotoView({
    super.key,
    required ImageProvider this.imageProvider,
    PhotoViewImageLoadingBuilder this.loadingBuilder = _defaultLoadingBuilder,
    ImageErrorWidgetBuilder this.errorBuilder = _defaultErrorBuilder,
    this.semanticLabel,
    this.gaplessPlayback = false,
    this.controller,
    this.decoration = const PhotoViewDecoration(),
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.customSize,
  })  : child = null,
        childSize = null;

  const PhotoView.custom({
    super.key,
    required Widget this.child,
    this.childSize,
    this.controller,
    this.decoration = const PhotoViewDecoration(),
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.customSize,
  })  : errorBuilder = null,
        imageProvider = null,
        semanticLabel = null,
        gaplessPlayback = false,
        loadingBuilder = null;

  final ImageProvider? imageProvider;
  final PhotoViewImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final String? semanticLabel;

  /// When enabled, changing the [imageProvider] will cause the existing image
  /// to keep showing until the new image provider provides a different image.
  final bool gaplessPlayback;

  final Widget? child;

  /// The size of the custom [child]. [PhotoView] uses this value to compute the
  /// relation between the child and the container's size to calculate the scale
  /// value.
  final Size? childSize;

  final PhotoViewController? controller;
  final PhotoViewDecoration decoration;

  /// Defines the minimum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double
  /// (absolute value) or a [PhotoViewComputedScale], that can be multiplied by
  /// a double
  final dynamic minScale;

  /// Defines the maximum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double
  /// (absolute value) or a [PhotoViewComputedScale], that can be multiplied by
  /// a double
  final dynamic maxScale;

  /// Defines the initial size in which the image will be assume in the mounting
  /// of the component, it is proportional to the original image size. Can be
  /// either a double (absolute value) or a [PhotoViewComputedScale], that can
  /// be multiplied by a double
  final dynamic initialScale;

  final Size? customSize;

  @override
  State<StatefulWidget> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView>
    with AutomaticKeepAliveClientMixin {
  late PhotoViewController _controller;

  @override
  bool get wantKeepAlive => widget.decoration.wantKeepAlive;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? PhotoViewController();
  }

  @override
  void didUpdateWidget(PhotoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }

      _controller = widget.controller ?? PhotoViewController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentSize = widget.customSize ?? constraints.biggest;

        if (widget.child != null) {
          return PhotoViewCore(
            decoration: widget.decoration,
            controller: _controller,
            scaleBoundaries: ScaleBoundaries(
              widget.minScale ?? 0.0,
              widget.maxScale ?? double.infinity,
              widget.initialScale ?? PhotoViewComputedScale.contained,
              parentSize,
              widget.childSize ?? parentSize,
            ),
            child: widget.child!,
          );
        }

        return PhotoViewImage(
          decoration: widget.decoration,
          imageProvider: widget.imageProvider!,
          loadingBuilder: widget.loadingBuilder!,
          semanticLabel: widget.semanticLabel,
          gaplessPlayback: widget.gaplessPlayback,
          controller: _controller,
          maxScale: widget.maxScale,
          minScale: widget.minScale,
          initialScale: widget.initialScale,
          outerSize: parentSize,
          errorBuilder: widget.errorBuilder!,
        );
      },
    );
  }
}
