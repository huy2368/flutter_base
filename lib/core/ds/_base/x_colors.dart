import 'package:flutter/widgets.dart';

/*
  Hex opacity:
100% — FF
95% — F2
90% — E6
85% — D9
80% — CC
75% — BF
70% — B3
65% — A6
60% — 99
55% — 8C
50% — 80
45% — 73
40% — 66
35% — 59
30% — 4D
25% — 40
20% — 33
15% — 26
10% — 1A
5% — 0D
0% — 00
  */

extension OpacityExt on Color {
  Color get o1 => withValues(alpha: 0.1);

  Color get o20 => withValues(alpha: 0.2);

  Color get o24 => withValues(alpha: 0.24);

  Color get o30 => withValues(alpha: 0.3);

  Color get o35 => withValues(alpha: 0.35);

  Color get o4 => withValues(alpha: 0.4);

  Color get o5 => withValues(alpha: 0.5);

  Color get o60 => withValues(alpha: 0.6);

  Color get o65 => withValues(alpha: 0.65);

  Color get o7 => withValues(alpha: 0.7);

  Color get o80 => withValues(alpha: 0.8);

  Color get o9 => withValues(alpha: 0.9);
}
