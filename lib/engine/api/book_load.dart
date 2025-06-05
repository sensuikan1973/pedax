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
  const BookLoadResponse({required this.request, required this.success, this.errorMessage});

  @override
  final BookLoadRequest request;
  final bool success;
  final String? errorMessage;
}

BookLoadResponse executeBookLoad(final LibEdax edax, final BookLoadRequest request) {
  try {
    edax
      ..edaxStop()
      ..edaxBookLoad(request.file);
    return BookLoadResponse(request: request, success: true);
  } catch (e) {
    return BookLoadResponse(request: request, success: false, errorMessage: e.toString());
  }
}
