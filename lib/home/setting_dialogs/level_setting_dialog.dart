import 'package:flutter/material.dart';
import 'package:pedax/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../engine/options/native/level_option.dart';
import '../../models/board_notifier.dart';

@immutable
class LevelSettingDialog extends StatelessWidget {
  LevelSettingDialog({super.key});

  final _option = const LevelOption();
  final _textController = TextEditingController();

  @override
  Widget build(final BuildContext context) => AlertDialog(
    title: Text(AppLocalizations.of(context)!.levelSetting, textAlign: TextAlign.center),
    content: FutureBuilder<int>(
      future: _option.val,
      builder: (final _, final snapshot) {
        if (snapshot.hasData) _textController.text = snapshot.data!.toString();
        return TextFormField(
          controller: _textController,
          autofocus: true,
          keyboardType: TextInputType.number,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        );
      },
    ),
    actions: <Widget>[
      TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancelOnDialog)),
      TextButton(
        onPressed: () {
          final n = int.tryParse(_textController.text);
          if (n != null && n > 0) {
            context.read<BoardNotifier>().requestSetOption(_option.nativeName, n.toString());
            Future(() async => _option.update(n));
          }
          Navigator.pop(context);
        },
        child: Text(AppLocalizations.of(context)!.updateSettingOnDialog),
      ),
    ],
  );
}
