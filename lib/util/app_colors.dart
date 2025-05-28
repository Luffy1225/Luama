import 'package:flutter/material.dart';

class AppColorsProvider extends InheritedWidget {
  final AppColors appColors;

  const AppColorsProvider({required this.appColors, required Widget child})
    : super(child: child);

  static AppColors of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppColorsProvider>();
    assert(provider != null, 'No AppColorsProvider found in context');
    return provider!.appColors;
  }

  @override
  bool updateShouldNotify(AppColorsProvider oldWidget) {
    return oldWidget.appColors != appColors;
  }
}

class AppColors {
  final Color Primary_Color;
  final Color Secondary_Color;
  final Color Dark;
  final Color PrimaryText;

  //mainpage
  final Color scaffoldBackground;
  final Color TopBar_Title;
  final Color TopBar_IconColor;

  final Color searchBarHintBackground;
  final Color searchBarHintColor;
  final Color searchBarLeftIcon;

  final Color contactItemUserName;
  final Color contactItemMessage;

  final Color navigationBarBackground;
  final Color navigationBarSelect;
  final Color navigationBarUnselect;

  //chatpage
  final Color timeTextColor;

  final Color chatBubbleNameColor;
  final Color chatBubbleSender_BGColor;
  final Color chatBubbleSender_TextColor;

  final Color chatBubbleReceiver_BGColor;
  final Color chatBubbleReceiver_TextColor;

  final Color inputAreaBackground;
  final Color TextBox_Background;
  final Color TextBoxHint_Background;

  final Color sendButtonBackground;
  final Color sendButtonIconColor;

  // Setting page
  final Color SettingTextColor;
  final Color SettingTextHintColor;

  final Color switchActiveTrack;
  final Color switchInactiveTrack;

  final Color buttonBG;

  AppColors({
    required this.Primary_Color,
    required this.Secondary_Color,
    required this.Dark,
    required this.PrimaryText,
    Color? scaffoldBackground,
    Color? TopBar_Title,
    Color? TopBar_IconColor,
    Color? searchBarHintBackground,
    Color? searchBarHintColor,
    Color? searchBarLeftIcon,
    Color? contactItemUserName,
    Color? contactItemMessage,
    Color? navigationBarBackground,
    Color? navigationBarSelect,
    Color? navigationBarUnselect,
    Color? timeTextColor,
    Color? chatBubbleNameColor,
    Color? chatBubbleSender_BGColor,
    Color? chatBubbleSender_TextColor,
    Color? chatBubbleReceiver_BGColor,
    Color? chatBubbleReceiver_TextColor,
    Color? inputAreaBackground,
    Color? TextBox_Background,
    Color? TextBoxHint_Background,
    Color? sendButtonBackground,
    Color? sendButtonIconColor,
    Color? SettingTextColor,
    Color? SettingTextHintColor,
    Color? switchActiveTrack,
    Color? switchInactiveTrack,
    Color? buttonBG,
  }) : scaffoldBackground = scaffoldBackground ?? const Color(0xFFFFFFFF),
       TopBar_Title = TopBar_Title ?? const Color(0xFF0E1A13),
       TopBar_IconColor = TopBar_IconColor ?? const Color(0xFF0E1A13),
       searchBarHintBackground =
           searchBarHintBackground ?? const Color(0xFFE8F2EC),
       searchBarHintColor = searchBarHintColor ?? const Color(0xFF51946B),
       searchBarLeftIcon = searchBarLeftIcon ?? const Color(0xFF51946B),
       contactItemUserName = contactItemUserName ?? const Color(0xff0d1912),
       contactItemMessage = contactItemMessage ?? const Color(0xFF51946B),
       navigationBarBackground =
           navigationBarBackground ?? const Color(0xff1c3024),
       navigationBarSelect = navigationBarSelect ?? const Color(0xff0d1912),
       navigationBarUnselect = navigationBarUnselect ?? const Color(0xFF51946B),
       timeTextColor = timeTextColor ?? const Color(0xFF688272),
       chatBubbleNameColor = chatBubbleNameColor ?? const Color(0xFF688272),
       chatBubbleSender_BGColor =
           chatBubbleSender_BGColor ?? const Color(0xFF94e0b1),
       chatBubbleSender_TextColor =
           chatBubbleSender_TextColor ?? const Color(0xFF121714),
       chatBubbleReceiver_BGColor =
           chatBubbleReceiver_BGColor ?? const Color(0xFFF1F4F2),
       chatBubbleReceiver_TextColor =
           chatBubbleReceiver_TextColor ?? const Color(0xFF121714),
       inputAreaBackground = inputAreaBackground ?? const Color(0xFFF1F4F2),
       TextBox_Background = TextBox_Background ?? const Color(0xFFFFFFFF),
       TextBoxHint_Background =
           TextBoxHint_Background ?? const Color(0xff9cbfa8),
       sendButtonBackground = sendButtonBackground ?? const Color(0xFF121714),
       sendButtonIconColor = sendButtonIconColor ?? const Color(0xFFFFFFFF),
       SettingTextColor = SettingTextColor ?? const Color(0xFF121714),
       SettingTextHintColor = SettingTextHintColor ?? const Color(0xFF688272),
       switchActiveTrack = switchActiveTrack ?? const Color(0xFF79D29B),
       switchInactiveTrack = switchInactiveTrack ?? const Color(0xFFF1F4F2),
       buttonBG = buttonBG ?? const Color(0xfff2f5f2);
}

