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
  final Color FoldRegion_TitleBGColor;
  final Color FoldRegion_BGColor;
  final Color FoldRegion_FoldedColor;
  final Color FoldRegion_UnFoldedColor;

  AppColors({
    required this.Primary_Color,
    required this.Secondary_Color,
    required this.Dark,
    required this.PrimaryText,
    Color? ScaffoldBackground,
    Color? TopBar_Title,
    Color? TopBar_IconColor,
    Color? SearchBarHintBackground,
    Color? SearchBarHintColor,
    Color? SearchBarLeftIcon,
    Color? ContactItemUserName,
    Color? ContactItemMessage,
    Color? NavigationBarBackground,
    Color? NavigationBarSelect,
    Color? NavigationBarUnselect,
    Color? TimeTextColor,
    Color? ChatBubbleNameColor,
    Color? ChatBubbleSender_BGColor,
    Color? ChatBubbleSender_TextColor,
    Color? ChatBubbleReceiver_BGColor,
    Color? ChatBubbleReceiver_TextColor,
    Color? InputAreaBackground,
    Color? TextBox_Background,
    Color? TextBoxHint_Background,
    Color? SendButtonBackground,
    Color? SendButtonIconColor,
    Color? SettingTextColor,
    Color? SettingTextHintColor,
    Color? SwitchActiveTrack,
    Color? SwitchInactiveTrack,
    Color? ButtonBGColor,
    Color? CheckBox_CheckColor,
    Color? CheckBox_ActiveColor,
    Color? CheckBox_BorderColor,
    Color? FoldRegion_TitleBGColor,
    Color? FoldRegion_BGColor,
    Color? FoldRegion_FoldedColor,
    Color? FoldRegion_UnFoldedColor,
  }) : ScaffoldBackground = ScaffoldBackground ?? const Color(0xFFFFFFFF),
       TopBar_Title = TopBar_Title ?? const Color(0xFF0E1A13),
       TopBar_IconColor = TopBar_IconColor ?? const Color(0xFF0E1A13),
       SearchBarHintBackground =
           SearchBarHintBackground ?? const Color(0xFFE8F2EC),
       SearchBarHintColor = SearchBarHintColor ?? const Color(0xFF51946B),
       SearchBarLeftIcon = SearchBarLeftIcon ?? const Color(0xFF51946B),
       ContactItemUserName = ContactItemUserName ?? const Color(0xff0d1912),
       ContactItemMessage = ContactItemMessage ?? const Color(0xFF51946B),
       NavigationBarBackground =
           NavigationBarBackground ?? const Color(0xff1c3024),
       NavigationBarSelect = NavigationBarSelect ?? const Color(0xff0d1912),
       NavigationBarUnselect = NavigationBarUnselect ?? const Color(0xFF51946B),
       TimeTextColor = TimeTextColor ?? const Color(0xFF688272),
       ChatBubbleNameColor = ChatBubbleNameColor ?? const Color(0xFF688272),
       ChatBubbleSender_BGColor =
           ChatBubbleSender_BGColor ?? const Color(0xFF94e0b1),
       ChatBubbleSender_TextColor =
           ChatBubbleSender_TextColor ?? const Color(0xFF121714),
       ChatBubbleReceiver_BGColor =
           ChatBubbleReceiver_BGColor ?? const Color(0xFFF1F4F2),
       ChatBubbleReceiver_TextColor =
           ChatBubbleReceiver_TextColor ?? const Color(0xFF121714),
       InputAreaBackground = InputAreaBackground ?? const Color(0xFFF1F4F2),
       TextBox_Background = TextBox_Background ?? const Color(0xFFFFFFFF),
       TextBoxHint_Background =
           TextBoxHint_Background ?? const Color(0xff9cbfa8),
       SendButtonBackground = SendButtonBackground ?? const Color(0xFF121714),
       SendButtonIconColor = SendButtonIconColor ?? const Color(0xFFFFFFFF),
       SettingTextColor = SettingTextColor ?? const Color(0xFF121714),
       SettingTextHintColor = SettingTextHintColor ?? const Color(0xFF688272),
       SwitchActiveTrack = SwitchActiveTrack ?? const Color(0xFF79D29B),
       SwitchInactiveTrack = SwitchInactiveTrack ?? const Color(0xFFF1F4F2),
       ButtonBGColor = ButtonBGColor ?? const Color(0xfff2f5f2),
       CheckBox_CheckColor = CheckBox_CheckColor ?? const Color(0xFF122118),
       CheckBox_ActiveColor = CheckBox_ActiveColor ?? const Color(0xFF39E079),
       CheckBox_BorderColor = CheckBox_BorderColor ?? const Color(0xFF366347),
       FoldRegion_TitleBGColor =
           FoldRegion_TitleBGColor ?? const Color(0xFF366347),
       FoldRegion_BGColor = FoldRegion_BGColor ?? const Color(0xFF366347),
       FoldRegion_FoldedColor =
           FoldRegion_FoldedColor ?? const Color(0xFF366347),
       FoldRegion_UnFoldedColor =
           FoldRegion_UnFoldedColor ?? const Color(0xFF366347);
}

