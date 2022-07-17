import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class CaptureBoardImageShorcut implements PedaxShorcut {
  const CaptureBoardImageShorcut(this.boardNotifier);

  @override
  final BoardNotifier boardNotifier;

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelCaptureBoardImageShorcut;

  @override
  String get keys => Platform.isMacOS ? '⌃P or ⌘P' : 'Ctrl + P';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      (keyEvent.isControlPressed && keyEvent.isKeyPressed(LogicalKeyboardKey.keyP)) ||
      (keyEvent.data.isModifierPressed(ModifierKey.metaModifier) && keyEvent.isKeyPressed(LogicalKeyboardKey.keyP));

  @override
  Future<void> runEvent() async {}

  Future<void> runEventWithWidget(final GlobalKey captureKey) async {
    final boundary = captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    // See: https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html
    final image = await boundary.toImage(pixelRatio: 3);
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

    final file = File('${(await _tmpDir).path}/board_for_clipboard.png');
    await file.writeAsBytes(pngBytes!.buffer.asUint8List(pngBytes.offsetInBytes, pngBytes.lengthInBytes));
    await Pasteboard.writeFiles([file.path]);
  }

  Future<Directory> get _tmpDir async => getTemporaryDirectory();
}
