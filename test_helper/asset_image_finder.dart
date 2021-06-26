import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTest
Finder findByAssetKey(final String key) => find.byWidgetPredicate((final widget) {
      if (widget is! Image) return false;
      if (widget.image is AssetImage) return (widget.image as AssetImage).keyName == key;
      if (widget.image is ResizeImage) {
        final resizeImage = widget.image as ResizeImage;
        return (resizeImage.imageProvider as AssetImage).keyName == key;
      }
      return false;
    });
