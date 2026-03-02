import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/windows/path.dart';

void main() {
  group('isWindowsAsciiPath', () {
    test('returns true for normal ASCII path', () {
      expect(isWindowsAsciiPath(r'C:\Users\alice\book.dat'), isTrue);
    });

    test('returns true for yen-separated path', () {
      expect(isWindowsAsciiPath('C:¥Users¥alice¥book.dat'), isTrue);
    });

    test('returns false for path including Japanese characters', () {
      expect(isWindowsAsciiPath(r'C:\Users\しみず\book.dat'), isFalse);
    });

    test('returns false for path including emoji', () {
      expect(isWindowsAsciiPath(r'C:\Users\alice\😀\book.dat'), isFalse);
    });
  });
}
