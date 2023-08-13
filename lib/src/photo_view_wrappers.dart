import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/core/photo_view_core.dart';
import 'package:photo_view/src/photo_view_default_widgets.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';

class ImageWrapper extends StatefulWidget {
  const ImageWrapper({
    super.key,
    required this.imageProvider,
    required this.loadingBuilder,
    required this.backgroundDecoration,
    required this.semanticLabel,
    required this.gaplessPlayback,
    required this.heroAttributes,
    required this.enableRotation,
    required this.controller,
    required this.maxScale,
    required this.minScale,
    required this.initialScale,
    required this.basePosition,
    required this.onTapUp,
    required this.onTapDown,
    required this.onScaleEnd,
    required this.outerSize,
    required this.gestureDetectorBehavior,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.errorBuilder,
    required this.enablePanAlways,
    required this.strictScale,
  });

  final ImageProvider imageProvider;
  final LoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final BoxDecoration backgroundDecoration;
  final String? semanticLabel;
  final bool gaplessPlayback;
  final PhotoViewHeroAttributes? heroAttributes;
  final bool enableRotation;
  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;
  final PhotoViewController controller;
  final Alignment basePosition;
  final GestureTapUpCallback? onTapUp;
  final GestureTapDownCallback? onTapDown;
  final GestureScaleEndCallback? onScaleEnd;
  final Size outerSize;
  final HitTestBehavior? gestureDetectorBehavior;
  final bool tightMode;
  final FilterQuality filterQuality;
  final bool disableGestures;
  final bool enablePanAlways;
  final bool strictScale;

  @override
  State<ImageWrapper> createState() => _ImageWrapperState();
}

class _ImageWrapperState extends State<ImageWrapper> {
  late ImageStreamListener _imageStreamListener;
  ImageStream? _imageStream;
  ImageChunkEvent? _loadingProgress;
  ImageInfo? _imageInfo;
  bool _loading = true;
  late Size _imageSize;
  Object? _lastException;
  StackTrace? _lastStack;

  @override
  void didUpdateWidget(ImageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _resolveImage();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void dispose() {
    super.dispose();
    _stopImageStream();
  }

  // retrieve image from the provider
  void _resolveImage() {
    final newStream = widget.imageProvider.resolve(ImageConfiguration.empty);
    _updateSourceStream(newStream);
  }

  ImageStreamListener _getOrCreateListener() {
    void handleImageChunk(ImageChunkEvent event) {
      setState(() {
        _loadingProgress = event;
        _lastException = null;
      });
    }

    void handleImageFrame(ImageInfo info, bool synchronousCall) {
      void setupCB() {
        _imageSize = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
        _loading = false;
        _imageInfo = _imageInfo;

        _loadingProgress = null;
        _lastException = null;
        _lastStack = null;
      }

      synchronousCall ? setupCB() : setState(setupCB);
    }

    void handleError(Object error, StackTrace? stackTrace) {
      setState(() {
        _loading = false;
        _lastException = error;
        _lastStack = stackTrace;
      });
      assert(() {
        if (widget.errorBuilder == null) {
          throw error;
        }
        return true;
      }());
    }

    return _imageStreamListener = ImageStreamListener(
      handleImageFrame,
      onChunk: handleImageChunk,
      onError: handleError,
    );
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) {
      return;
    }
    _imageStream?.removeListener(_imageStreamListener);
    _imageStream = newStream;
    _imageStream!.addListener(_getOrCreateListener());
  }

  void _stopImageStream() {
    _imageStream?.removeListener(_imageStreamListener);
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context, _loadingProgress);
    }

    return PhotoViewDefaultLoading(
      event: _loadingProgress,
    );
  }

  Widget _buildError(BuildContext context) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _lastException!, _lastStack);
    }
    return PhotoViewDefaultError(
      decoration: widget.backgroundDecoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoading(context);
    }

    if (_lastException != null) {
      return _buildError(context);
    }

    final scaleBoundaries = ScaleBoundaries(
      widget.minScale ?? 0.0,
      widget.maxScale ?? double.infinity,
      widget.initialScale ?? PhotoViewComputedScale.contained,
      widget.outerSize,
      _imageSize,
    );

    return PhotoViewCore(
      imageProvider: widget.imageProvider,
      backgroundDecoration: widget.backgroundDecoration,
      semanticLabel: widget.semanticLabel,
      gaplessPlayback: widget.gaplessPlayback,
      enableRotation: widget.enableRotation,
      heroAttributes: widget.heroAttributes,
      basePosition: widget.basePosition,
      controller: widget.controller,
      strictScale: widget.strictScale,
      scaleBoundaries: scaleBoundaries,
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
      onScaleEnd: widget.onScaleEnd,
      gestureDetectorBehavior: widget.gestureDetectorBehavior,
      tightMode: widget.tightMode,
      filterQuality: widget.filterQuality,
      disableGestures: widget.disableGestures,
      enablePanAlways: widget.enablePanAlways,
    );
  }
}

class CustomChildWrapper extends StatelessWidget {
  const CustomChildWrapper({
    super.key,
    required this.child,
    required this.childSize,
    required this.backgroundDecoration,
    required this.heroAttributes,
    required this.enableRotation,
    required this.controller,
    required this.maxScale,
    required this.minScale,
    required this.initialScale,
    required this.basePosition,
    required this.onTapUp,
    required this.onTapDown,
    required this.onScaleEnd,
    required this.outerSize,
    required this.gestureDetectorBehavior,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
    required this.strictScale,
  });

  final Widget child;
  final Size? childSize;
  final Decoration backgroundDecoration;
  final PhotoViewHeroAttributes? heroAttributes;
  final bool enableRotation;
  final PhotoViewController controller;
  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;
  final Alignment basePosition;
  final GestureTapUpCallback? onTapUp;
  final GestureTapDownCallback? onTapDown;
  final GestureScaleEndCallback? onScaleEnd;
  final Size outerSize;
  final HitTestBehavior? gestureDetectorBehavior;
  final bool tightMode;
  final FilterQuality filterQuality;
  final bool disableGestures;
  final bool enablePanAlways;
  final bool strictScale;

  @override
  Widget build(BuildContext context) {
    final scaleBoundaries = ScaleBoundaries(
      minScale ?? 0.0,
      maxScale ?? double.infinity,
      initialScale ?? PhotoViewComputedScale.contained,
      outerSize,
      childSize ?? outerSize,
    );

    return PhotoViewCore.customChild(
      customChild: child,
      backgroundDecoration: backgroundDecoration,
      enableRotation: enableRotation,
      heroAttributes: heroAttributes,
      controller: controller,
      basePosition: basePosition,
      scaleBoundaries: scaleBoundaries,
      strictScale: strictScale,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      onScaleEnd: onScaleEnd,
      gestureDetectorBehavior: gestureDetectorBehavior,
      tightMode: tightMode,
      filterQuality: filterQuality,
      disableGestures: disableGestures,
      enablePanAlways: enablePanAlways,
    );
  }
}
