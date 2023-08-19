import 'package:flutter/rendering.dart';
import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/utils/scale_boundaries.dart';

class PhotoViewEdgeDetector {
  PhotoViewEdgeDetector({
    required PhotoViewController controller,
    required ScaleBoundaries scaleBoundaries,
    required Alignment basePosition,
  })  : _controller = controller,
        _scaleBoundaries = scaleBoundaries,
        _basePosition = basePosition;

  PhotoViewController _controller;
  set controller(PhotoViewController controller) => _controller = controller;

  ScaleBoundaries _scaleBoundaries;
  set scaleBoundaries(ScaleBoundaries scaleBoundaries) =>
      _scaleBoundaries = scaleBoundaries;

  Alignment _basePosition;
  set basePosition(Alignment basePosition) => _basePosition = basePosition;

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

  bool canMove(Offset move, Axis mainAxis) {
    return switch (mainAxis) {
      Axis.horizontal => _canMoveHorizontal(move),
      Axis.vertical => _canMoveVertical(move),
    };
  }

  (double, double) _horizontalEdge({double? scale}) {
    scale ??= _controller.value.scale!;

    final computedWidth = _scaleBoundaries.childSize.width * scale;
    final screenWidth = _scaleBoundaries.outerSize.width;

    final positionX = _basePosition.x;
    final widthDiff = computedWidth - screenWidth;

    final minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final maxX = ((positionX + 1).abs() / 2) * widthDiff;

    return (minX, maxX);
  }

  (double, double) _verticalEdge({double? scale}) {
    scale ??= _controller.value.scale!;

    final computedHeight = _scaleBoundaries.childSize.height * scale;
    final screenHeight = _scaleBoundaries.outerSize.height;

    final positionY = _basePosition.y;
    final heightDiff = computedHeight - screenHeight;

    final minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final maxY = ((positionY + 1).abs() / 2) * heightDiff;

    return (minY, maxY);
  }

  _HitEdge _hitHorizontalEdge() {
    final childWidth =
        _scaleBoundaries.childSize.width * _controller.value.scale!;
    final screenWidth = _scaleBoundaries.outerSize.width;

    if (screenWidth >= childWidth) {
      return const _HitEdge(true, true);
    }

    final x = -_controller.value.position.dx;
    final (min, max) = _horizontalEdge();

    return _HitEdge(x <= min, x >= max);
  }

  _HitEdge _hitVerticalEdge() {
    final childHeight =
        _scaleBoundaries.childSize.height * _controller.value.scale!;
    final screenHeight = _scaleBoundaries.outerSize.height;

    if (screenHeight >= childHeight) {
      return const _HitEdge(true, true);
    }

    final y = -_controller.value.position.dy;
    final (min, max) = _verticalEdge();

    return _HitEdge(y <= min, y >= max);
  }

  bool _canMoveHorizontal(Offset move) {
    final hitHorizontalEdge = _hitHorizontalEdge();
    final mainAxisMove = move.dx;
    final crossAxisMove = move.dy;

    return _canMoveAxis(hitHorizontalEdge, mainAxisMove, crossAxisMove);
  }

  bool _canMoveVertical(Offset move) {
    final hitVerticalEdge = _hitVerticalEdge();
    final mainAxisMove = move.dy;
    final crossAxisMove = move.dx;

    return _canMoveAxis(hitVerticalEdge, mainAxisMove, crossAxisMove);
  }

  bool _canMoveAxis(
    _HitEdge hitEdge,
    double mainAxisMove,
    double crossAxisMove,
  ) {
    if (mainAxisMove == 0) {
      return false;
    }
    if (!hitEdge.hasHitAny) {
      return true;
    }
    final axisBlocked = hitEdge.hasHitBoth ||
        (hitEdge.hasHitMax ? mainAxisMove > 0 : mainAxisMove < 0);
    return !axisBlocked;
  }
}

class _HitEdge {
  const _HitEdge(this.hasHitMin, this.hasHitMax);

  final bool hasHitMin;
  final bool hasHitMax;

  bool get hasHitAny => hasHitMin || hasHitMax;

  bool get hasHitBoth => hasHitMin && hasHitMax;
}
