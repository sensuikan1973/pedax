import 'package:flutter/material.dart';
import 'package:pedax/l10n/app_localizations.dart';

import '../../board/pedax_shortcuts/pedax_shortcut.dart';

@immutable
class ShortcutCheatsheetDialog extends StatelessWidget {
  const ShortcutCheatsheetDialog({required this.shortcutList, super.key});

  final List<PedaxShortcut> shortcutList;

  @override
  Widget build(final BuildContext context) => AlertDialog(
    title: Text(AppLocalizations.of(context)!.shortcutCheatsheet, textAlign: TextAlign.center),
    content: SingleChildScrollView(
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(),
        children: List.generate(
          shortcutList.length,
          (final k) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  shortcutList[k].label(AppLocalizations.of(context)!),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(shortcutList[k].keys, textAlign: TextAlign.center, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
