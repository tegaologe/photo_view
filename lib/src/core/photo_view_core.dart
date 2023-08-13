import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart' show PhotoViewHeroAttributes;
import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/controller/photo_view_controller_delegate.dart';
import 'package:photo_view/src/core/photo_view_gesture_detector.dart';
import 'package:photo_view/src/core/photo_view_hit_corners.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';

/// Internal widget in which controls all animations lifecycle, core responses
/// to user gestures, updates to  the controller state and mounts the entire PhotoView Layout
class PhotoViewCore extends StatefulWidget {
  const PhotoViewCore({
    super.key,
    required ImageProvider this.imageProvider,
    required this.backgroundDecoration,
    required this.semanticLabel,
    required this.gaplessPlayback,
    required this.heroAttributes,
    required this.enableRotation,
    required this.onTapUp,
    required this.onTapDown,
    required this.onScaleEnd,
    required this.gestureDetectorBehavior,
    required this.controller,
    required this.scaleBoundaries,
    required this.basePosition,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
    required this.strictScale,
  }) : customChild = null;

  const PhotoViewCore.customChild({
    super.key,
    required Widget this.customChild,
    required this.backgroundDecoration,
    required this.heroAttributes,
    required this.enableRotation,
    required this.onTapUp,
    required this.onTapDown,
    required this.onScaleEnd,
    required this.gestureDetectorBehavior,
    required this.controller,
    required this.scaleBoundaries,
    required this.basePosition,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
    required this.strictScale,
  })  : imageProvider = null,
        semanticLabel = null,
        gaplessPlayback = false;

  final Decoration backgroundDecoration;
  final ImageProvider? imageProvider;
  final String? semanticLabel;
  final bool? gaplessPlayback;
  final PhotoViewHeroAttributes? heroAttributes;
  final bool enableRotation;
  final Widget? customChild;
  final PhotoViewControllerBase controller;
  final ScaleBoundaries scaleBoundaries;
  final Alignment basePosition;
  final GestureTapUpCallback? onTapUp;
  final GestureTapDownCallback? onTapDown;
  final GestureScaleEndCallback? onScaleEnd;
  final HitTestBehavior? gestureDetectorBehavior;
  final bool tightMode;
  final bool disableGestures;
  final bool enablePanAlways;
  final bool strictScale;
  final FilterQuality filterQuality;

  @override
  State<StatefulWidget> createState() => PhotoViewCoreState();
}

