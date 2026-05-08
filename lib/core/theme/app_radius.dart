import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double xs = 2;
  static const double xsm = 4;
  static const double sm = 8;
  static const double smd = 10;
  static const double md = 12;
  static const double msl = 14;
  static const double lg = 16;
  static const double xl = 24;
  static const double xlg = 20;
  static const double full = 9999;

  static BorderRadius get xsBorder => BorderRadius.circular(xs);
  static BorderRadius get xsmBorder => BorderRadius.circular(xsm);
  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get smdBorder => BorderRadius.circular(smd);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get mslBorder => BorderRadius.circular(msl);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get xlBorder => BorderRadius.circular(xl);
  static BorderRadius get xlgBorder => BorderRadius.circular(xlg);
  static BorderRadius get fullBorder => BorderRadius.circular(full);
}
