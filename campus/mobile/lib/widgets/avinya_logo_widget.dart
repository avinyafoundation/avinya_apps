import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget avinyaLogoImage() {
  return Image.asset(
    'assets/images/avinya_logo.png',
    width: SizerUtil.deviceType == DeviceType.tablet ? 13.w : 11.w,
    height: SizerUtil.deviceType == DeviceType.tablet ? 13.h : 11.h,
    fit: BoxFit.contain,
  );
}
