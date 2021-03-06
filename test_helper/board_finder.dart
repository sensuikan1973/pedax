import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/board/square.dart';
import 'package:meta/meta.dart';

@isTest
void expectLastMove(WidgetTester tester, String coordinate) {
  final finder = findByCoordinate(coordinate);
  expect(finder, findsOneWidget);
  final square = tester.firstWidget<Square>(finder);
  expect(square.isLastMove, true);
}

@isTest
void expectStoneNum(WidgetTester tester, SquareType type, int n) {
  final finder = _findSquareByType(type);
  expect(finder, findsWidgets);
  final squares = tester.widgetList<Square>(finder);
  expect(squares.length, n);
}

@isTest
void expectStoneCoordinate(WidgetTester tester, String coordinate, SquareType type) {
  final finder = find.byWidgetPredicate((widget) {
    if (widget is! Square) return false;
    return widget.coordinate == coordinate.toLowerCase() ||
        widget.coordinate == coordinate.toUpperCase() && widget.type == type;
  });
  expect(finder, findsOneWidget);
}

@isTest
Finder findByCoordinate(String coordinate) => find.byWidgetPredicate((widget) {
      if (widget is! Square) return false;
      return widget.coordinate == coordinate.toLowerCase() || widget.coordinate == coordinate.toUpperCase();
    });

Finder _findSquareByType(SquareType type) => find.byWidgetPredicate((widget) {
      if (widget is! Square) return false;
      return widget.type == type;
    });
