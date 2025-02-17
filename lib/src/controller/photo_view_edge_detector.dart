import 'package:flutter/rendering.dart';
import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/utils/scale_boundaries.dart';

class PhotoViewEdgeDetector {
  PhotoViewEdgeDetector({
    required PhotoViewController controller,
    required ScaleBoundaries scaleBoundaries,
    required Alignment alignment,
  })  : _controller = controller,
        _scaleBoundaries = scaleBoundaries,
        _alignment = alignment;

  /// The distance away from the edge that the position must be in to be
  /// considered "on the edge".
  static const _edgeEpsilon = 5;

  PhotoViewController _controller;
  set controller(PhotoViewController controller) => _controller = controller;

  ScaleBoundaries _scaleBoundaries;
  set scaleBoundaries(ScaleBoundaries scaleBoundaries) =>
      _scaleBoundaries = scaleBoundaries;

  Alignment _alignment;
  set alignment(Alignment alignment) => _alignment = alignment;

  Offset clampPosition({Offset? position, double? scale}) {
    scale ??= _controller.value.scale!;
    position ??= _controller.value.position;

    final computedWidth = _scaleBoundaries.childSize.width * scale;
    final computedHeight = _scaleBoundaries.childSize.height * scale;

    final screenWidth = _scaleBoundaries.outerSize.width;
    final screenHeight = _scaleBoundaries.outerSize.height;

    var finalX = 0.0;
    if (screenWidth < computedWidth) {
      final (min, max) = _horizontalEdge(scale: scale);
      finalX = position.dx.clamp(min, max);
    }

    var finalY = 0.0;
    if (screenHeight < computedHeight) {
      final (min, max) = _verticalEdge(scale: scale);
      finalY = position.dy.clamp(min, max);
    }

    return Offset(finalX, finalY);
  }

  bool canMove(Offset delta, Axis mainAxis) {
    return switch (mainAxis) {
      Axis.horizontal => _canMoveHorizontal(delta),
      Axis.vertical => _canMoveVertical(delta),
    };
  }

  (double, double) _horizontalEdge({double? scale}) {
    scale ??= _controller.value.scale!;

    final computedWidth = _scaleBoundaries.childSize.width * scale;
    final screenWidth = _scaleBoundaries.outerSize.width;

    final positionX = _alignment.x;
    final widthDiff = computedWidth - screenWidth;

    final minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final maxX = ((positionX + 1).abs() / 2) * widthDiff;

    return (minX, maxX);
  }

  (double, double) _verticalEdge({double? scale}) {
    scale ??= _controller.value.scale!;

    final computedHeight = _scaleBoundaries.childSize.height * scale;
    final screenHeight = _scaleBoundaries.outerSize.height;

    final positionY = _alignment.y;
    final heightDiff = computedHeight - screenHeight;

    final minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final maxY = ((positionY + 1).abs() / 2) * heightDiff;

    return (minY, maxY);
  }

  (bool, bool) _hitHorizontalEdge() {
    final childWidth =
        _scaleBoundaries.childSize.width * _controller.value.scale!;
    final screenWidth = _scaleBoundaries.outerSize.width;

    if (screenWidth >= childWidth) {
      return (true, true);
    }

    final x = -_controller.value.position.dx;
    final (min, max) = _horizontalEdge();

    return (x <= min + _edgeEpsilon, x >= max - _edgeEpsilon);
  }

  (bool, bool) _hitVerticalEdge() {
    final childHeight =
        _scaleBoundaries.childSize.height * _controller.value.scale!;
    final screenHeight = _scaleBoundaries.outerSize.height;

    if (screenHeight >= childHeight) {
      return (true, true);
    }

    final y = -_controller.value.position.dy;
    final (min, max) = _verticalEdge();

    return (y <= min + _edgeEpsilon, y >= max - _edgeEpsilon);
  }

  bool _canMoveHorizontal(Offset move) {
    final hitEdge = _hitHorizontalEdge();
    final mainAxisDelta = move.dx;
    final crossAxisDelta = move.dy;

    return _canMoveAxis(hitEdge, mainAxisDelta, crossAxisDelta);
  }

  bool _canMoveVertical(Offset move) {
    final hitEdge = _hitVerticalEdge();
    final mainAxisMove = move.dy;
    final crossAxisMove = move.dx;

    return _canMoveAxis(hitEdge, mainAxisMove, crossAxisMove);
  }

  bool _canMoveAxis(
    (bool, bool) hitEdge,
    double mainAxisDelta,
    double crossAxisDelta,
  ) {
    if (mainAxisDelta == 0) {
      return false;
    }

    final (hitStart, hitEnd) = hitEdge;

    if (!(hitStart || hitEnd)) {
      return true;
    }

    final axisBlocked =
        hitStart && hitEnd || (hitEnd ? mainAxisDelta > 0 : mainAxisDelta < 0);

    return !axisBlocked;
  }
}
