// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
//import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';

/// The maximum width taken up by each item on the home screen.
const maxHomeItemWidth = 1400.0;

/// Adaptive Window in Material has five different window sizes.
/// See: https://material.io/design/layout/responsive-layout-grid.html#breakpoints
class AdaptiveWindowType {
  const AdaptiveWindowType._({
    required this.name,
    required this.relativeSize,
    required this.widthRangeValues,
    required this.heightLandscapeRangeValues,
    required this.heightPortraitRangeValues,
  });

  final String name;
  final int relativeSize;
  final RangeValues widthRangeValues;
  final RangeValues heightLandscapeRangeValues;
  final RangeValues heightPortraitRangeValues;

  static const AdaptiveWindowType xsmall = AdaptiveWindowType._(
    name: 'xsmall',
    relativeSize: 0,
    widthRangeValues: RangeValues(0, 599),
    heightLandscapeRangeValues: RangeValues(0, 359),
    heightPortraitRangeValues: RangeValues(0, 959),
  );

  static const AdaptiveWindowType small = AdaptiveWindowType._(
    name: 'small',
    relativeSize: 1,
    widthRangeValues: RangeValues(600, 1023),
    heightLandscapeRangeValues: RangeValues(360, 719),
    heightPortraitRangeValues: RangeValues(360, 1599),
  );

  static const AdaptiveWindowType medium = AdaptiveWindowType._(
    name: 'medium',
    relativeSize: 2,
    widthRangeValues: RangeValues(1024, 1439),
    heightLandscapeRangeValues: RangeValues(720, 959),
    heightPortraitRangeValues: RangeValues(720, 1919),
  );

  static const AdaptiveWindowType large = AdaptiveWindowType._(
    name: 'large',
    relativeSize: 3,
    widthRangeValues: RangeValues(1440, 1919),
    heightLandscapeRangeValues: RangeValues(960, 1279),
    heightPortraitRangeValues: RangeValues(1920, double.infinity),
  );

  static const AdaptiveWindowType xlarge = AdaptiveWindowType._(
    name: 'xlarge',
    relativeSize: 4,
    widthRangeValues: RangeValues(1920, double.infinity),
    heightLandscapeRangeValues: RangeValues(1280, double.infinity),
    heightPortraitRangeValues: RangeValues(1920, double.infinity),
  );

  bool operator <=(AdaptiveWindowType other) =>
      relativeSize <= other.relativeSize;
  bool operator <(AdaptiveWindowType other) =>
      relativeSize < other.relativeSize;
  bool operator >=(AdaptiveWindowType other) =>
      relativeSize >= other.relativeSize;
  bool operator >(AdaptiveWindowType other) =>
      relativeSize > other.relativeSize;
}

//Define custom screen size categories
//enum CustomWindowType { xsmall, small, medium, large, xlarge }

//Custom screen width breakpoints
AdaptiveWindowType getWindowType(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final orientation = MediaQuery.of(context).orientation;

  final double width = size.width;
  final double height = size.height;

  for (final type in [
    AdaptiveWindowType.xsmall,
    AdaptiveWindowType.small,
    AdaptiveWindowType.medium,
    AdaptiveWindowType.large,
    AdaptiveWindowType.xlarge,
  ]) {
    final heightRange = orientation == Orientation.landscape
        ? type.heightLandscapeRangeValues
        : type.heightPortraitRangeValues;

    if (type.widthRangeValues.start <= width &&
        width <= type.widthRangeValues.end &&
        heightRange.start <= height &&
        height <= heightRange.end) {
      return type;
    }
  }

  return AdaptiveWindowType.xsmall;
}

/// Returns a boolean value whether the window is considered medium or large size.
///
/// When running on a desktop device that is also foldable, the display is not
/// considered desktop. Widgets using this method might consider the display is
/// large enough for certain layouts, which is not the case on foldable devices,
/// where only part of the display is available to said widgets.
///
/// Used to build adaptive and responsive layouts.
bool isDisplayDesktop(BuildContext context) =>
    !isDisplayFoldable(context) &&
    getWindowType(context) >= AdaptiveWindowType.medium;

bool isDisplayTab(BuildContext context) =>
    !isDisplayFoldable(context) &&
    getWindowType(context) >= AdaptiveWindowType.small;

/// Returns boolean value whether the window is considered medium size.
///
/// Used to build adaptive and responsive layouts.
bool isDisplaySmallDesktop(BuildContext context) =>
    getWindowType(context) == AdaptiveWindowType.medium;

/// Returns a boolean value whether the display has a hinge that splits the
/// screen into two, left and right sub-screens. Horizontal splits (top and
/// bottom sub-screens) are ignored for this application.
bool isDisplayFoldable(BuildContext context) {
  // final hinge = MediaQuery.of(context).hinge;
  // if (hinge == null) {
  //   return false;
  // } else {
  //   // Vertical
  //   return hinge.bounds.size.aspectRatio < 1;
  //}
  return false;
}
