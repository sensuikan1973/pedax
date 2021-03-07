import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../engine/options/level_option.dart';
import '../models/board_notifier.dart';

@immutable
class LevelSettingDialog extends StatelessWidget {
  LevelSettingDialog({Key? key}) : super(key: key);

  final _option = const LevelOption();
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.levelSetting, textAlign: TextAlign.center),
        content: FutureBuilder<int>(
          future: _option.val,
          builder: (_, snapshot) {
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelOnDialog),
          ),
          TextButton(
            onPressed: () async {
              final n = int.tryParse(_textController.text);
              if (n != null && n > 0) {
                context.read<BoardNotifier>().requestSetOption(_option.nativeName, n.toString());
                await _option.update(n);
              }
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.updateSettingOnDialog),
          ),
        ],
      );
}
