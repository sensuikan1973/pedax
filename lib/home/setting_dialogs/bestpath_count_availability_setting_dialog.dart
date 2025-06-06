import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedax/l10n/app_localizations.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:provider/provider.dart';

import '../../engine/options/pedax/bestpath_count_availability_option.dart';
import '../../engine/options/pedax/bestpath_count_opponent_lower_limit.dart';
import '../../engine/options/pedax/bestpath_count_player_lower_limit.dart';
import '../../models/board_notifier.dart';

class BestpathCountSettingDialog extends StatelessWidget {
  BestpathCountSettingDialog({super.key});

  BestpathCountAvailabilityOption get _availabilityOption => const BestpathCountAvailabilityOption();
  final _enabled = ValueNotifier<bool?>(null);

  BestpathCountPlayerLowerLimitOption get _playerLowerLimitOption => const BestpathCountPlayerLowerLimitOption();
  BestpathCountOpponentLowerLimitOption get _opponentLowerLimitOption => const BestpathCountOpponentLowerLimitOption();
  final _playerLowerLimitOptionTextController = TextEditingController();
  final _opponentLowerLimitOptionTextController = TextEditingController();

  final _hintTextOfLowerLimit = 'default is ${BookCountBoardBestPathLowerLimit.best.toString()} (= only best move)';

  @override
  Widget build(final BuildContext context) => AlertDialog(
    title: Text(AppLocalizations.of(context)!.bestpathCountSetting, textAlign: TextAlign.center),
    content: FutureBuilder<bool>(
      future: _availabilityOption.val,
      builder: (final context, final snapshot) {
        if (snapshot.hasData) _enabled.value = snapshot.data;
        return ValueListenableBuilder<bool?>(
          valueListenable: _enabled,
          builder: (final _, final value, final _) {
            if (value == null) return const CupertinoActivityIndicator();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.bestpathCountDescription),
                Switch(
                  value: _enabled.value!,
                  onChanged: (final value) async {
                    context.read<BoardNotifier>().switchCountBestpathAvailability(enabled: value);
                    await _availabilityOption.update(value);
                    _enabled.value = value;
                  },
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Text(AppLocalizations.of(context)!.bestpathCountPlayerLowerLimitDescription),
                FutureBuilder<List<int>>(
                  future: Future(
                    () async => Future.wait([_playerLowerLimitOption.val, _playerLowerLimitOption.appDefaultValue]),
                  ),
                  builder: (final _, final snapshot) {
                    if (snapshot.hasData) {
                      final currentPlayerLowerLimit = snapshot.data!.first.toString();
                      final playerLowerLimitAppDefault = snapshot.data![1].toString();
                      if (currentPlayerLowerLimit == playerLowerLimitAppDefault) {
                        _playerLowerLimitOptionTextController.text = '';
                      } else {
                        _playerLowerLimitOptionTextController.text = currentPlayerLowerLimit;
                      }
                    }
                    return TextFormField(
                      textAlign: TextAlign.center,
                      controller: _playerLowerLimitOptionTextController,
                      decoration: InputDecoration(hintText: _hintTextOfLowerLimit),
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (str) async {
                        final newPlayerLowerLimit = int.tryParse(str);
                        await _playerLowerLimitOption.update(
                          newPlayerLowerLimit ?? await _playerLowerLimitOption.appDefaultValue,
                        );
                      },
                    );
                  },
                ),
                Text(AppLocalizations.of(context)!.bestpathCountOpponentLowerLimitDescription),
                FutureBuilder<List<int>>(
                  future: Future(
                    () async => Future.wait([_opponentLowerLimitOption.val, _opponentLowerLimitOption.appDefaultValue]),
                  ),
                  builder: (final _, final snapshot) {
                    if (snapshot.hasData) {
                      final currentOpponentLowerLimit = snapshot.data!.first.toString();
                      final opponentLowerLimitAppDefault = snapshot.data![1].toString();
                      if (currentOpponentLowerLimit == opponentLowerLimitAppDefault) {
                        _opponentLowerLimitOptionTextController.text = '';
                      } else {
                        _opponentLowerLimitOptionTextController.text = currentOpponentLowerLimit;
                      }
                    }
                    return TextFormField(
                      textAlign: TextAlign.center,
                      controller: _opponentLowerLimitOptionTextController,
                      decoration: InputDecoration(hintText: _hintTextOfLowerLimit),
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (str) async {
                        final newOpponentLowerLimit = int.tryParse(str);
                        await _opponentLowerLimitOption.update(
                          newOpponentLowerLimit ?? await _opponentLowerLimitOption.appDefaultValue,
                        );
                      },
                    );
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
