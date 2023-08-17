import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:photo_view/src/utils/ignorable_change_notifier.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoViewControllerValue &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          scale == other.scale &&
          rotation == other.rotation &&
          rotationFocusPoint == other.rotationFocusPoint;

  @override
  int get hashCode =>
      position.hashCode ^
      scale.hashCode ^
      rotation.hashCode ^
      rotationFocusPoint.hashCode;
}

class PhotoViewController {
  PhotoViewController({
    Offset initialPosition = Offset.zero,
    double initialRotation = 0.0,
    double? initialScale,
  })  : _valueNotifier = IgnorableValueNotifier(
          PhotoViewControllerValue(
            position: initialPosition,
            rotation: initialRotation,
            scale: initialScale,
            rotationFocusPoint: null,
          ),
        ),
        super() {
    _initial = value;
    prevValue = _initial;

    _valueNotifier.addListener(_changeListener);
    _outputCtrl = StreamController<PhotoViewControllerValue>.broadcast();
    _outputCtrl.sink.add(_initial);
  }

  final IgnorableValueNotifier<PhotoViewControllerValue> _valueNotifier;

  late PhotoViewControllerValue _initial;

  late StreamController<PhotoViewControllerValue> _outputCtrl;

  Stream<PhotoViewControllerValue> get outputStateStream => _outputCtrl.stream;

  late PhotoViewControllerValue prevValue;

  void _changeListener() {
    _outputCtrl.sink.add(value);
  }

  void addIgnorableListener(VoidCallback callback) {
    _valueNotifier.addIgnorableListener(callback);
  }

  void removeIgnorableListener(VoidCallback callback) {
    _valueNotifier.removeIgnorableListener(callback);
  }

  void dispose() {
    _outputCtrl.close();
    _valueNotifier.dispose();
  }

  set position(Offset position) {
    if (value.position == position) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  Offset get position => value.position;

  set scale(double? scale) {
    if (value.scale == scale) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  double? get scale => value.scale;

  void setScaleInvisibly(double? scale) {
    if (value.scale == scale) {
      return;
    }
    prevValue = value;
    _valueNotifier.updateIgnoring(
      PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        rotationFocusPoint: rotationFocusPoint,
      ),
    );
  }

  set rotation(double rotation) {
    if (value.rotation == rotation) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  double get rotation => value.rotation;

  set rotationFocusPoint(Offset? rotationFocusPoint) {
    if (value.rotationFocusPoint == rotationFocusPoint) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  Offset? get rotationFocusPoint => value.rotationFocusPoint;

  void updateMultiple({
    Offset? position,
    double? scale,
    double? rotation,
    Offset? rotationFocusPoint,
  }) {
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position ?? value.position,
      scale: scale ?? value.scale,
      rotation: rotation ?? value.rotation,
      rotationFocusPoint: rotationFocusPoint ?? value.rotationFocusPoint,
    );
  }

  PhotoViewControllerValue get value => _valueNotifier.value;

  set value(PhotoViewControllerValue newValue) {
    if (_valueNotifier.value == newValue) {
      return;
    }
    _valueNotifier.value = newValue;
  }
}
