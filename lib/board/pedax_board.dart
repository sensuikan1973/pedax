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
import '../engine/api/redo.dart';
import '../engine/api/set_option.dart';
import '../engine/api/stop.dart';
import '../engine/api/undo.dart';
import '../engine/options/book_file_option.dart';
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

  @override
  void initState() {
    super.initState();
    widget.edaxServerParentPort.listen(_updateStateByEdaxServerMessage);
    widget.edaxServerPort.send(const InitRequest());
    const BookFileOption().val.then(
      (path) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
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

  // ignore: avoid_annotating_with_dynamic
  void _updateStateByEdaxServerMessage(dynamic message) {
    _logger.i('received response "${message.runtimeType}"');
    if (message is MoveResponse) {
      if (_currentMoves != message.moves) {
        _hints.clear();
        widget.edaxServerPort.send(const HintOneByOneRequest());
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
        widget.edaxServerPort.send(const HintOneByOneRequest());
      }
      setState(() {
        _hints.clear();
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
        widget.edaxServerPort.send(const HintOneByOneRequest());
      }
      setState(() {
        _hints.clear();
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
        _hints.add(message.hint);
        _bestScore = _hints.map<int>((h) => h.score).reduce(max);
      });
    } else if (message is BookLoadResponse) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.finishedLoadingBookFile, textAlign: TextAlign.center),
        ),
      );
    } else if (message is SetOptionResponse) {
      // for now, nothing
    } else if (message is StopResponse) {
      // for now, nothing
    } else {
      final str = 'response "${message.runtimeType}" is not unexpected';
      _logger.e(str);
      throw Exception(str);
    }
  }

  void _handleRawKeyEvent(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.keyU)) widget.edaxServerPort.send(const UndoRequest());
    if (event.isKeyPressed(LogicalKeyboardKey.keyR)) widget.edaxServerPort.send(const RedoRequest());
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
      future: _edaxInit.future,
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CupertinoActivityIndicator());
        return SizedBox(
          height: widget.length,
          width: widget.length,
          child: Table(
            border: TableBorder.all(),
            children: List.generate(
              _boardSize,
              (yIndex) => TableRow(
                children: List.generate(
                  _boardSize,
                  (xIndex) => _square(yIndex, xIndex),
                ),
              ),
            ),
          ),
        );
      });

  int get _boardSize => 8;
  double get _stoneMargin => (widget.length / _boardSize) * 0.1;
  double get _stoneSize => (widget.length / _boardSize) - (_stoneMargin * 2);

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
