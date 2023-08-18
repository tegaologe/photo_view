import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/core/photo_view_core.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';

/// A  class to hold internal layout logic to sync both controller states
///
/// It reacts to layout changes (eg: enter landscape or widget resize) and syncs the two controllers.
mixin PhotoViewControllerDelegate on State<PhotoViewCore> {
  PhotoViewController get controller => widget.controller;
  ScaleBoundaries get scaleBoundaries => widget.scaleBoundaries;
  Alignment get basePosition => widget.decoration.basePosition;

  /// Mark if scale need recalculation, useful for scale boundaries changes.
  bool markNeedsScaleRecalc = true;

  void initDelegate() {
    controller.addListener(_blindScaleListener);
  }

  void _blindScaleListener() {
    if (!widget.decoration.enablePanAlways) {
      controller.value = controller.value.copyWith(
        position: clampPosition(),
      );
    }
  }

  Offset get position => controller.value.position;

  double get scale {
    final scaleExistsOnController = controller.value.scale != null;

    if (markNeedsScaleRecalc || !scaleExistsOnController) {
      final newScale = _clampSize(
        scaleBoundaries.initialScale,
        scaleBoundaries,
      );
      markNeedsScaleRecalc = false;
      scale = newScale;
      return newScale;
    }

    return controller.value.scale!;
  }

  set scale(double scale) => controller.value = controller.value.copyWith(
        scale: scale,
      );

  CornersRange cornersX({double? scale}) {
    final scale0 = scale ?? this.scale;

    final computedWidth = scaleBoundaries.childSize.width * scale0;
    final screenWidth = scaleBoundaries.outerSize.width;

    final positionX = basePosition.x;
    final widthDiff = computedWidth - screenWidth;

    final minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final maxX = ((positionX + 1).abs() / 2) * widthDiff;
    return CornersRange(minX, maxX);
  }

  CornersRange cornersY({double? scale}) {
    final scale0 = scale ?? this.scale;

    final computedHeight = scaleBoundaries.childSize.height * scale0;
    final screenHeight = scaleBoundaries.outerSize.height;

    final positionY = basePosition.y;
    final heightDiff = computedHeight - screenHeight;

    final minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final maxY = ((positionY + 1).abs() / 2) * heightDiff;
    return CornersRange(minY, maxY);
  }

  Offset clampPosition({Offset? position, double? scale}) {
    final scale0 = scale ?? this.scale;
    final position0 = position ?? this.position;

    final computedWidth = scaleBoundaries.childSize.width * scale0;
    final computedHeight = scaleBoundaries.childSize.height * scale0;

    final screenWidth = scaleBoundaries.outerSize.width;
    final screenHeight = scaleBoundaries.outerSize.height;

    var finalX = 0.0;
    if (screenWidth < computedWidth) {
      final cornersX = this.cornersX(scale: scale0);
      finalX = position0.dx.clamp(cornersX.min, cornersX.max);
    }

    var finalY = 0.0;
    if (screenHeight < computedHeight) {
      final cornersY = this.cornersY(scale: scale0);
      finalY = position0.dy.clamp(cornersY.min, cornersY.max);
    }

    return Offset(finalX, finalY);
  }

  @override
  void dispose() {
    // controller.removeIgnorableListener(_blindScaleListener);
    super.dispose();
  }
}

double _clampSize(double size, ScaleBoundaries scaleBoundaries) {
  return size.clamp(scaleBoundaries.minScale, scaleBoundaries.maxScale);
}
