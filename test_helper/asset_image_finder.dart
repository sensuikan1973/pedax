import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Finder findByAssetKey(String key) => find.byWidgetPredicate((widget) {
      if (widget is Image && widget.image is AssetImage) {
        return (widget.image as AssetImage).keyName == 'assets/pedax_logo.png';
      }
      return false;
    });
