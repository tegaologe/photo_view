import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PhotoViewController extends ChangeNotifier
    implements ValueListenable<PhotoViewControllerValue> {
  PhotoViewController({
    Offset initialPosition = Offset.zero,
    double initialRotation = 0.0,
    double? initialScale,
  }) : _value = PhotoViewControllerValue(
          position: initialPosition,
          rotation: initialRotation,
          scale: initialScale,
          rotationFocusPoint: null,
        );

  @override
  PhotoViewControllerValue get value => _value;
  late PhotoViewControllerValue _value;
  set value(PhotoViewControllerValue value) {
    if (_value == value) {
      return;
    }
    _value = value;
    notifyListeners();
  }

  /// Sets the controller's scale without updating any listeners.
  void initializeScale(double scale) {
    _value = _value.copyWith(scale: scale);
  }
}

@immutable
class PhotoViewControllerValue {
  const PhotoViewControllerValue({
    required this.position,
    required this.scale,
    required this.rotation,
    required this.rotationFocusPoint,
  });

  final Offset position;
  final double? scale;
  final double rotation;
  final Offset? rotationFocusPoint;

  PhotoViewControllerValue copyWith({
    Offset? position,
    double? scale,
    double? rotation,
    Offset? rotationFocusPoint,
  }) {
    return PhotoViewControllerValue(
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      rotationFocusPoint: rotationFocusPoint ?? this.rotationFocusPoint,
    );
  }

  @override
  bool operator ==(covariant PhotoViewControllerValue other) {
    if (identical(this, other)) return true;

    return other.position == position &&
        other.scale == scale &&
        other.rotation == rotation &&
        other.rotationFocusPoint == rotationFocusPoint;
  }

  @override
  int get hashCode {
    return position.hashCode ^
        scale.hashCode ^
        rotation.hashCode ^
        rotationFocusPoint.hashCode;
  }
}
