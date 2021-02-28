import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../engine/options/book_file_option.dart';
import '../models/board_notifier.dart';

@immutable
class BookFilePathSettingDialog extends StatelessWidget {
  BookFilePathSettingDialog({Key? key}) : super(key: key);

  final _option = const BookFileOption();
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bookFilePathSetting),
        content: FutureBuilder<String>(
          future: _option.val,
          builder: (_, snapshot) => Form(
            key: _formKey,
            child: TextFormField(
              controller: _textController..text = snapshot.hasData ? snapshot.data! : '',
              autofocus: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (path) {
                if (path == null) return null;
                if (path.isEmpty) return null; // use default book
                if (!File(path).existsSync()) return AppLocalizations.of(context)!.userSpecifiedFileNotFound;
              },
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelOnDialog),
          ),
          TextButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              final newBookFilePath = _textController.text;
              final currentBookFilePath = await _option.val;
              if (newBookFilePath == currentBookFilePath) return Navigator.pop(context);
              await _option.update(newBookFilePath);
              context.read<BoardNotifier>().requestBookLoad(await _option.val);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.updateSettingOnDialog),
          ),
        ],
      );
}
