import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import '../engine/api/book_load.dart';
import '../engine/api/hint_one_by_one.dart';
import '../engine/api/init.dart';
import '../engine/api/move.dart';
import '../engine/api/play.dart';
import '../engine/api/redo.dart';
import '../engine/api/undo.dart';
import '../engine/options/book_file_option.dart';
import '../engine/options/hint_step_by_step_option.dart';
import '../engine/options/level_option.dart';
import 'square.dart';

class PedaxBoard extends StatefulWidget {
  const PedaxBoard(this.edaxServerPort, this.edaxServerParentPort, this.length, {Key? key}) : super(key: key);

  final SendPort edaxServerPort;
  final Stream<dynamic> edaxServerParentPort;
  final double length;

  @override
  _PedaxBoardState createState() => _PedaxBoardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<SendPort>('edaxServerPort', edaxServerPort))
      ..add(DiagnosticsProperty<Stream>('edaxServerParentPort', edaxServerParentPort))
      ..add(DoubleProperty('length', length));
  }
}

class _PedaxBoardState extends State<PedaxBoard> {
  late Board _board;
  late List<int> _squaresOfPlayer;
  late List<int> _squaresOfOpponent;
  late int _currentColor;
  late Move? _lastMove;
  late String _currentMoves;
  final List<Hint> _hints = [];
  int _bestScore = 0;
  final Completer<bool> _edaxInit = Completer<bool>();
  final _logger = Logger();
  final _hintStepByStepOption = const HintStepByStepOption();
  final _levelOption = const LevelOption();

  int get _boardSize => 8;
  double get _stoneMargin => (widget.length / _boardSize) * 0.1;
  double get _stoneSize => (widget.length / _boardSize) - (_stoneMargin * 2);

