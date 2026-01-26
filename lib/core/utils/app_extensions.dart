import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

extension AppBuildeContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  TextTheme get textTheme => appTheme.textTheme;
  TextStyle get inputTextStyle => appTheme.textTheme.bodyLarge!.merge(
    GoogleFonts.prompt(
      fontSize: 14.sp,
    ),
  );
}
