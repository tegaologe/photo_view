import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/core/photo_view_gesture_detector.dart';
import 'package:photo_view/src/utils/scale_boundaries.dart';

class PhotoViewCore extends StatefulWidget {
  const PhotoViewCore({
    super.key,
    required this.child,
    required this.decoration,
    required this.controller,
    required this.scaleBoundaries,
  });

  final PhotoViewDecoration decoration;
  final Widget child;
  final PhotoViewController controller;
  final ScaleBoundaries scaleBoundaries;

  @override
  State<StatefulWidget> createState() => PhotoViewCoreState();
}

class PhotoViewCoreState extends State<PhotoViewCore>
    with TickerProviderStateMixin {
  late final AnimationController _scaleAnimationController;
  late final AnimationController _positionAnimationController;
  late final AnimationController _rotationAnimationController;

  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;

  late PhotoViewEdgeDetector _edgeDetector;

  late Offset _normalizedPosition;
  late double _scaleBefore;
  late double _rotationBefore;

  Offset get position => widget.controller.value.position;
  double get scale => widget.controller.value.scale!;

  @override
  void initState() {
    super.initState();

    _edgeDetector = PhotoViewEdgeDetector(
      controller: widget.controller,
      scaleBoundaries: widget.scaleBoundaries,
      alignment: widget.decoration.alignment,
    );

    widget.controller.edgeDetector = _edgeDetector;
    widget.controller.initializeScale(widget.scaleBoundaries.initialScale);
    widget.controller.initializePosition(_edgeDetector.clampPosition());

    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(_handleScaleAnimation);

    _positionAnimationController = AnimationController(vsync: this)
      ..addListener(_handlePositionAnimate);

    _rotationAnimationController = AnimationController(vsync: this)
      ..addListener(_handleRotationAnimation);
  }

  @override
  void didUpdateWidget(covariant PhotoViewCore oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scaleBoundaries != widget.scaleBoundaries) {
      widget.controller.initializeScale(widget.scaleBoundaries.initialScale);
      widget.controller.initializePosition(_edgeDetector.clampPosition());
    }

    _edgeDetector
      ..controller = widget.controller
      ..scaleBoundaries = widget.scaleBoundaries
      ..alignment = widget.decoration.alignment;
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  void _handleScaleAnimation() {
    widget.controller.value = widget.controller.value.copyWith(
      scale: _scaleAnimation.value,
    );
  }

  void _handlePositionAnimate() {
    widget.controller.value = widget.controller.value.copyWith(
      position: _positionAnimation.value,
    );
  }

  void _handleRotationAnimation() {
    widget.controller.value = widget.controller.value.copyWith(
      rotation: _rotationAnimation.value,
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _rotationBefore = widget.controller.value.rotation;
    _scaleBefore = scale;
    _normalizedPosition = details.focalPoint - position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    _rotationAnimationController.stop();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final newScale = _scaleBefore * details.scale;
    final delta = details.focalPoint - _normalizedPosition;

    if (widget.decoration.strictScale &&
        (newScale > widget.scaleBoundaries.maxScale ||
            newScale < widget.scaleBoundaries.minScale)) {
      return;
    }

    widget.controller.value = widget.controller.value.copyWith(
      scale: newScale,
      position: widget.decoration.allowUnrestrictedPan
          ? delta
          : _edgeDetector.clampPosition(position: delta * details.scale),
      rotation: widget.decoration.enableRotation
          ? _rotationBefore + details.rotation
          : null,
      rotationFocusPoint:
          widget.decoration.enableRotation ? details.focalPoint : null,
    );
  }

  void _onScaleEnd(ScaleEndDetails details) {
    widget.decoration.onScaleEnd?.call(details);

    final minScale = widget.scaleBoundaries.minScale;
    final maxScale = widget.scaleBoundaries.maxScale;

    // animate back to maxScale if gesture exceeded the maxScale specified
    if (scale > maxScale) {
      final scaleComebackRatio = maxScale / scale;
      _animateScale(scale, maxScale);
      final clampedPosition = _edgeDetector.clampPosition(
        position: position * scaleComebackRatio,
        scale: maxScale,
      );
      _animatePosition(position, clampedPosition);
      return;
    }

    // animate back to minScale if gesture fell smaller than the minScale
    // specified
    if (scale < minScale) {
      final scaleComebackRatio = minScale / scale;
      _animateScale(scale, minScale);
      _animatePosition(
        position,
        _edgeDetector.clampPosition(
          position: position * scaleComebackRatio,
          scale: minScale,
        ),
      );
      return;
    }

    // get magnitude from gesture velocity
    final magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant
    // magnitude
    if (_scaleBefore / scale == 1.0 && magnitude >= 400.0) {
      final direction = details.velocity.pixelsPerSecond / magnitude;
      _animatePosition(
        position,
        _edgeDetector.clampPosition(position: position + direction * 100.0),
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (_, value, __) {
        final heroAttributes = widget.decoration.heroAttributes;
        final useImageScale =
            widget.decoration.filterQuality != FilterQuality.none;

        final computedScale = useImageScale ? 1.0 : scale;

        final matrix = Matrix4.identity()
          ..translate(value.position.dx, value.position.dy)
          ..scale(computedScale)
          ..rotateZ(value.rotation);

        Widget child;

        if (heroAttributes != null) {
          child = Hero(
            tag: heroAttributes.tag,
            createRectTween: heroAttributes.createRectTween,
            flightShuttleBuilder: heroAttributes.flightShuttleBuilder,
            placeholderBuilder: heroAttributes.placeholderBuilder,
            transitionOnUserGestures: heroAttributes.transitionOnUserGestures,
            child: widget.child,
          );
        } else {
          child = widget.child;
        }

        child = CustomSingleChildLayout(
          delegate: _CenterWithOriginalSizeDelegate(
            widget.scaleBoundaries.childSize,
            widget.decoration.alignment,
            useImageScale,
          ),
          child: child,
        );

        child = Container(
          alignment: Alignment.center,
          constraints: widget.decoration.tightMode
              ? BoxConstraints.tight(widget.scaleBoundaries.childSize * scale)
              : null,
          decoration: widget.decoration.backgroundDecoration,
          child: Transform(
            transform: matrix,
            alignment: widget.decoration.alignment,
            child: child,
          ),
        );

        if (widget.decoration.disableGestures) {
          return child;
        }

        return Listener(
          onPointerSignal: _onPointerSignal,
          child: PhotoViewGestureDetector(
            behavior: widget.decoration.gestureDetectorBehavior,
            edgeDetector: _edgeDetector,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            onTapUp: widget.decoration.onTapUp,
            onTapDown: widget.decoration.onTapDown,
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
    this.alignment,
    this.useImageScale,
  );

  final Size subjectSize;
  final Alignment alignment;
  final bool useImageScale;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final childWidth = useImageScale ? childSize.width : subjectSize.width;
    final childHeight = useImageScale ? childSize.height : subjectSize.height;

    final halfWidth = (size.width - childWidth) / 2;
    final halfHeight = (size.height - childHeight) / 2;

    final offsetX = halfWidth * (alignment.x + 1);
    final offsetY = halfHeight * (alignment.y + 1);
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
    return oldDelegate.subjectSize != subjectSize ||
        oldDelegate.alignment != alignment ||
        oldDelegate.useImageScale != useImageScale;
  }
}
