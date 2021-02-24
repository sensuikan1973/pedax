import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

final _logger = Logger();

@immutable
class BookShowRequest extends RequestSchema {
  const BookShowRequest();

  @override
  String get name => 'bookShow';
}

@immutable
class BookShowResponse extends ResponseSchema<BookShowRequest> {
  const BookShowResponse({
    required this.position,
    required BookShowRequest request,
  }) : super(request);

  final Position position;
}

BookShowResponse executeBookShow(LibEdax edax, BookShowRequest request) =>
    BookShowResponse(position: edax.edaxBookShow(), request: request);
