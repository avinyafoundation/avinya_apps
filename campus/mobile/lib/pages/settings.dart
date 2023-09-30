// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mobile/constants.dart';
import 'package:mobile/data/gallery_options.dart';
import 'package:mobile/layout/adaptive.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/pages/settings_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

enum _ExpandableSetting {
  textScale,
  textDirection,
  platform,
  theme,
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.animationController,
  });

  final AnimationController animationController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _ExpandableSetting? _expandedSettingId;
  late Animation<double> _staggerSettingsItemsAnimation;

  void onTapSetting(_ExpandableSetting settingId) {
    setState(() {
      if (_expandedSettingId == settingId) {
        _expandedSettingId = null;
      } else {
        _expandedSettingId = settingId;
      }
    });
  }

  void _closeSettingId(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      setState(() {
        _expandedSettingId = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // When closing settings, also shrink expanded setting.
    widget.animationController.addStatusListener(_closeSettingId);

    _staggerSettingsItemsAnimation = CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(
        0.5,
        1.0,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.animationController.removeStatusListener(_closeSettingId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final options = GalleryOptions.of(context);
    final isDesktop = isDisplayDesktop(context);

    final settingsListItems = [
      SettingsListItem<double?>(
        title: "Text scaling",
        selectedOption: options.textScaleFactor(
          context,
          useSentinel: true,
        ),
        optionsMap: LinkedHashMap.of({
          systemTextScaleFactorOption: DisplayOption(
            "System Default",
          ),
          0.8: DisplayOption(
            "Small",
          ),
          1.0: DisplayOption(
            "Normal",
          ),
          2.0: DisplayOption(
            "Large",
          ),
          3.0: DisplayOption(
            "Huge",
          ),
        }),
        onOptionChanged: (newTextScale) => GalleryOptions.update(
          context,
          options.copyWith(textScaleFactor: newTextScale),
        ),
        onTapSetting: () => onTapSetting(_ExpandableSetting.textScale),
        isExpanded: _expandedSettingId == _ExpandableSetting.textScale,
      ),
      SettingsListItem<CustomTextDirection?>(
        title: "Text direction",
        selectedOption: options.customTextDirection,
        optionsMap: LinkedHashMap.of({
          CustomTextDirection.localeBased: DisplayOption(
            "Locale based",
          ),
          CustomTextDirection.ltr: DisplayOption(
            "LTR",
          ),
          CustomTextDirection.rtl: DisplayOption(
            "RTL",
          ),
        }),
        onOptionChanged: (newTextDirection) => GalleryOptions.update(
          context,
          options.copyWith(customTextDirection: newTextDirection),
        ),
        onTapSetting: () => onTapSetting(_ExpandableSetting.textDirection),
        isExpanded: _expandedSettingId == _ExpandableSetting.textDirection,
      ),
      SettingsListItem<TargetPlatform?>(
        title: "Platform",
        selectedOption: options.platform,
        optionsMap: LinkedHashMap.of({
          TargetPlatform.android: DisplayOption('Android'),
          TargetPlatform.iOS: DisplayOption('iOS'),
          TargetPlatform.macOS: DisplayOption('macOS'),
          TargetPlatform.linux: DisplayOption('Linux'),
          TargetPlatform.windows: DisplayOption('Windows'),
        }),
        onOptionChanged: (newPlatform) => GalleryOptions.update(
          context,
          options.copyWith(platform: newPlatform),
        ),
        onTapSetting: () => onTapSetting(_ExpandableSetting.platform),
        isExpanded: _expandedSettingId == _ExpandableSetting.platform,
      ),
      SettingsListItem<ThemeMode?>(
        title: "Theme",
        selectedOption: options.themeMode,
        optionsMap: LinkedHashMap.of({
          ThemeMode.system: DisplayOption(
            "System Default",
          ),
          ThemeMode.dark: DisplayOption(
            "Dark",
          ),
          ThemeMode.light: DisplayOption(
            "Light",
          ),
        }),
        onOptionChanged: (newThemeMode) => GalleryOptions.update(
          context,
          options.copyWith(themeMode: newThemeMode),
        ),
        onTapSetting: () => onTapSetting(_ExpandableSetting.theme),
        isExpanded: _expandedSettingId == _ExpandableSetting.theme,
      ),
      ToggleSetting(
        text: "Time dilation",
        value: options.timeDilation != 1.0,
        onChanged: (isOn) => GalleryOptions.update(
          context,
          options.copyWith(timeDilation: isOn ? 5.0 : 1.0),
        ),
      ),
    ];

    return Material(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: isDesktop
            ? EdgeInsets.zero
            : const EdgeInsets.only(
                bottom: galleryHeaderHeight,
              ),
        // Remove ListView top padding as it is already accounted for.
        child: MediaQuery.removePadding(
          removeTop: isDesktop,
          context: context,
          child: ListView(
            children: [
              if (isDesktop)
                const SizedBox(height: firstHeaderDesktopTopPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ExcludeSemantics(
                  child: Header(
                    color: Theme.of(context).colorScheme.onSurface,
                    text: "Settings",
                  ),
                ),
              ),
              if (isDesktop)
                ...settingsListItems
              else ...[
                _AnimateSettingsListItems(
                  animation: _staggerSettingsItemsAnimation,
                  children: settingsListItems,
                ),
                const SizedBox(height: 16),
                Divider(thickness: 2, height: 0, color: colorScheme.background),
                const SizedBox(height: 12),
                const SettingsFeedback(),
                const SizedBox(height: 12),
                Divider(thickness: 2, height: 0, color: colorScheme.background),
                const SettingsAttribution(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsFeedback extends StatelessWidget {
  const SettingsFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsLink(
      title: "Send feedback",
      icon: Icons.feedback,
      onTap: () async {
        final url =
            Uri.parse('https://github.com/flutter/gallery/issues/new/choose/');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
    );
  }
}

class SettingsAttribution extends StatelessWidget {
  const SettingsAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final verticalPadding = isDesktop ? 0.0 : 28.0;
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: isDesktop ? 24 : 32,
          end: isDesktop ? 0 : 32,
          top: verticalPadding,
          bottom: verticalPadding,
        ),
        child: SelectableText(
          "Flutter Gallery is an open source project maintained by the Flutter team. Flutter is a trademark of Google LLC. Flutter Gallery is licensed under the Creative Commons Attribution 4.0 International license (CC-BY-4.0).",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
          textAlign: isDesktop ? TextAlign.end : TextAlign.start,
        ),
      ),
    );
  }
}

class _SettingsLink extends StatelessWidget {
  final String title;
  final IconData? icon;
  final GestureTapCallback? onTap;

  const _SettingsLink({
    required this.title,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 32,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: colorScheme.onSecondary.withOpacity(0.5),
              size: 24,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  top: 12,
                  bottom: 12,
                ),
                child: Text(
                  title,
                  style: textTheme.titleSmall!.apply(
                    color: colorScheme.onSecondary,
                  ),
                  textAlign: isDesktop ? TextAlign.end : TextAlign.start,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animate the settings list items to stagger in from above.
class _AnimateSettingsListItems extends StatelessWidget {
  const _AnimateSettingsListItems({
    required this.animation,
    required this.children,
  });

  final Animation<double> animation;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const dividingPadding = 4.0;
    final topPaddingTween = Tween<double>(
      begin: 0,
      end: children.length * dividingPadding,
    );
    final dividerTween = Tween<double>(
      begin: 0,
      end: dividingPadding,
    );

    return Padding(
      padding: EdgeInsets.only(top: topPaddingTween.animate(animation).value),
      child: Column(
        children: [
          for (Widget child in children)
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: dividerTween.animate(animation).value,
                  ),
                  child: child,
                );
              },
              child: child,
            ),
        ],
      ),
    );
  }
}
