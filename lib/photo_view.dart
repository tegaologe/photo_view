import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/controller/photo_view_scalestate_controller.dart';
import 'package:photo_view/src/core/photo_view_core.dart';
import 'package:photo_view/src/photo_view_computed_scale.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:photo_view/src/photo_view_wrappers.dart';
import 'package:photo_view/src/utils/photo_view_hero_attributes.dart';

export 'src/controller/photo_view_controller.dart';
export 'src/controller/photo_view_scalestate_controller.dart';
export 'src/core/photo_view_gesture_detector.dart'
    show PhotoViewGestureDetectorScope;
export 'src/photo_view_computed_scale.dart';
export 'src/photo_view_scale_state.dart';
export 'src/utils/photo_view_hero_attributes.dart';

class PhotoView extends StatefulWidget {
  const PhotoView({
    super.key,
    required this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.semanticLabel,
    this.gaplessPlayback = false,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableDoubleTap = false,
    this.disableGestures,
    this.errorBuilder,
    this.enablePanAlways,
    this.strictScale,
  })  : child = null,
        childSize = null;

  const PhotoView.customChild({
    super.key,
    required this.child,
    this.childSize,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableDoubleTap = false,
    this.disableGestures,
    this.enablePanAlways,
    this.strictScale,
  })  : errorBuilder = null,
        imageProvider = null,
        semanticLabel = null,
        gaplessPlayback = false,
        loadingBuilder = null;

  /// Given a [imageProvider] it resolves into an zoomable image widget using. It
  /// is required
  final ImageProvider? imageProvider;

  /// While [imageProvider] is not resolved, [loadingBuilder] is called by [PhotoView]
  /// into the screen, by default it is a centered [CircularProgressIndicator]
  final LoadingBuilder? loadingBuilder;

  /// Show loadFailedChild when the image failed to load
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Changes the background behind image, defaults to `Colors.black`.
  final BoxDecoration? backgroundDecoration;

  /// This is used to keep the state of an image in the gallery (e.g. scale state).
  /// `false` -> resets the state (default)
  /// `true`  -> keeps the state
  final bool wantKeepAlive;

  /// A Semantic description of the image.
  ///
  /// Used to provide a description of the image to TalkBack on Android, and VoiceOver on iOS.
  final String? semanticLabel;

  /// This is used to continue showing the old image (`true`), or briefly show
  /// nothing (`false`), when the `imageProvider` changes. By default it's set
  /// to `false`.
  final bool gaplessPlayback;

  /// Attributes that are going to be passed to [PhotoViewCore]'s
  /// [Hero]. Leave this property undefined if you don't want a hero animation.
  final PhotoViewHeroAttributes? heroAttributes;

  /// Defines the size of the scaling base of the image inside [PhotoView],
  /// by default it is `MediaQuery.of(context).size`.
  final Size? customSize;

  /// A [Function] to be called whenever the scaleState changes, this happens when the user double taps the content ou start to pinch-in.
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback;

  /// A flag that enables the rotation gesture support
  final bool enableRotation;

  /// The specified custom child to be shown instead of a image
  final Widget? child;

  /// The size of the custom [child]. [PhotoView] uses this value to compute the relation between the child and the container's size to calculate the scale value.
  final Size? childSize;

  /// Defines the maximum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic maxScale;

  /// Defines the minimum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic minScale;

  /// Defines the initial size in which the image will be assume in the mounting of the component, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic initialScale;

  /// A way to control PhotoView transformation factors externally and listen to its updates
  final PhotoViewControllerBase? controller;

  /// A way to control PhotoViewScaleState value externally and listen to its updates
  final PhotoViewScaleStateController? scaleStateController;

  /// The alignment of the scale origin in relation to the widget size. Default is [Alignment.center]
  final Alignment? basePosition;

  /// Defines de next [PhotoViewScaleState] given the actual one. Default is [defaultScaleStateCycle]
  final ScaleStateCycle? scaleStateCycle;

  /// A pointer that will trigger a tap has stopped contacting the screen at a
  /// particular location.
  final PhotoViewImageTapUpCallback? onTapUp;

  /// A pointer that might cause a tap has contacted the screen at a particular
  /// location.
  final PhotoViewImageTapDownCallback? onTapDown;

  /// A pointer that will trigger a scale has stopped contacting the screen at a
  /// particular location.
  final PhotoViewImageScaleEndCallback? onScaleEnd;

  /// [HitTestBehavior] to be passed to the internal gesture detector.
  final HitTestBehavior? gestureDetectorBehavior;

  /// Enables tight mode, making background container assume the size of the image/child.
  /// Useful when inside a [Dialog]
  final bool? tightMode;

  /// Quality levels for image filters.
  final FilterQuality? filterQuality;

  final bool disableDoubleTap;

  // Removes gesture detector if `true`.
  // Useful when custom gesture detector is used in child widget.
  final bool? disableGestures;

  /// Enable pan the widget even if it's smaller than the hole parent widget.
  /// Useful when you want to drag a widget without restrictions.
  final bool? enablePanAlways;

  /// Enable strictScale will restrict user scale gesture to the maxScale and minScale values.
  final bool? strictScale;

