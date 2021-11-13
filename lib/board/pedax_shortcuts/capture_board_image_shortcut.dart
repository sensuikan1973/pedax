import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'pedax_shortcut.dart';

@immutable
class CaptureBoardImageShorcut implements PedaxShorcut {
  const CaptureBoardImageShorcut(this.screenshotController);

  final ScreenshotController screenshotController;

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelCaptureBoardImageShorcut;

  @override
  String get keys => Platform.isMacOS ? '⌃B or ⌘B' : 'Ctrl + B';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      (keyEvent.isControlPressed && keyEvent.isKeyPressed(LogicalKeyboardKey.keyB)) ||
      (keyEvent.data.isModifierPressed(ModifierKey.metaModifier) && keyEvent.isKeyPressed(LogicalKeyboardKey.keyB));

  @override
  Future<void> runEvent() async {
    const fileName = 'board_image_captured_by_pedax.png';
    final filePath = (await _docDir).path;
    await screenshotController.captureAndSave(filePath, fileName: fileName);
    final bytes = File('$filePath/$fileName').readAsBytesSync();
    final img64 = base64Encode(bytes);
    await Clipboard.setData(
      // ClipboardData(text: 'uri://$filePath/$fileName'),
      ClipboardData(text: 'data:image/png;base64,$img64'),
    );
  }

  Future<Directory> get _docDir async => getApplicationDocumentsDirectory();
}
