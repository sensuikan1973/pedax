import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class BookLoadRequest implements RequestSchema {
  const BookLoadRequest(this.file);

  final String file;
}

@immutable
class BookLoadResponse extends ResponseSchema<BookLoadRequest> {
  const BookLoadResponse({
    required BookLoadRequest request,
  }) : super(request);
}

BookLoadResponse executeBookLoad(LibEdax edax, BookLoadRequest request) {
  edax
    ..edaxStop()
    ..edaxBookLoad(request.file);
  return BookLoadResponse(request: request);
}
