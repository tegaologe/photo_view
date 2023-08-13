import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class CommonExampleRouteWrapper extends StatelessWidget {
  const CommonExampleRouteWrapper({
    super.key,
    required this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration = const BoxDecoration(color: Color(0xff000000)),
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition = Alignment.center,
    this.filterQuality = FilterQuality.none,
    this.disableGestures = false,
    this.errorBuilder,
  });

  final ImageProvider imageProvider;
  final PhotoViewImageLoadingBuilder? loadingBuilder;
  final BoxDecoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;
  final FilterQuality filterQuality;
  final bool disableGestures;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          loadingBuilder: loadingBuilder ?? (_, __) => const SizedBox(),
          decoration: PhotoViewDecoration(
            backgroundDecoration: backgroundDecoration,
            basePosition: basePosition,
            filterQuality: filterQuality,
            disableGestures: disableGestures,
          ),
          minScale: minScale,
          maxScale: maxScale,
          initialScale: initialScale,
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
      ),
    );
  }
}
