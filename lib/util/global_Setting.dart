import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'user.dart';

class AppContextProvider extends InheritedWidget {
  final AppColors appColors;
  final bool isDarkMode;
  // final TUser MySelf;

  const AppContextProvider({
    required this.appColors,
    required this.isDarkMode,
    // required this.MySelf,
    required Widget child,
  }) : super(child: child);

  static AppContextProvider of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppContextProvider>();
    assert(provider != null, 'No AppContextProvider found in context');
    return provider!;
  }

  @override
  bool updateShouldNotify(AppContextProvider oldWidget) {
    return appColors != oldWidget.appColors ||
        isDarkMode != oldWidget.isDarkMode;
    //  MySelf != oldWidget.MySelf;
  }
}
