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
class BookLoadResponse implements ResponseSchema<BookLoadRequest> {
  const BookLoadResponse({required final this.request});

  @override
  final BookLoadRequest request;
}

BookLoadResponse executeBookLoad(final LibEdax edax, final BookLoadRequest request) {
  edax
    ..edaxStop()
    ..edaxBookLoad(request.file);
  return BookLoadResponse(request: request);
}
