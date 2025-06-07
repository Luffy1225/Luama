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
  final Color ScaffoldBackground;
  final Color TopBar_Title;
  final Color TopBar_IconColor;

  final Color SearchBarHintBackground;
  final Color SearchBarHintColor;
  final Color SearchBarLeftIcon;

  final Color ContactItemUserName;
  final Color ContactItemMessage;

  final Color NavigationBarBackground;
  final Color NavigationBarSelect;
  final Color NavigationBarUnselect;

  //chatpage
  final Color TimeTextColor;

  final Color ChatBubbleNameColor;
  final Color ChatBubbleSender_BGColor;
  final Color ChatBubbleSender_TextColor;

  final Color ChatBubbleReceiver_BGColor;
  final Color ChatBubbleReceiver_TextColor;

  final Color InputAreaBackground;
  final Color TextBox_Background;
  final Color TextBoxHint_Background;

  final Color SendButtonBackground;
  final Color SendButtonIconColor;

  // Setting page
  final Color SettingTextColor;
  final Color SettingTextHintColor;

  final Color SwitchActiveTrack;
  final Color SwitchInactiveTrack;

  final Color ButtonBGColor;

  // CheckBox
  final Color CheckBox_CheckColor;
  final Color CheckBox_ActiveColor;
  final Color CheckBox_BorderColor;

  // FoldRegion
  final Color FoldRegion_BGColor;
  final Color CheckBox_ActiveColor;
  final Color CheckBox_BorderColor;

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
    Color? checkBox_CheckColor,
    Color? checkBox_ActiveColor,
    Color? checkBox_BorderColor,
  }) : ScaffoldBackground = scaffoldBackground ?? const Color(0xFFFFFFFF),
       TopBar_Title = TopBar_Title ?? const Color(0xFF0E1A13),
       TopBar_IconColor = TopBar_IconColor ?? const Color(0xFF0E1A13),
       SearchBarHintBackground =
           searchBarHintBackground ?? const Color(0xFFE8F2EC),
       SearchBarHintColor = searchBarHintColor ?? const Color(0xFF51946B),
       SearchBarLeftIcon = searchBarLeftIcon ?? const Color(0xFF51946B),
       ContactItemUserName = contactItemUserName ?? const Color(0xff0d1912),
       ContactItemMessage = contactItemMessage ?? const Color(0xFF51946B),
       NavigationBarBackground =
           navigationBarBackground ?? const Color(0xff1c3024),
       NavigationBarSelect = navigationBarSelect ?? const Color(0xff0d1912),
       NavigationBarUnselect = navigationBarUnselect ?? const Color(0xFF51946B),
       TimeTextColor = timeTextColor ?? const Color(0xFF688272),
       ChatBubbleNameColor = chatBubbleNameColor ?? const Color(0xFF688272),
       ChatBubbleSender_BGColor =
           chatBubbleSender_BGColor ?? const Color(0xFF94e0b1),
       ChatBubbleSender_TextColor =
           chatBubbleSender_TextColor ?? const Color(0xFF121714),
       ChatBubbleReceiver_BGColor =
           chatBubbleReceiver_BGColor ?? const Color(0xFFF1F4F2),
       ChatBubbleReceiver_TextColor =
           chatBubbleReceiver_TextColor ?? const Color(0xFF121714),
       InputAreaBackground = inputAreaBackground ?? const Color(0xFFF1F4F2),
       TextBox_Background = TextBox_Background ?? const Color(0xFFFFFFFF),
       TextBoxHint_Background =
           TextBoxHint_Background ?? const Color(0xff9cbfa8),
       SendButtonBackground = sendButtonBackground ?? const Color(0xFF121714),
       SendButtonIconColor = sendButtonIconColor ?? const Color(0xFFFFFFFF),
       SettingTextColor = SettingTextColor ?? const Color(0xFF121714),
       SettingTextHintColor = SettingTextHintColor ?? const Color(0xFF688272),
       SwitchActiveTrack = switchActiveTrack ?? const Color(0xFF79D29B),
       SwitchInactiveTrack = switchInactiveTrack ?? const Color(0xFFF1F4F2),
       ButtonBGColor = buttonBG ?? const Color(0xfff2f5f2),
       CheckBox_CheckColor = checkBox_CheckColor ?? const Color(0xFF122118),
       CheckBox_ActiveColor = checkBox_ActiveColor ?? const Color(0xFF39E079),
       CheckBox_BorderColor = checkBox_BorderColor ?? const Color(0xFF366347);
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
  checkBox_CheckColor: const Color(0xFF122118),
  checkBox_ActiveColor: const Color(0xff52946b),
  checkBox_BorderColor: const Color(0xff94e0b0),
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
  checkBox_CheckColor: const Color(0xFF122118),
  checkBox_ActiveColor: const Color(0xFF39E079),
  checkBox_BorderColor: const Color(0xFF366347),
);