  @override
  State<StatefulWidget> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView>
    with AutomaticKeepAliveClientMixin {
  late PhotoViewControllerBase _controller;
  late PhotoViewScaleStateController _scaleStateController;
  late StreamSubscription<PhotoViewScaleState> _scaleStateSubscription;

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? PhotoViewController();
    _scaleStateController =
        widget.scaleStateController ?? PhotoViewScaleStateController();

    _scaleStateSubscription =
        _scaleStateController.outputScaleStateStream.listen(
      scaleStateListener,
    );
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

    if (widget.scaleStateController != oldWidget.scaleStateController) {
      _scaleStateSubscription.cancel().ignore();

      if (oldWidget.scaleStateController == null) {
        _scaleStateController.dispose();
      }

      _scaleStateController =
          widget.scaleStateController ?? PhotoViewScaleStateController();

      _scaleStateSubscription =
          _scaleStateController.outputScaleStateStream.listen(
        scaleStateListener,
      );
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.scaleStateController == null) {
      _scaleStateController.dispose();
    }

    super.dispose();
  }

  void scaleStateListener(PhotoViewScaleState scaleState) {
    widget.scaleStateChangedCallback?.call(_scaleStateController.scaleState);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final computedOuterSize = widget.customSize ?? constraints.biggest;
        final backgroundDecoration = widget.backgroundDecoration ??
            const BoxDecoration(color: Colors.black);

        return widget.child != null
            ? CustomChildWrapper(
                childSize: widget.childSize,
                backgroundDecoration: backgroundDecoration,
                heroAttributes: widget.heroAttributes,
                scaleStateChangedCallback: widget.scaleStateChangedCallback,
                enableRotation: widget.enableRotation,
                controller: _controller,
                scaleStateController: _scaleStateController,
                maxScale: widget.maxScale,
                minScale: widget.minScale,
                initialScale: widget.initialScale,
                basePosition: widget.basePosition,
                scaleStateCycle: widget.scaleStateCycle,
                onTapUp: widget.onTapUp,
                onTapDown: widget.onTapDown,
                onScaleEnd: widget.onScaleEnd,
                outerSize: computedOuterSize,
                gestureDetectorBehavior: widget.gestureDetectorBehavior,
                tightMode: widget.tightMode,
                filterQuality: widget.filterQuality,
                disableDoubleTap: widget.disableDoubleTap,
                disableGestures: widget.disableGestures,
                enablePanAlways: widget.enablePanAlways,
                strictScale: widget.strictScale,
                child: widget.child,
              )
            : ImageWrapper(
                imageProvider: widget.imageProvider!,
                loadingBuilder: widget.loadingBuilder,
                backgroundDecoration: backgroundDecoration,
                semanticLabel: widget.semanticLabel,
                gaplessPlayback: widget.gaplessPlayback,
                heroAttributes: widget.heroAttributes,
                scaleStateChangedCallback: widget.scaleStateChangedCallback,
                enableRotation: widget.enableRotation,
                controller: _controller,
                scaleStateController: _scaleStateController,
                maxScale: widget.maxScale,
                minScale: widget.minScale,
                initialScale: widget.initialScale,
                basePosition: widget.basePosition,
                scaleStateCycle: widget.scaleStateCycle,
                onTapUp: widget.onTapUp,
                onTapDown: widget.onTapDown,
                onScaleEnd: widget.onScaleEnd,
                outerSize: computedOuterSize,
                gestureDetectorBehavior: widget.gestureDetectorBehavior,
                tightMode: widget.tightMode,
                filterQuality: widget.filterQuality,
                disableDoubleTap: widget.disableDoubleTap,
                disableGestures: widget.disableGestures,
                errorBuilder: widget.errorBuilder,
                enablePanAlways: widget.enablePanAlways,
                strictScale: widget.strictScale,
              );
      },
    );
  }
}

/// The default [ScaleStateCycle]
PhotoViewScaleState defaultScaleStateCycle(PhotoViewScaleState actual) {
  switch (actual) {
    case PhotoViewScaleState.initial:
      return PhotoViewScaleState.covering;
    case PhotoViewScaleState.covering:
      return PhotoViewScaleState.originalSize;
    case PhotoViewScaleState.originalSize:
      return PhotoViewScaleState.initial;
    case PhotoViewScaleState.zoomedIn:
    case PhotoViewScaleState.zoomedOut:
      return PhotoViewScaleState.initial;
    default:
      return PhotoViewScaleState.initial;
  }
}

/// A type definition for a [Function] that receives the actual [PhotoViewScaleState] and returns the next one
/// It is used internally to walk in the "doubletap gesture cycle".
/// It is passed to [PhotoView.scaleStateCycle]
typedef ScaleStateCycle = PhotoViewScaleState Function(
  PhotoViewScaleState actual,
);

/// A type definition for a callback when the user taps up the photoview region
typedef PhotoViewImageTapUpCallback = Function(
  BuildContext context,
  TapUpDetails details,
  PhotoViewControllerValue controllerValue,
);

/// A type definition for a callback when the user taps down the photoview region
typedef PhotoViewImageTapDownCallback = Function(
  BuildContext context,
  TapDownDetails details,
  PhotoViewControllerValue controllerValue,
);

/// A type definition for a callback when a user finished scale
typedef PhotoViewImageScaleEndCallback = Function(
  BuildContext context,
  ScaleEndDetails details,
  PhotoViewControllerValue controllerValue,
);

/// A type definition for a callback to show a widget while the image is loading, a [ImageChunkEvent] is passed to inform progress
typedef LoadingBuilder = Widget Function(
  BuildContext context,
  ImageChunkEvent? event,
);
