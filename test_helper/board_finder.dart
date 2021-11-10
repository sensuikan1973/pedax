import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:pedax/board/square.dart';

@isTest
void expectLastMove(final WidgetTester tester, final String coordinate) {
  final finder = findByCoordinate(coordinate);
  expect(finder, findsOneWidget);
  final square = tester.firstWidget<Square>(finder);
  expect(square.isLastMove, true);
}

@isTest
void expectStoneNum(final WidgetTester tester, final SquareType type, final int n) {
  final finder = _findSquareByType(type);
  expect(finder, findsWidgets);
  final squares = tester.widgetList<Square>(finder);
  expect(squares.length, n);
}

@isTest
void expectStoneCoordinates(final WidgetTester tester, final List<String> coordinates, final SquareType type) {
  final finders = coordinates
      .map(
        (final coordinate) => find.byWidgetPredicate((final widget) {
          if (widget is! Square) return false;
          final coordinateMatched =
              widget.coordinate == coordinate.toLowerCase() || widget.coordinate == coordinate.toUpperCase();
          return coordinateMatched && widget.type == type;
        }),
      )
      .toList();
  for (final finder in finders) {
    expect(finder, findsOneWidget);
  }
}

@isTest
Finder findByCoordinate(final String coordinate) => find.byWidgetPredicate((final widget) {
      if (widget is! Square) return false;
      return widget.coordinate == coordinate.toLowerCase() || widget.coordinate == coordinate.toUpperCase();
    });

Finder _findSquareByType(final SquareType type) => find.byWidgetPredicate((final widget) {
      if (widget is! Square) return false;
      return widget.type == type;
    });
