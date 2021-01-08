import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBoxShadow extends BoxShadow {
  final BlurStyle blurStyle;

  const CustomBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    this.blurStyle = BlurStyle.normal,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(this.blurStyle, blurSigma);
    assert(() {
      if (debugDisableShadows)
        result.maskFilter = null;
      return true;
    }());
    return result;
  }
}

final minaButtonDecoration = BoxDecoration(
  border: Border.all(color: Colors.black, width: 1),
  borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0.w), bottomRight: Radius.circular(4.0.w)),
  boxShadow: [
    CustomBoxShadow(color: Colors.black, offset: Offset(5.0, 2.9), blurStyle: BlurStyle.outer),
    CustomBoxShadow(color: Colors.white, offset: Offset(4.4, 2.4), blurStyle: BlurStyle.inner),
    CustomBoxShadow(color: Colors.white),
  ]
);