AppColors LightTheme = AppColors(
  Primary_Color: const Color(0xff52946b),
  Secondary_Color: const Color(0xff94e0b0),
  Dark: const Color(0xff52946b),
  PrimaryText: const Color(0xff0d1912),
  ScaffoldBackground: const Color(0xfff7fafa),
  TopBar_Title: const Color(0xff0d1912),
  TopBar_IconColor: const Color(0xff0d1912),
  SearchBarHintBackground: const Color(0xffe8f2ed),
  SearchBarHintColor: const Color(0xff52946b),
  SearchBarLeftIcon: const Color(0xff52946b),
  ContactItemUserName: const Color(0xff0d1912),
  ContactItemMessage: const Color(0xff52946b),
  NavigationBarBackground: const Color(0xfff7fafa),
  NavigationBarSelect: const Color(0xff0d1912),
  NavigationBarUnselect: const Color(0xff52946b),
  TimeTextColor: const Color(0xff698273),
  ChatBubbleNameColor: const Color(0xff698273),
  ChatBubbleSender_BGColor: const Color(0xff94e0b0),
  ChatBubbleSender_TextColor: const Color(0xff0d1912),
  ChatBubbleReceiver_BGColor: const Color(0xfff2f5f2),
  ChatBubbleReceiver_TextColor: const Color(0xff0d1912),
  InputAreaBackground: const Color(0xfff7fafa),
  TextBox_Background: const Color(0xffe8f2ed),
  TextBoxHint_Background: const Color(0xff52946b),
  SendButtonBackground: const Color(0xFF121714),
  SendButtonIconColor: const Color(0xFFFFFFFF),
  SettingTextColor: const Color(0xff121714),
  SettingTextHintColor: const Color(0xff698273),
  SwitchActiveTrack: const Color(0xff94e0b0),
  SwitchInactiveTrack: const Color(0xfff2f5f2),
  ButtonBGColor: const Color(0xffe8f2ed),
  CheckBox_CheckColor: const Color(0xFF122118),
  CheckBox_ActiveColor: const Color(0xff52946b),
  CheckBox_BorderColor: const Color(0xff94e0b0),
  FoldRegion_TitleBGColor: const Color(0xff94e0b0),
  FoldRegion_BGColor: const Color(0xff94e0b0),
  FoldRegion_FoldedColor: const Color(0xff94e0b0),
  FoldRegion_UnFoldedColor: const Color(0xff94e0b0),
);

AppColors DarkTheme = AppColors(
  Primary_Color: const Color(0xff122117),
  Secondary_Color: const Color(0xff264533),
  Dark: const Color(0xffffffff),
  PrimaryText: const Color(0xffffffff),
  ScaffoldBackground: const Color(0xff122117),
  TopBar_Title: const Color(0xffffffff),
  TopBar_IconColor: const Color(0xffffffff),
  SearchBarHintBackground: const Color(0xff264533),
  SearchBarHintColor: const Color(0xff96c4a8),
  SearchBarLeftIcon: const Color(0xff96c4a8),
  ContactItemUserName: const Color(0xffffffff),
  ContactItemMessage: const Color(0xff96c4a8),
  NavigationBarBackground: const Color(0xff1c3024),
  NavigationBarSelect: const Color(0xffffffff),
  NavigationBarUnselect: const Color(0xff96c4a8),
  TimeTextColor: const Color(0xff9cbfa8),
  ChatBubbleNameColor: const Color(0xff9cbfa8),
  ChatBubbleSender_BGColor: const Color(0xff94e0b0),
  ChatBubbleSender_TextColor: const Color(0xff141f17),
  ChatBubbleReceiver_BGColor: const Color(0xff294033),
  ChatBubbleReceiver_TextColor: const Color(0xfff2f5f2),
  InputAreaBackground: const Color(0xff122117),
  TextBox_Background: const Color(0xff294033),
  TextBoxHint_Background: const Color(0xff9cbfa8),
  SendButtonBackground: const Color(0xFF121714),
  SendButtonIconColor: const Color(0xFFFFFFFF),
  SettingTextColor: const Color(0xffffffff),
  SettingTextHintColor: const Color(0xff9ebfab),
  SwitchActiveTrack: const Color(0xff94e0b0),
  SwitchInactiveTrack: const Color(0xff2b4033),
  ButtonBGColor: const Color(0xff294033),
  CheckBox_CheckColor: const Color(0xFF122118),
  CheckBox_ActiveColor: const Color(0xFF39E079),
  CheckBox_BorderColor: const Color(0xFF366347),
  FoldRegion_TitleBGColor: const Color(0xff94e0b0),
  FoldRegion_BGColor: const Color(0xff94e0b0),
  FoldRegion_FoldedColor: const Color(0xff94e0b0),
  FoldRegion_UnFoldedColor: const Color(0xff94e0b0),
);
