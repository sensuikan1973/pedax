import 'package:file_selector/file_selector.dart';
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
  final _selectedFilePath = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bookFilePathSetting, textAlign: TextAlign.center),
        content: FutureBuilder<String>(
          future: _option.val,
          builder: (_, snapshot) {
            if (snapshot.hasData) _selectedFilePath.value = snapshot.data;
            return Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final typeGroup = XTypeGroup(label: 'edax book file', extensions: ['dat']);
                    final openedFile = await openFile(acceptedTypeGroups: [typeGroup]);
                    if (openedFile != null) _selectedFilePath.value = openedFile.path;
                  },
                  child: Text(AppLocalizations.of(context)!.chooseBookFile),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                ValueListenableBuilder<String?>(
                  valueListenable: _selectedFilePath,
                  builder: (_, value, __) {
                    if (value == null) return const Text(' ');
                    return Expanded(child: SelectableText(value));
                  },
                ),
              ],
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
              if (_selectedFilePath.value == null) return;

              final newBookFilePath = _selectedFilePath.value!;
              final currentBookFilePath = await _option.val;
              // ignore: use_build_context_synchronously
              if (newBookFilePath == currentBookFilePath) return Navigator.pop(context);

              await _option.update(newBookFilePath);
              // ignore: use_build_context_synchronously
              context.read<BoardNotifier>().requestBookLoad(await _option.val);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.updateSettingOnDialog),
          ),
        ],
      );
}
