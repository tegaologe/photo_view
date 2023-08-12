import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart' show PhotoViewControllerBase;
import 'package:photo_view/src/core/photo_view_core.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';

/// A  class to hold internal layout logic to sync both controller states
///
/// It reacts to layout changes (eg: enter landscape or widget resize) and syncs the two controllers.
mixin PhotoViewControllerDelegate on State<PhotoViewCore> {
  PhotoViewControllerBase get controller => widget.controller;

  ScaleBoundaries get scaleBoundaries => widget.scaleBoundaries;

  Alignment get basePosition => widget.basePosition;

  /// Mark if scale need recalculation, useful for scale boundaries changes.
  bool markNeedsScaleRecalc = true;

  void initDelegate() {
    controller.addIgnorableListener(_blindScaleListener);
  }

  void _blindScaleListener() {
    if (!widget.enablePanAlways) {
      controller.position = clampPosition();
    }
    if (controller.scale == controller.prevValue.scale) {
      return;
    }
  }

  Offset get position => controller.position;

  double get scale => controller.scale!;

  set scale(double scale) => controller.setScaleInvisibly(scale);

  void updateMultiple({
    Offset? position,
    double? scale,
    double? rotation,
    Offset? rotationFocusPoint,
  }) {
    controller.updateMultiple(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

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
    controller.removeIgnorableListener(_blindScaleListener);
    super.dispose();
  }
}
