sealed class PhotoViewScale {
  const PhotoViewScale();
  const factory PhotoViewScale.value(double scale) = PhotoViewScaleValue;
  const factory PhotoViewScale.contained() = PhotoViewScaleContained;
  const factory PhotoViewScale.covered() = PhotoViewScaleContained;

  PhotoViewScale operator *(double multiplier) {
    return switch (this) {
      PhotoViewScaleValue(:final scale) =>
        PhotoViewScaleValue(scale * multiplier),
      PhotoViewScaleContained(multiplier: final previous) =>
        PhotoViewScaleContained._(multiplier * previous),
      PhotoViewScaleCovered(multiplier: final previous) =>
        PhotoViewScaleCovered._(multiplier * previous),
    };
  }

  PhotoViewScale operator /(double divisor) {
    return switch (this) {
      PhotoViewScaleValue(:final scale) => PhotoViewScaleValue(scale / divisor),
      PhotoViewScaleContained(multiplier: final previous) =>
        PhotoViewScaleContained._(previous / divisor),
      PhotoViewScaleCovered(multiplier: final previous) =>
        PhotoViewScaleCovered._(previous / divisor),
    };
  }
}

class PhotoViewScaleValue extends PhotoViewScale {
  const PhotoViewScaleValue(this.scale);

  final double scale;
}

class PhotoViewScaleContained extends PhotoViewScale {
  const PhotoViewScaleContained() : multiplier = 1.0;
  const PhotoViewScaleContained._(this.multiplier);

  final double multiplier;
}

class PhotoViewScaleCovered extends PhotoViewScale {
  const PhotoViewScaleCovered() : multiplier = 1.0;
  const PhotoViewScaleCovered._(this.multiplier);

  final double multiplier;
}
