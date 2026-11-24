import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';

class SplashState extends Equatable {
  final Uint8List? logo;
  final Uint8List? android12;
  final Uint8List? legacy;
  final double k;
  final double radius;
  final bool useIconBg;
  final Color splashColor;
  final Color splashColorDark;
  final Color iconBgColor;
  final bool busy;
  final String? message;

  const SplashState({
    this.logo,
    this.android12,
    this.legacy,
    this.k = 0.22,
    this.radius = 0,
    this.useIconBg = true,
    this.splashColor = const Color(0xFF002B36),
    this.splashColorDark = const Color(0xFF002B36),
    this.iconBgColor = const Color(0xFF1A3F46),
    this.busy = false,
    this.message,
  });

  // message is cleared on every copy unless passed again
  SplashState copyWith({
    Uint8List? logo,
    Uint8List? android12,
    Uint8List? legacy,
    double? k,
    double? radius,
    bool? useIconBg,
    Color? splashColor,
  Color?  splashColorDark,
    Color? iconBgColor,
    bool? busy,
    String? message,
  }) =>
      SplashState(
        logo: logo ?? this.logo,
        android12: android12 ?? this.android12,
        legacy: legacy ?? this.legacy,
        k: k ?? this.k,
        radius: radius ?? this.radius,
        useIconBg: useIconBg ?? this.useIconBg,
        splashColor: splashColor ?? this.splashColor,
    splashColorDark: splashColorDark ?? this.splashColorDark,
        iconBgColor: iconBgColor ?? this.iconBgColor,
        busy: busy ?? this.busy,
        message: message,
      );

  @override
  List<Object?> get props => [logo, android12, legacy, k, radius, useIconBg,
        splashColor, iconBgColor, busy, message,
                             splashColorDark
                             ];
}
