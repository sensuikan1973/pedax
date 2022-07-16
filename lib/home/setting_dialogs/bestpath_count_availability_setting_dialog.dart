import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:libedax4dart/libedax4dart.dart';
import 'package:provider/provider.dart';

import '../../engine/options/pedax/bestpath_count_availability_option.dart';
import '../../engine/options/pedax/bestpath_count_opponent_lower_limit.dart';
import '../../engine/options/pedax/bestpath_count_player_lower_limit.dart';
import '../../models/board_notifier.dart';

class BestpathCountAvailabilitySettingDialog extends StatelessWidget {
  BestpathCountAvailabilitySettingDialog({super.key});

  BestpathCountAvailabilityOption get _availabilityOption => const BestpathCountAvailabilityOption();
  final _enabled = ValueNotifier<bool?>(null);

  BestpathCountPlayerLowerLimitOption get _playerLowerLimitOption => const BestpathCountPlayerLowerLimitOption();
  BestpathCountOpponentLowerLimitOption get _opponentLowerLimitOption => const BestpathCountOpponentLowerLimitOption();
  final _playerLowerLimitOptionTextController = TextEditingController();
  final _opponentLowerLimitOptionTextController = TextEditingController();

  final _hintTextOfLowerLimit = 'default is ${BookCountBoardBestPathLowerLimit.best.toString()} (= only best move)';

  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bestpathCountAvailabilitySetting, textAlign: TextAlign.center),
        content: FutureBuilder<bool>(
          future: _availabilityOption.val,
          builder: (final context, final snapshot) {
            if (snapshot.hasData) _enabled.value = snapshot.data;
            return ValueListenableBuilder<bool?>(
              valueListenable: _enabled,
              builder: (final _, final value, final __) {
                if (value == null) return const CupertinoActivityIndicator();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.bestpathCountAvailabilityDescription),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Switch(
                      value: _enabled.value!,
                      onChanged: (final value) {
                        context.read<BoardNotifier>().switchCountBestpathAvailability(enabled: value);
                        _availabilityOption.update(value);
                        _enabled.value = value;
                      },
                    ),
                    const Divider(),
                    Text(AppLocalizations.of(context)!.bestpathCountPlayerLowerLimitDescription),
                    FutureBuilder<int>(
                      future: _playerLowerLimitOption.val,
                      builder: (final _, final snapshot) {
                        if (snapshot.hasData) _playerLowerLimitOptionTextController.text = snapshot.data!.toString();
                        return TextFormField(
                          textAlign: TextAlign.center,
                          controller: _playerLowerLimitOptionTextController,
                          autofocus: true,
                          decoration: InputDecoration(hintText: _hintTextOfLowerLimit),
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        );
                      },
                    ),
                    Text(AppLocalizations.of(context)!.bestpathCountOpponentLowerLimitDescription),
                    FutureBuilder<int>(
                      future: _opponentLowerLimitOption.val,
                      builder: (final _, final snapshot) {
                        if (snapshot.hasData) _opponentLowerLimitOptionTextController.text = snapshot.data!.toString();
                        return TextFormField(
                          textAlign: TextAlign.center,
                          controller: _opponentLowerLimitOptionTextController,
                          autofocus: true,
                          decoration: InputDecoration(hintText: _hintTextOfLowerLimit),
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () async {
                        final playerLowerLimit = int.tryParse(_playerLowerLimitOptionTextController.text);
                        if (playerLowerLimit != null) {
                          await _playerLowerLimitOption.update(playerLowerLimit);
                        }
                        final opponentLowerLimit = int.tryParse(_opponentLowerLimitOptionTextController.text);
                        if (opponentLowerLimit != null) {
                          await _opponentLowerLimitOption.update(opponentLowerLimit);
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.bestpathCountLowerLimitSaveButton),
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
}
