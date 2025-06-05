import 'package:meta/meta.dart';

@immutable
class BookLoadStatusNotification {
  const BookLoadStatusNotification({required this.status});
  final String status;
}
