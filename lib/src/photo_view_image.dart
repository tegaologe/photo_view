import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/core/photo_view_core.dart';
import 'package:photo_view/src/utils/scale_boundaries.dart';

class PhotoViewImage extends StatefulWidget {
  const PhotoViewImage({
    super.key,
    required this.controller,
    required this.imageProvider,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.decoration,
    required this.semanticLabel,
    required this.gaplessPlayback,
    required this.minScale,
    required this.maxScale,
    required this.initialScale,
    required this.outerSize,
  });

  final PhotoViewController controller;
  final ImageProvider imageProvider;
  final PhotoViewImageLoadingBuilder loadingBuilder;
  final ImageErrorWidgetBuilder errorBuilder;

  final PhotoViewDecoration decoration;
  final String? semanticLabel;
  final bool gaplessPlayback;
  final PhotoViewScale minScale;
  final PhotoViewScale maxScale;
  final PhotoViewScale initialScale;
  final Size outerSize;

  @override
  State<PhotoViewImage> createState() => _PhotoViewImageState();
}

class _PhotoViewImageState extends State<PhotoViewImage> {
  late final ImageStreamListener _imageStreamListener;
  ImageStream? _imageStream;

  var _imageState = const _ImageState.loading();

  @override
  void initState() {
    super.initState();

    _setupImageStreamListener();
  }

  @override
  void didUpdateWidget(covariant PhotoViewImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageProvider != widget.imageProvider) {
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
    _imageStream?.removeListener(_imageStreamListener);

    super.dispose();
  }

  void _setupImageStreamListener() {
    void onImage(ImageInfo info, bool synchronousCall) {
      final size = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );

      synchronousCall
          ? _imageState = _ImageState.data(size: size)
          : setState(
              () => _imageState = _ImageState.data(size: size),
            );
    }

    void onChunk(ImageChunkEvent event) {
      setState(
        () => _imageState = _ImageState.loading(progress: event),
      );
    }

    void onError(Object error, StackTrace? stackTrace) {
      setState(
        () => _imageState = _ImageState.error(
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }

    _imageStreamListener = ImageStreamListener(
      onImage,
      onChunk: onChunk,
      onError: onError,
    );
  }

  void _resolveImage() {
    final imageStream = widget.imageProvider.resolve(
      createLocalImageConfiguration(context),
    );

    if (_imageStream?.key == imageStream.key) return;

    _imageStream?.removeListener(_imageStreamListener);
    _imageStream = imageStream..addListener(_imageStreamListener);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_imageState) {
      _PhotoViewImageStateLoading(:final progress) =>
        widget.loadingBuilder(context, progress),
      _PhotoViewImageStateError(:final error, :final stackTrace) =>
        widget.errorBuilder(context, error, stackTrace),
      _PhotoViewImageStateData(:final size) => PhotoViewCore(
          controller: widget.controller,
          decoration: widget.decoration,
          scaleBoundaries: ScaleBoundaries(
            widget.minScale,
            widget.maxScale,
            widget.initialScale,
            widget.outerSize,
            size,
          ),
          child: Image(
            image: widget.imageProvider,
            semanticLabel: widget.semanticLabel,
            gaplessPlayback: widget.gaplessPlayback,
            filterQuality: widget.decoration.filterQuality,
            width: size.width * (widget.controller.value.scale ?? 1.0),
            fit: BoxFit.contain,
          ),
        ),
    };
  }
}

sealed class _ImageState {
  const _ImageState();

  const factory _ImageState.loading({
    ImageChunkEvent? progress,
  }) = _PhotoViewImageStateLoading;

  const factory _ImageState.data({
    required Size size,
  }) = _PhotoViewImageStateData;

  const factory _ImageState.error({
    required Object error,
    StackTrace? stackTrace,
  }) = _PhotoViewImageStateError;
}

class _PhotoViewImageStateLoading extends _ImageState {
  const _PhotoViewImageStateLoading({this.progress});

  final ImageChunkEvent? progress;
}

class _PhotoViewImageStateData extends _ImageState {
  const _PhotoViewImageStateData({required this.size});

  final Size size;
}

class _PhotoViewImageStateError extends _ImageState {
  const _PhotoViewImageStateError({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;
}
