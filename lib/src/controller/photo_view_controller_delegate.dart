import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/core/photo_view_core.dart';
import 'package:photo_view/src/utils/scale_boundaries.dart';

mixin PhotoViewControllerDelegate on State<PhotoViewCore> {
  PhotoViewController get controller => widget.controller;
  ScaleBoundaries get scaleBoundaries => widget.scaleBoundaries;
  Alignment get basePosition => widget.decoration.basePosition;

  Offset get position => controller.value.position;
  double get scale {
    return controller.value.scale!;
  }

  set scale(double scale) => controller.value = controller.value.copyWith(
        scale: scale,
      );

  (double, double) cornersX({double? scale}) {
    final scale0 = scale ?? this.scale;

    final computedWidth = scaleBoundaries.childSize.width * scale0;
    final screenWidth = scaleBoundaries.outerSize.width;

    final positionX = basePosition.x;
    final widthDiff = computedWidth - screenWidth;

    final minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final maxX = ((positionX + 1).abs() / 2) * widthDiff;
    return (minX, maxX);
  }

  (double, double) cornersY({double? scale}) {
    final scale0 = scale ?? this.scale;

    final computedHeight = scaleBoundaries.childSize.height * scale0;
    final screenHeight = scaleBoundaries.outerSize.height;

    final positionY = basePosition.y;
    final heightDiff = computedHeight - screenHeight;

    final minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final maxY = ((positionY + 1).abs() / 2) * heightDiff;
    return (minY, maxY);
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
      final (min, max) = cornersX(scale: scale0);
      finalX = position0.dx.clamp(min, max);
    }

    var finalY = 0.0;
    if (screenHeight < computedHeight) {
      final (min, max) = cornersY(scale: scale0);
      finalY = position0.dy.clamp(min, max);
    }

    return Offset(finalX, finalY);
  }
}
