import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/src/controller/photo_view_edge_detector.dart';

class PhotoViewGestureDetector extends StatelessWidget {
  const PhotoViewGestureDetector({
    super.key,
    required this.edgeDetector,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
    required this.child,
    required this.onTapUp,
    required this.onTapDown,
  });

  final PhotoViewEdgeDetector edgeDetector;
  final GestureScaleStartCallback? onScaleStart;
  final GestureScaleUpdateCallback? onScaleUpdate;
  final GestureScaleEndCallback? onScaleEnd;
  final GestureTapUpCallback? onTapUp;
  final GestureTapDownCallback? onTapDown;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final axis = PhotoViewGestureDetectorScope.maybeOf(context);

    return RawGestureDetector(
      gestures: {
        if (onTapDown != null || onTapUp != null)
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            () => TapGestureRecognizer(debugOwner: this),
            (instance) => instance
              ..onTapDown = onTapDown
              ..onTapUp = onTapUp,
          ),
        _PhotoViewGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_PhotoViewGestureRecognizer>(
          () => _PhotoViewGestureRecognizer(
            edgeDetector: edgeDetector,
            validateAxis: axis,
          ),
          (instance) => instance
            ..dragStartBehavior = DragStartBehavior.start
            ..onStart = onScaleStart
            ..onUpdate = onScaleUpdate
            ..onEnd = onScaleEnd,
        ),
      },
      child: child,
    );
  }
}

class _PhotoViewGestureRecognizer extends ScaleGestureRecognizer {
  _PhotoViewGestureRecognizer({
    required this.edgeDetector,
    required this.validateAxis,
  });

  final PhotoViewEdgeDetector edgeDetector;
  final Axis? validateAxis;

  final _pointerLocations = <int, Offset>{};

  Offset? _initialFocalPoint;
  Offset? _currentFocalPoint;

  bool ready = true;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);

    if (ready) {
      ready = false;
      _pointerLocations.clear();
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    super.didStopTrackingLastPointer(pointer);

    ready = true;
  }

  @override
  void handleEvent(PointerEvent event) {
    if (validateAxis != null) {
      _computeEvent(event);
      _updateDistances();
      _decideIfWeAcceptEvent(event);
    }

    super.handleEvent(event);
  }

  void _computeEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (!event.synthesized) {
        _pointerLocations[event.pointer] = event.position;
      }
    } else if (event is PointerDownEvent) {
      _pointerLocations[event.pointer] = event.position;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerLocations.remove(event.pointer);
    }

    _initialFocalPoint = _currentFocalPoint;
  }

  void _updateDistances() {
    final count = _pointerLocations.keys.length;
    var focalPoint = Offset.zero;

    for (final pointer in _pointerLocations.keys) {
      focalPoint += _pointerLocations[pointer]!;
    }

    _currentFocalPoint =
        count > 0 ? focalPoint / count.toDouble() : Offset.zero;
  }

  void _decideIfWeAcceptEvent(PointerEvent event) {
    if (event is! PointerMoveEvent) {
      return;
    }

    final move = _initialFocalPoint! - _currentFocalPoint!;
    final shouldMove = edgeDetector.canMove(move, validateAxis!);

    if (shouldMove || _pointerLocations.keys.length > 1) {
      acceptGesture(event.pointer);
    }
  }
}

/// An [InheritedWidget] responsible to give a axis aware scope to
/// [_PhotoViewGestureRecognizer].
///
/// When using this, PhotoView will test if the content zoomed has hit edge
/// every time user pinches, if so, it will let parent gesture detectors win the gesture arena
///
/// Useful when placing PhotoView inside a gesture sensitive context,
/// such as [PageView], [Dismissible], [BottomSheet].
class PhotoViewGestureDetectorScope extends InheritedWidget {
  const PhotoViewGestureDetectorScope({
    super.key,
    this.axis,
    required super.child,
  });

  final Axis? axis;

  static Axis? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PhotoViewGestureDetectorScope>()
        ?.axis;
  }

  @override
  bool updateShouldNotify(PhotoViewGestureDetectorScope oldWidget) {
    return axis != oldWidget.axis;
  }
}