AppColors LightTheme = AppColors(
  Primary_Color: const Color(0xff52946b),
  Secondary_Color: const Color(0xff94e0b0),
  Dark: const Color(0xff52946b),
  PrimaryText: const Color(0xff0d1912),
  scaffoldBackground: const Color(0xfff7fafa),
  TopBar_Title: const Color(0xff0d1912),
  TopBar_IconColor: const Color(0xff0d1912),
  searchBarHintBackground: const Color(0xffe8f2ed),
  searchBarHintColor: const Color(0xff52946b),
  searchBarLeftIcon: const Color(0xff52946b),
  contactItemUserName: const Color(0xff0d1912),
  contactItemMessage: const Color(0xff52946b),
  navigationBarBackground: const Color(0xfff7fafa),
  navigationBarSelect: const Color(0xff0d1912),
  navigationBarUnselect: const Color(0xff52946b),
  timeTextColor: const Color(0xff698273),
  chatBubbleNameColor: const Color(0xff698273),
  chatBubbleSender_BGColor: const Color(0xff94e0b0),
  chatBubbleSender_TextColor: const Color(0xff0d1912),
  chatBubbleReceiver_BGColor: const Color(0xfff2f5f2),
  chatBubbleReceiver_TextColor: const Color(0xff0d1912),
  inputAreaBackground: const Color(0xfff7fafa),
  TextBox_Background: const Color(0xffe8f2ed),
  TextBoxHint_Background: const Color(0xff52946b),
  sendButtonBackground: const Color(0xFF121714),
  sendButtonIconColor: const Color(0xFFFFFFFF),
  SettingTextColor: const Color(0xff121714),
  SettingTextHintColor: const Color(0xff698273),
  switchActiveTrack: const Color(0xff94e0b0),
  switchInactiveTrack: const Color(0xfff2f5f2),
  buttonBG: const Color(0xfff2f5f2),
);

AppColors DarkTheme = AppColors(
  Primary_Color: const Color(0xff122117),
  Secondary_Color: const Color(0xff264533),
  Dark: const Color(0xffffffff),
  PrimaryText: const Color(0xffffffff),
  scaffoldBackground: const Color(0xff122117),
  TopBar_Title: const Color(0xffffffff),
  TopBar_IconColor: const Color(0xffffffff),
  searchBarHintBackground: const Color(0xff264533),
  searchBarHintColor: const Color(0xff96c4a8),
  searchBarLeftIcon: const Color(0xff96c4a8),
  contactItemUserName: const Color(0xffffffff),
  contactItemMessage: const Color(0xff96c4a8),
  navigationBarBackground: const Color(0xff1c3024),
  navigationBarSelect: const Color(0xffffffff),
  navigationBarUnselect: const Color(0xff96c4a8),
  timeTextColor: const Color(0xff9cbfa8),
  chatBubbleNameColor: const Color(0xff9cbfa8),
  chatBubbleSender_BGColor: const Color(0xff94e0b0),
  chatBubbleSender_TextColor: const Color(0xff141f17),
  chatBubbleReceiver_BGColor: const Color(0xff294033),
  chatBubbleReceiver_TextColor: const Color(0xfff2f5f2),
  inputAreaBackground: const Color(0xff122117),
  TextBox_Background: const Color(0xff294033),
  TextBoxHint_Background: const Color(0xff9cbfa8),
  sendButtonBackground: const Color(0xFF121714),
  sendButtonIconColor: const Color(0xFFFFFFFF),
  SettingTextColor: const Color(0xffffffff),
  SettingTextHintColor: const Color(0xff9ebfab),
  switchActiveTrack: const Color(0xff94e0b0),
  switchInactiveTrack: const Color(0xff2b4033),
  buttonBG: const Color(0xff294033),
);
