// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/layout/adaptive.dart';
import 'package:gallery/pages/home.dart';
import 'package:gallery/pages/login.dart';
import 'package:gallery/pages/settings.dart';
import 'package:gallery/pages/settings_icon/icon.dart' as settings_icon;
import '../data/campus_apps_portal.dart';
import 'dart:async';

const double _settingsButtonWidth = 64;
const double _settingsButtonHeightDesktop = 56;
const double _settingsButtonHeightMobile = 40;

class Backdrop extends StatefulWidget {
  const Backdrop({super.key, this.settingsPage, this.homePage, this.loginPage});

  final Widget? settingsPage;
  final Widget? homePage;
  final Widget? loginPage;

  @override
  State<Backdrop> createState() => _BackdropState();
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _BackdropState extends State<Backdrop>
    with TickerProviderStateMixin, RouteAware {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  late AnimationController _settingsPanelController;
  late AnimationController _iconController;
  late FocusNode _settingsPageFocusNode;
  late ValueNotifier<bool> _isSettingsOpenNotifier;
  late Widget _settingsPage;
  late Widget _homePage;
  late Completer<void> _completer;

  @override
  void initState() {
    super.initState();
    _homePage = const Center(child: CircularProgressIndicator());
    _completer = Completer<void>();
    _settingsPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _settingsPageFocusNode = FocusNode();
    _isSettingsOpenNotifier = ValueNotifier(false);
    _settingsPage = widget.settingsPage ??
        SettingsPage(
          animationController: _settingsPanelController,
        );
    // _homePage = widget.homePage ?? const HomePage();
    int count = 0;
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      while (campusAppsPortalInstance.isGroupFetched == false && count < 600) {
        print('Waiting for group to be fetched...');
        Future.delayed(const Duration(milliseconds: 500));
        count++;
      }
      if (!_completer.isCompleted) {
        if (campusAppsPortalInstance.isGroupFetched) {
          setState(() {
            _homePage = widget.homePage ?? const HomePage();
          });
        } else {
          setState(() {
            _homePage = Center(child: CircularProgressIndicator());
          });
        }
      }
    }).whenComplete(() {
      if (!_completer.isCompleted) {
        _completer.complete();
      }
    });
  }

  @override
  void dispose() {
    _settingsPanelController.dispose();
    _iconController.dispose();
    _settingsPageFocusNode.dispose();
    _isSettingsOpenNotifier.dispose();
    routeObserver.unsubscribe(this);
    if (!_completer.isCompleted) {
      _completer.complete(); // Complete the future if it hasn't completed yet
    }
    super.dispose();
  }

  @override
  void didPush() {
    final route = ModalRoute.of(context)!.settings.name;
    print('didPush route: $route');
  }

  @override
  void didPopNext() {
    final route = ModalRoute.of(context)!.settings.name;
    print('didPopNext route: $route');
  }

  @override
  void didPushNext() {
    final route = ModalRoute.of(context)!.settings.name;
    print('didPushNext route: $route');
  }

  @override
  void didPop() {
    final route = ModalRoute.of(context)!.settings.name;
    print('didPop route: $route');
  }

  void _toggleSettings() {
    // Animate the settings panel to open or close.
    if (_isSettingsOpenNotifier.value) {
      _settingsPanelController.reverse();
      _iconController.reverse();
    } else {
      _settingsPanelController.forward();
      _iconController.forward();
    }
    _isSettingsOpenNotifier.value = !_isSettingsOpenNotifier.value;
  }

  Animation<RelativeRect> _slideDownSettingsPageAnimation(
      BoxConstraints constraints) {
    return RelativeRectTween(
      begin: RelativeRect.fromLTRB(0, -constraints.maxHeight, 0, 0),
      end: const RelativeRect.fromLTRB(0, 0, 0, 0),
    ).animate(
      CurvedAnimation(
        parent: _settingsPanelController,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.ease,
        ),
      ),
    );
  }

  Animation<RelativeRect> _slideDownHomePageAnimation(
      BoxConstraints constraints) {
    return RelativeRectTween(
      begin: const RelativeRect.fromLTRB(0, 0, 0, 0),
      end: RelativeRect.fromLTRB(
        0,
        constraints.biggest.height - galleryHeaderHeight,
        0,
        -galleryHeaderHeight,
      ),
    ).animate(
      CurvedAnimation(
        parent: _settingsPanelController,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.ease,
        ),
      ),
    );
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final isDesktop = isDisplayDesktop(context);

    bool signedIn = campusAppsPortalInstance.getSignedIn();

    // int count = 0;
    // bool widgetMounted = true; // Flag to track widget state
    // Future.delayed(const Duration(milliseconds: 500)).then((_) {
    //   while (campusAppsPortalInstance.isGroupFetched == false && count < 30) {
    //     Future.delayed(const Duration(milliseconds: 500));
    //     count++;
    //   }
    //   if (widgetMounted) {
    //     if (campusAppsPortalInstance.isGroupFetched) {
    //       setState(() {
    //         _homePage = widget.homePage ?? const HomePage();
    //       });
    //     } else {
    //       setState(() {
    //         _homePage = Center(child: CircularProgressIndicator());
    //       });
    //     }
    //   }
    // });

    Widget homePage = ValueListenableBuilder<bool>(
      valueListenable: _isSettingsOpenNotifier,
      builder: (context, isSettingsOpen, child) {
        return ExcludeSemantics(
          excluding: isSettingsOpen,
          child: FocusTraversalGroup(child: _homePage),
        );
      },
    );

    log('signedIn: $signedIn! ');
    print('signedIn: $signedIn!');

    log('is decktop $isDesktop');

    final Widget settingsPage = ValueListenableBuilder<bool>(
      valueListenable: _isSettingsOpenNotifier,
      builder: (context, isSettingsOpen, child) {
        return ExcludeSemantics(
          excluding: !isSettingsOpen,
          child: isSettingsOpen
              ? RawKeyboardListener(
                  includeSemantics: false,
                  focusNode: _settingsPageFocusNode,
                  onKey: (event) {
                    if (event.logicalKey == LogicalKeyboardKey.escape) {
                      _toggleSettings();
                    }
                  },
                  child: FocusScope(child: _settingsPage),
                )
              : ExcludeFocus(child: _settingsPage),
        );
      },
    );

    final Widget loginPage = ValueListenableBuilder<bool>(
      valueListenable: _isSettingsOpenNotifier,
      builder: (context, isSettingsOpen, child) {
        return ExcludeSemantics(
          excluding: isSettingsOpen,
          child: FocusTraversalGroup(
            child: LoginPage(
                // onSignIn: (credentials) async {
                //   var signedIn = await authState.signIn(
                //       credentials.username, credentials.password);
                //   if (signedIn) {
                //     await routeState.go('/gallery');
                //   }
                // },
                ),
          ),
        );
      },
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: GalleryOptions.of(context).resolvedSystemUiOverlayStyle(),
      child: Stack(
        children: [
          // for mobile view login page
          if (!isDesktop && !signedIn) ...[
            // Slides the settings page up and down from the top of the
            // screen.
            PositionedTransition(
              rect: _slideDownSettingsPageAnimation(constraints),
              child: settingsPage,
            ),
            // Slides the home page up and down below the bottom of the
            // screen.
            PositionedTransition(
              rect: _slideDownHomePageAnimation(constraints),
              child: loginPage,
            ),
          ],
          if (isDesktop && signedIn) ...[
            Semantics(sortKey: const OrdinalSortKey(2), child: homePage),
            ValueListenableBuilder<bool>(
              valueListenable: _isSettingsOpenNotifier,
              builder: (context, isSettingsOpen, child) {
                if (isSettingsOpen) {
                  return ExcludeSemantics(
                    child: Listener(
                      onPointerDown: (_) => _toggleSettings(),
                      child: const ModalBarrier(dismissible: false),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Semantics(
              sortKey: const OrdinalSortKey(3),
              child: ScaleTransition(
                alignment: Directionality.of(context) == TextDirection.ltr
                    ? Alignment.topRight
                    : Alignment.topLeft,
                scale: CurvedAnimation(
                  parent: _settingsPanelController,
                  curve: Curves.easeIn,
                  reverseCurve: Curves.easeOut,
                ),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Material(
                    elevation: 7,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 560,
                        maxWidth: desktopSettingsWidth,
                        minWidth: desktopSettingsWidth,
                      ),
                      child: settingsPage,
                    ),
                  ),
                ),
              ),
            ),
            _SettingsIcon(
              animationController: _iconController,
              toggleSettings: _toggleSettings,
              isSettingsOpenNotifier: _isSettingsOpenNotifier,
            ),
            _LogoutIcon(
              animationController: _iconController,
              toggleSettings: _toggleSettings,
              isSettingsOpenNotifier: _isSettingsOpenNotifier,
            ),
            _ProfileIcon(
              animationController: _iconController,
              toggleSettings: _toggleSettings,
              isSettingsOpenNotifier: _isSettingsOpenNotifier,
            ),
          ],
          if (!isDesktop && signedIn) ...[
            Semantics(sortKey: const OrdinalSortKey(2), child: homePage),
            ValueListenableBuilder<bool>(
              valueListenable: _isSettingsOpenNotifier,
              builder: (context, isSettingsOpen, child) {
                if (isSettingsOpen) {
                  return ExcludeSemantics(
                    child: Listener(
                      onPointerDown: (_) => _toggleSettings(),
                      child: const ModalBarrier(dismissible: false),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Semantics(
              sortKey: const OrdinalSortKey(3),
              child: ScaleTransition(
                alignment: Directionality.of(context) == TextDirection.ltr
                    ? Alignment.topRight
                    : Alignment.topLeft,
                scale: CurvedAnimation(
                  parent: _settingsPanelController,
                  curve: Curves.easeIn,
                  reverseCurve: Curves.easeOut,
                ),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Material(
                    elevation: 7,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 560,
                        maxWidth: desktopSettingsWidth,
                        minWidth: desktopSettingsWidth,
                      ),
                      child: settingsPage,
                    ),
                  ),
                ),
              ),
            ),
            _SettingsIcon(
              animationController: _iconController,
              toggleSettings: _toggleSettings,
              isSettingsOpenNotifier: _isSettingsOpenNotifier,
            ),
            _LogoutIcon(
              animationController: _iconController,
              toggleSettings: _toggleSettings,
              isSettingsOpenNotifier: _isSettingsOpenNotifier,
            ),
            _ProfileIcon(
              animationController: _iconController,
              toggleSettings: _toggleSettings,
              isSettingsOpenNotifier: _isSettingsOpenNotifier,
            ),
          ],
          if (isDesktop && !signedIn) ...[
            Semantics(sortKey: const OrdinalSortKey(2), child: loginPage),
            ValueListenableBuilder<bool>(
              valueListenable: _isSettingsOpenNotifier,
              builder: (context, isSettingsOpen, child) {
                if (isSettingsOpen) {
                  return ExcludeSemantics(
                    child: Listener(
                      onPointerDown: (_) => _toggleSettings(),
                      child: const ModalBarrier(dismissible: false),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Semantics(
              sortKey: const OrdinalSortKey(3),
              child: ScaleTransition(
                alignment: Directionality.of(context) == TextDirection.ltr
                    ? Alignment.topRight
                    : Alignment.topLeft,
                scale: CurvedAnimation(
                  parent: _settingsPanelController,
                  curve: Curves.easeIn,
                  reverseCurve: Curves.easeOut,
                ),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Material(
                    elevation: 7,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 560,
                        maxWidth: desktopSettingsWidth,
                        minWidth: desktopSettingsWidth,
                      ),
                      child: settingsPage,
                    ),
                  ),
                ),
              ),
            ),
            _SettingsIcon(
              animationController: _iconController,
              toggleSettings: _toggleSettings,
              isSettingsOpenNotifier: _isSettingsOpenNotifier,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildStack(context, BoxConstraints());
  }
}

class _SettingsIcon extends AnimatedWidget {
  const _SettingsIcon({
    required this.animationController,
    required this.toggleSettings,
    required this.isSettingsOpenNotifier,
  }) : super(listenable: animationController);

  final AnimationController animationController;
  final VoidCallback toggleSettings;
  final ValueNotifier<bool> isSettingsOpenNotifier;

  String _settingsSemanticLabel(bool isOpen, BuildContext context) {
    return isOpen
        ? GalleryLocalizations.of(context)!.settingsButtonCloseLabel
        : GalleryLocalizations.of(context)!.settingsButtonLabel;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final safeAreaTopPadding = MediaQuery.of(context).padding.top;

    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: Semantics(
        sortKey: const OrdinalSortKey(1),
        button: true,
        enabled: true,
        label: _settingsSemanticLabel(isSettingsOpenNotifier.value, context),
        child: SizedBox(
          width: _settingsButtonWidth,
          height: isDesktop
              ? _settingsButtonHeightDesktop
              : _settingsButtonHeightMobile + safeAreaTopPadding,
          child: Material(
            borderRadius: const BorderRadiusDirectional.only(
              bottomStart: Radius.circular(10),
            ),
            color:
                isSettingsOpenNotifier.value & !animationController.isAnimating
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.secondaryContainer,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                toggleSettings();
                SemanticsService.announce(
                  _settingsSemanticLabel(isSettingsOpenNotifier.value, context),
                  GalleryOptions.of(context).resolvedTextDirection()!,
                );
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 3, end: 18),
                child: settings_icon.SettingsIcon(animationController.value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutIcon extends AnimatedWidget {
  const _LogoutIcon({
    required this.animationController,
    required this.toggleSettings,
    required this.isSettingsOpenNotifier,
  }) : super(listenable: animationController);

  final AnimationController animationController;
  final VoidCallback toggleSettings;
  final ValueNotifier<bool> isSettingsOpenNotifier;

  String _settingsSemanticLabel(bool isOpen, BuildContext context) {
    return isOpen
        ? GalleryLocalizations.of(context)!.settingsButtonCloseLabel
        : GalleryLocalizations.of(context)!.settingsButtonLabel;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final safeAreaTopPadding = MediaQuery.of(context).padding.top;

    return Container(
      margin: const EdgeInsetsDirectional.only(end: 80),
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Semantics(
          sortKey: const OrdinalSortKey(1),
          button: true,
          enabled: true,
          label: _settingsSemanticLabel(isSettingsOpenNotifier.value, context),
          child: SizedBox(
            width: _settingsButtonWidth,
            height: isDesktop
                ? _settingsButtonHeightDesktop
                : _settingsButtonHeightMobile + safeAreaTopPadding,
            child: Material(
              borderRadius: const BorderRadiusDirectional.only(
                bottomStart: Radius.circular(10),
                bottomEnd: Radius.circular(10),
              ),
              color: isSettingsOpenNotifier.value &
                      !animationController.isAnimating
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondaryContainer,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  await campusAppsPortalInstance.getAuth()!.signOut();
                },
                // onTap: () {
                //   toggleSettings();
                //   SemanticsService.announce(
                //     _settingsSemanticLabel(
                //         isSettingsOpenNotifier.value, context),
                //     GalleryOptions.of(context).resolvedTextDirection()!,
                //   );
                // },
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 3, end: 18),
                  child: Icon(
                    Icons.exit_to_app,
                    size: 25.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileIcon extends AnimatedWidget {
  const _ProfileIcon({
    required this.animationController,
    required this.toggleSettings,
    required this.isSettingsOpenNotifier,
  }) : super(listenable: animationController);

  final AnimationController animationController;
  final VoidCallback toggleSettings;
  final ValueNotifier<bool> isSettingsOpenNotifier;

  String _settingsSemanticLabel(bool isOpen, BuildContext context) {
    return isOpen
        ? GalleryLocalizations.of(context)!.settingsButtonCloseLabel
        : GalleryLocalizations.of(context)!.settingsButtonLabel;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final safeAreaTopPadding = MediaQuery.of(context).padding.top;

    return Container(
      margin: const EdgeInsetsDirectional.only(end: 160),
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Semantics(
          sortKey: const OrdinalSortKey(1),
          button: true,
          enabled: true,
          label: _settingsSemanticLabel(isSettingsOpenNotifier.value, context),
          child: SizedBox(
            width: _settingsButtonWidth,
            height: isDesktop
                ? _settingsButtonHeightDesktop
                : _settingsButtonHeightMobile + safeAreaTopPadding,
            child: Material(
              borderRadius: const BorderRadiusDirectional.only(
                bottomStart: Radius.circular(10),
                bottomEnd: Radius.circular(10),
              ),
              color: isSettingsOpenNotifier.value &
                      !animationController.isAnimating
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondaryContainer,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  await Navigator.of(context).pushNamed('/profile');
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 3, end: 8),
                  child: Icon(
                    Icons.account_circle,
                    size: 25.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
