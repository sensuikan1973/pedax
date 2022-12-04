import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';

import 'pedax_shortcut.dart';

@immutable
class CaptureBoardImageShorcut implements PedaxShorcut {
  const CaptureBoardImageShorcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelCaptureBoardImageShorcut;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyP;

  String get _keyLabel => logicalKey.keyLabel.toUpperCase();

  @override
  String get keys => Platform.isMacOS ? '⌃$_keyLabel or ⌘$_keyLabel' : 'Ctrl + $_keyLabel';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      (keyEvent.isControlPressed && keyEvent.isKeyPressed(logicalKey)) ||
      (keyEvent.data.isModifierPressed(ModifierKey.metaModifier) && keyEvent.isKeyPressed(logicalKey));

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments argus) async {
    final boundary = argus.captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    // See: https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html
    final image = await boundary.toImage(pixelRatio: 3);
    final pngByteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = pngByteData!.buffer.asUint8List();

    final file = File('${(await _tmpDir).path}/board_for_clipboard.png');
    await file.writeAsBytes(pngBytes);
    await Pasteboard.writeFiles([file.path]);
  }

  Future<Directory> get _tmpDir async => getTemporaryDirectory();
}