  @override
  void initState() {
    super.initState();
    widget.edaxServerParentPort.listen(_updateStateByEdaxServerMessage);
    widget.edaxServerPort.send(const InitRequest());
    const BookFileOption().val.then(
      (path) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.loadingBookFile, textAlign: TextAlign.center),
              duration: const Duration(minutes: 1),
            ),
          );
          widget.edaxServerPort.send(BookLoadRequest(path));
        });
      },
    );
    RawKeyboard.instance.addListener(_handleRawKeyEvent);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
      future: _edaxInit.future,
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CupertinoActivityIndicator());
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _xCoordinateLabels,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _yCoordinateLabels,
                _boardBody,
                _yCoordinatePadding,
              ],
            ),
          ],
        );
      });

  Widget get _xCoordinateLabels => SizedBox(
        width: widget.length / _boardSize * 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', ' ']
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(e),
                  ))
              .toList(),
        ),
      );

  Widget get _yCoordinateLabels => SizedBox(
        height: widget.length,
        width: widget.length / _boardSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            _boardSize,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text((i + 1).toString()),
            ),
          ),
        ),
      );

  SizedBox get _yCoordinatePadding => SizedBox(
        height: widget.length,
        width: widget.length / _boardSize,
      );

  SizedBox get _boardBody => SizedBox(
        height: widget.length,
        width: widget.length,
        child: Table(
          border: TableBorder.all(),
          children: List.generate(
            _boardSize,
            (yIndex) => TableRow(
              children: List.generate(_boardSize, (xIndex) => _square(yIndex, xIndex)),
            ),
          ),
        ),
      );

  Future<HintOneByOneRequest> get _buildHintRequest async => HintOneByOneRequest(
        level: await _levelOption.val,
        stepByStep: await _hintStepByStepOption.val,
      );

  // ignore: avoid_annotating_with_dynamic
  Future<void> _updateStateByEdaxServerMessage(dynamic message) async {
    _logger.i('received response "${message.runtimeType}"');
    if (message is MoveResponse) {
      if (_currentMoves != message.moves) {
        _hints.clear();
        widget.edaxServerPort.send(await _buildHintRequest);
      }
      setState(() {
        _board = message.board;
        _squaresOfPlayer = _board.squaresOfPlayer;
        _squaresOfOpponent = _board.squaresOfOpponent;
        _currentColor = message.currentColor;
        _lastMove = message.lastMove;
        _currentMoves = message.moves;
      });
    } else if (message is PlayResponse) {
      if (_currentMoves != message.moves) {
        _hints.clear();
        widget.edaxServerPort.send(await _buildHintRequest);
      }
      setState(() {
        _board = message.board;
        _squaresOfPlayer = _board.squaresOfPlayer;
        _squaresOfOpponent = _board.squaresOfOpponent;
        _currentColor = message.currentColor;
        _lastMove = message.lastMove;
        _currentMoves = message.moves;
      });
    } else if (message is InitResponse) {
      _edaxInit.complete(true);
      setState(() {
        _hints.clear();
        _board = message.board;
        _squaresOfPlayer = _board.squaresOfPlayer;
        _squaresOfOpponent = _board.squaresOfOpponent;
        _currentColor = message.currentColor;
        _lastMove = message.lastMove;
        _currentMoves = message.moves;
      });
    } else if (message is UndoResponse) {
      if (_currentMoves != message.moves) {
        _hints.clear();
        widget.edaxServerPort.send(await _buildHintRequest);
      }
      setState(() {
        _board = message.board;
        _squaresOfPlayer = _board.squaresOfPlayer;
        _squaresOfOpponent = _board.squaresOfOpponent;
        _currentColor = message.currentColor;
        _lastMove = message.lastMove;
        _currentMoves = message.moves;
      });
    } else if (message is RedoResponse) {
      if (_currentMoves != message.moves) {
        _hints.clear();
        widget.edaxServerPort.send(await _buildHintRequest);
      }
      setState(() {
        _board = message.board;
        _squaresOfPlayer = _board.squaresOfPlayer;
        _squaresOfOpponent = _board.squaresOfOpponent;
        _currentColor = message.currentColor;
        _lastMove = message.lastMove;
        _currentMoves = message.moves;
      });
    } else if (message is HintOneByOneResponse) {
      setState(() {
        _logger.d('${message.hint.moveString}: ${message.hint.scoreString}');
        if (message.searchTargetMoves != _currentMoves) return _hints.clear();
        _hints
          ..removeWhere((hint) => hint.move == message.hint.move)
          ..add(message.hint);
        _bestScore = _hints.map<int>((h) => h.score).reduce(max);
      });
    } else if (message is BookLoadResponse) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.finishedLoadingBookFile, textAlign: TextAlign.center),
        ),
      );
    }
  }

  Future<void> _handleRawKeyEvent(RawKeyEvent event) async {
    if (event.isKeyPressed(LogicalKeyboardKey.keyU)) widget.edaxServerPort.send(const UndoRequest());
    if (event.isKeyPressed(LogicalKeyboardKey.keyR)) widget.edaxServerPort.send(const RedoRequest());
    if ((event.isControlPressed && event.isKeyPressed(LogicalKeyboardKey.keyC)) ||
        (event.data.isModifierPressed(ModifierKey.metaModifier) && event.isKeyPressed(LogicalKeyboardKey.keyC))) {
      await Clipboard.setData(ClipboardData(text: _currentMoves));
    }
    if ((event.isControlPressed && event.isKeyPressed(LogicalKeyboardKey.keyV)) ||
        (event.data.isModifierPressed(ModifierKey.metaModifier) && event.isKeyPressed(LogicalKeyboardKey.keyV))) {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData == null || clipboardData.text == null) return;
      widget.edaxServerPort.send(PlayRequest(clipboardData.text!));
    }
  }

  Square _square(int y, int x) {
    final move = y * 8 + x;
    final type = _squareType(move);
    final moveString = move2String(move);
    final targetHints = _hints.where((h) => h.move == move).toList();
    final hint = targetHints.isEmpty ? null : targetHints.first;
    return Square(
      type: type,
      length: _stoneSize,
      margin: _stoneMargin,
      coordinate: moveString,
      isLastMove: _lastMove?.x == move,
      isBookMove: hint != null && hint.isBookMove,
      score: hint?.score,
      scoreColor: _scoreColor(hint?.score, hint?.score == _bestScore),
      onTap: type != SquareType.empty ? null : () => _squareOnTap(moveString),
    );
  }

  void _squareOnTap(String moveString) {
    widget.edaxServerPort.send(MoveRequest(moveString));
  }

  SquareType _squareType(int move) {
    final isBlackTurn = _currentColor == TurnColor.black;
    if (_squaresOfPlayer.contains(move)) {
      return isBlackTurn ? SquareType.black : SquareType.white;
    }
    if (_squaresOfOpponent.contains(move)) {
      return isBlackTurn ? SquareType.white : SquareType.black;
    }
    return SquareType.empty;
  }

  Color? _scoreColor(int? score, bool bestMove) {
    if (score == null) return null;
    if (score == 0) {
      if (bestMove) return Colors.cyan;
      return Colors.cyan[900];
    } else if (score > 0) {
      if (bestMove) return Colors.blue;
      return Colors.blue[900];
    } else /* score < 0*/ {
      if (bestMove) return Colors.lime;
      return Colors.lime[900];
    }
  }
}
