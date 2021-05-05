import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../board/pedax_shortcuts/pedax_shortcut.dart';

@immutable
class ShortcutCheatsheetDialog extends StatelessWidget {
  const ShortcutCheatsheetDialog({required this.shortcutList, Key? key}) : super(key: key);

  final List<PedaxShorcut> shortcutList;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.shortcutCheatsheet, textAlign: TextAlign.center),
        content: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(),
          children: List.generate(
            shortcutList.length,
            (k) => TableRow(
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
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<PedaxShorcut>('shortcutList', shortcutList));
  }
}
