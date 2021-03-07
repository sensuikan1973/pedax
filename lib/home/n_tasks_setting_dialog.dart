import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../engine/options/n_tasks_option.dart';
import '../models/board_notifier.dart';

@immutable
class NTasksSettingDialog extends StatelessWidget {
  NTasksSettingDialog({Key? key}) : super(key: key);

  final _option = const NTasksOption();
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.nTasksSetting, textAlign: TextAlign.center),
        content: FutureBuilder<int>(
          future: _option.val,
          builder: (_, snapshot) {
            if (snapshot.hasData) _textController.text = snapshot.data!.toString();
            return TextFormField(
              controller: _textController,
              autofocus: true,
              decoration: InputDecoration(hintText: '1 ~ ${Platform.numberOfProcessors}'),
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
              if (n != null) {
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
