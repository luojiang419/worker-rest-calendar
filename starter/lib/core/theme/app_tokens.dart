import 'package:flutter/material.dart';

@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({
    required this.low,
    required this.medium,
    required this.high,
  });

  final List<BoxShadow> low;
  final List<BoxShadow> medium;
  final List<BoxShadow> high;

  static const light = AppShadows(
    low: [
      BoxShadow(color: Color(0x0F14233C), blurRadius: 8, offset: Offset(0, 2)),
    ],
    medium: [
      BoxShadow(color: Color(0x1A14233C), blurRadius: 24, offset: Offset(0, 8)),
      BoxShadow(color: Color(0x0D14233C), blurRadius: 8, offset: Offset(0, 2)),
    ],
    high: [
      BoxShadow(
        color: Color(0x2914233C),
        blurRadius: 44,
        offset: Offset(0, 18),
      ),
    ],
  );

  static const dark = AppShadows(
    low: [
      BoxShadow(color: Color(0x47000000), blurRadius: 10, offset: Offset(0, 4)),
    ],
    medium: [
      BoxShadow(
        color: Color(0x73000000),
        blurRadius: 30,
        offset: Offset(0, 12),
      ),
    ],
    high: [
      BoxShadow(
        color: Color(0x94000000),
        blurRadius: 48,
        offset: Offset(0, 20),
      ),
    ],
  );

  @override
  AppShadows copyWith({
    List<BoxShadow>? low,
    List<BoxShadow>? medium,
    List<BoxShadow>? high,
  }) => AppShadows(
    low: low ?? this.low,
    medium: medium ?? this.medium,
    high: high ?? this.high,
  );

  @override
  AppShadows lerp(covariant AppShadows? other, double t) => this;
}