class PhotoViewCoreState extends State<PhotoViewCore>
    with
        TickerProviderStateMixin,
        PhotoViewControllerDelegate,
        HitCornersDetector {
  late Offset _normalizedPosition;
  late double _scaleBefore;
  late double _rotationBefore;

  late final AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  late final AnimationController _positionAnimationController;
  late Animation<Offset> _positionAnimation;

  late final AnimationController _rotationAnimationController;
  late Animation<double> _rotationAnimation;

  PhotoViewHeroAttributes? get heroAttributes => widget.heroAttributes;

  late ScaleBoundaries cachedScaleBoundaries = widget.scaleBoundaries;

  @override
  void initState() {
    super.initState();
    initDelegate();

    cachedScaleBoundaries = widget.scaleBoundaries;

    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(_handleScaleAnimation);

    _positionAnimationController = AnimationController(vsync: this)
      ..addListener(_handlePositionAnimate);

    _rotationAnimationController = AnimationController(vsync: this)
      ..addListener(_handleRotationAnimation);
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  void _handleScaleAnimation() {
    scale = _scaleAnimation.value;
  }

  void _handlePositionAnimate() {
    controller.position = _positionAnimation.value;
  }

  void _handleRotationAnimation() {
    controller.rotation = _rotationAnimation.value;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _rotationBefore = controller.rotation;
    _scaleBefore = scale;
    _normalizedPosition = details.focalPoint - controller.position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    _rotationAnimationController.stop();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final newScale = _scaleBefore * details.scale;
    final delta = details.focalPoint - _normalizedPosition;

    if (widget.strictScale &&
        (newScale > widget.scaleBoundaries.maxScale ||
            newScale < widget.scaleBoundaries.minScale)) {
      return;
    }

    controller.updateMultiple(
      scale: newScale,
      position: widget.enablePanAlways
          ? delta
          : clampPosition(position: delta * details.scale),
      rotation:
          widget.enableRotation ? _rotationBefore + details.rotation : null,
      rotationFocusPoint: widget.enableRotation ? details.focalPoint : null,
    );
  }

  void _onScaleEnd(ScaleEndDetails details) {
    widget.onScaleEnd?.call(details);

    final scale = this.scale;
    final position = controller.position;
    final maxScale = scaleBoundaries.maxScale;
    final minScale = scaleBoundaries.minScale;

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (scale > maxScale) {
      final scaleComebackRatio = maxScale / scale;
      _animateScale(scale, maxScale);
      final clampedPosition = clampPosition(
        position: position * scaleComebackRatio,
        scale: maxScale,
      );
      _animatePosition(position, clampedPosition);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (scale < minScale) {
      final scaleComebackRatio = minScale / scale;
      _animateScale(scale, minScale);
      _animatePosition(
        position,
        clampPosition(
          position: position * scaleComebackRatio,
          scale: minScale,
        ),
      );
      return;
    }
    // get magnitude from gesture velocity
    final magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    if (_scaleBefore / scale == 1.0 && magnitude >= 400.0) {
      final direction = details.velocity.pixelsPerSecond / magnitude;
      _animatePosition(
        position,
        clampPosition(position: position + direction * 100.0),
      );
    }
  }

  void _animateScale(double from, double to) {
    _scaleAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void _animatePosition(Offset from, Offset to) {
    _positionAnimation = Tween<Offset>(begin: from, end: to)
        .animate(_positionAnimationController);
    _positionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    double scaleChange;

    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy == 0.0) return;

      scaleChange = exp(-event.scrollDelta.dy / 200);
    } else if (event is PointerScaleEvent) {
      scaleChange = event.scale;
    } else {
      return;
    }

    _onScaleStart(ScaleStartDetails(focalPoint: event.position));

    final newScale = _scaleBefore * scaleChange;

    if (newScale > widget.scaleBoundaries.maxScale) {
      scaleChange = widget.scaleBoundaries.maxScale / _scaleBefore;
    } else if (newScale < widget.scaleBoundaries.minScale) {
      scaleChange = widget.scaleBoundaries.minScale / _scaleBefore;
    }

    _onScaleUpdate(
      ScaleUpdateDetails(
        focalPoint: event.position,
        localFocalPoint: event.localPosition,
        scale: scaleChange,
      ),
    );

    _onScaleEnd(ScaleEndDetails());
  }

  Widget _buildChild() {
    final child = widget.customChild ??
        Image(
          image: widget.imageProvider!,
          semanticLabel: widget.semanticLabel,
          gaplessPlayback: widget.gaplessPlayback ?? false,
          filterQuality: widget.filterQuality,
          width: scaleBoundaries.childSize.width * scale,
          fit: BoxFit.contain,
        );

    if (heroAttributes != null) {
      return Hero(
        tag: heroAttributes!.tag,
        createRectTween: heroAttributes!.createRectTween,
        flightShuttleBuilder: heroAttributes!.flightShuttleBuilder,
        placeholderBuilder: heroAttributes!.placeholderBuilder,
        transitionOnUserGestures: heroAttributes!.transitionOnUserGestures,
        child: child,
      );
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need a recalc on the scale
    if (widget.scaleBoundaries != cachedScaleBoundaries) {
      markNeedsScaleRecalc = true;
      cachedScaleBoundaries = widget.scaleBoundaries;
    }

    return StreamBuilder(
      stream: controller.outputStateStream,
      initialData: controller.prevValue,
      builder: (
        BuildContext context,
        AsyncSnapshot<PhotoViewControllerValue> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final value = snapshot.data!;
        final useImageScale = widget.filterQuality != FilterQuality.none;

        final computedScale = useImageScale ? 1.0 : scale;

        final matrix = Matrix4.identity()
          ..translate(value.position.dx, value.position.dy)
          ..scale(computedScale)
          ..rotateZ(value.rotation);

        final customChildLayout = CustomSingleChildLayout(
          delegate: _CenterWithOriginalSizeDelegate(
            scaleBoundaries.childSize,
            basePosition,
            useImageScale,
          ),
          child: _buildChild(),
        );

        final child = Container(
          constraints: widget.tightMode
              ? BoxConstraints.tight(scaleBoundaries.childSize * scale)
              : null,
          decoration: widget.backgroundDecoration,
          child: Center(
            child: Transform(
              transform: matrix,
              alignment: basePosition,
              child: customChildLayout,
            ),
          ),
        );

        if (widget.disableGestures) {
          return child;
        }

        return Listener(
          onPointerSignal: _onPointerSignal,
          child: PhotoViewGestureDetector(
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            hitDetector: this,
            onTapUp: widget.onTapUp,
            onTapDown: widget.onTapDown,
            child: child,
          ),
        );
      },
    );
  }
}

class _CenterWithOriginalSizeDelegate extends SingleChildLayoutDelegate {
  const _CenterWithOriginalSizeDelegate(
    this.subjectSize,
    this.basePosition,
    this.useImageScale,
  );

  final Size subjectSize;
  final Alignment basePosition;
  final bool useImageScale;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final childWidth = useImageScale ? childSize.width : subjectSize.width;
    final childHeight = useImageScale ? childSize.height : subjectSize.height;

    final halfWidth = (size.width - childWidth) / 2;
    final halfHeight = (size.height - childHeight) / 2;

    final offsetX = halfWidth * (basePosition.x + 1);
    final offsetY = halfHeight * (basePosition.y + 1);
    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return useImageScale
        ? const BoxConstraints()
        : BoxConstraints.tight(subjectSize);
  }

  @override
  bool shouldRelayout(_CenterWithOriginalSizeDelegate oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CenterWithOriginalSizeDelegate &&
          runtimeType == other.runtimeType &&
          subjectSize == other.subjectSize &&
          basePosition == other.basePosition &&
          useImageScale == other.useImageScale;

  @override
  int get hashCode =>
      subjectSize.hashCode ^ basePosition.hashCode ^ useImageScale.hashCode;
}
