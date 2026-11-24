import 'package:flutter/painting.dart';

extension ColorHex on Color {
  String get hex =>
      '#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
