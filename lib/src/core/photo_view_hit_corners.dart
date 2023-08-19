import 'package:flutter/widgets.dart';
import 'package:photo_view/src/controller/photo_view_controller_delegate.dart'
    show PhotoViewControllerDelegate;

mixin HitCornersDetector on PhotoViewControllerDelegate {
  bool shouldMove(Offset move, Axis mainAxis) {
    return switch (mainAxis) {
      Axis.horizontal => _shouldMoveX(move),
      Axis.vertical => _shouldMoveY(move),
    };
  }

  HitCorners _hitCornersX() {
    final childWidth = scaleBoundaries.childSize.width * scale;
    final screenWidth = scaleBoundaries.outerSize.width;
    if (screenWidth >= childWidth) {
      return const HitCorners(true, true);
    }
    final x = -position.dx;
    final (min, max) = cornersX();
    return HitCorners(x <= min, x >= max);
  }

  HitCorners _hitCornersY() {
    final childHeight = scaleBoundaries.childSize.height * scale;
    final screenHeight = scaleBoundaries.outerSize.height;
    if (screenHeight >= childHeight) {
      return const HitCorners(true, true);
    }
    final y = -position.dy;
    final (min, max) = cornersY();
    return HitCorners(y <= min, y >= max);
  }

  bool _shouldMoveAxis(
    HitCorners hitCorners,
    double mainAxisMove,
    double crossAxisMove,
  ) {
    if (mainAxisMove == 0) {
      return false;
    }
    if (!hitCorners.hasHitAny) {
      return true;
    }
    final axisBlocked = hitCorners.hasHitBoth ||
        (hitCorners.hasHitMax ? mainAxisMove > 0 : mainAxisMove < 0);
    if (axisBlocked) {
      return false;
    }
    return true;
  }

  bool _shouldMoveX(Offset move) {
    final hitCornersX = _hitCornersX();
    final mainAxisMove = move.dx;
    final crossAxisMove = move.dy;

    return _shouldMoveAxis(hitCornersX, mainAxisMove, crossAxisMove);
  }

  bool _shouldMoveY(Offset move) {
    final hitCornersY = _hitCornersY();
    final mainAxisMove = move.dy;
    final crossAxisMove = move.dx;

    return _shouldMoveAxis(hitCornersY, mainAxisMove, crossAxisMove);
  }
}

class HitCorners {
  const HitCorners(this.hasHitMin, this.hasHitMax);

  final bool hasHitMin;
  final bool hasHitMax;

  bool get hasHitAny => hasHitMin || hasHitMax;

  bool get hasHitBoth => hasHitMin && hasHitMax;
}
