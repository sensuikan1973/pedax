import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../engine/options/best_path_num_availability_option.dart';
import '../models/board_notifier.dart';

class BestPathNumAvailabilitySettingDialog extends StatelessWidget {
  BestPathNumAvailabilitySettingDialog({Key? key}) : super(key: key);

  BestPathNumAvailabilityOption get _option => const BestPathNumAvailabilityOption();
  final _enabled = ValueNotifier<bool?>(null);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bestPathNumAvailabilitySetting, textAlign: TextAlign.center),
        content: FutureBuilder<bool>(
          future: _option.val,
          builder: (context, snapshot) {
            if (snapshot.hasData) _enabled.value = snapshot.data;
            return ValueListenableBuilder<bool?>(
              valueListenable: _enabled,
              builder: (_, value, __) {
                if (value == null) return const CupertinoActivityIndicator();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.bestPathNumAvailabilityDescription),
                    Switch(
                      value: _enabled.value!,
                      onChanged: (value) {
                        context.read<BoardNotifier>().switchBestPathNumAvailability(enabled: value);
                        _option.update(value);
                        _enabled.value = value;
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
}
