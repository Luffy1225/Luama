import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:luama/util/user.dart';
import '../main.dart';
import '../util/Page_animation.dart';
import '../util/app_colors.dart';

class InitialSetupPage extends StatelessWidget {
  InitialSetupPage({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Scaffold(
      backgroundColor: appColors.ScaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Center(
                child: Text(
                  'Luama',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: appColors.TopBar_Title,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Container(
                          height: 128,
                          width: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAWjASnsmvnLF9LkSlwqzW3HnDa_PiyZ1wPqQweTedCq9__iJFrF4z8xLyYc4HiEDSqxh0Zk4uC5pqY0AsLOW1pv8P7zx1qT4RBVkDo4WuKIVBRE9B0ljPkzqtgQo2UnZJ3X5lMXD4KRd5MVv1nMs-nFm4sHqohzYElBQhIaF_fvnH3QUjTl1WsJPwRzJrz9BDdn7FKZxqbtbeT25CWwE22IQjnbwULWqCYd6TgaUkekqTujsqX7R-W7Q0kJuWYQrznCvGjwOggITM',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Set Personal Information',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: appColors.PrimaryText,
                            letterSpacing: -0.015,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please provide your details to personalize your experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: appColors.PrimaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _InputField(
                      placeholder: 'Username',
                      controller: nameController,
                    ),
                    _InputField(
                      placeholder: 'User ID',
                      controller: idController,
                    ),
                    const SizedBox(height: 8),
                    _CheckboxSetting(
                      nameController: nameController,
                      idController: idController,
                      emailController: emailController,
                    ),
                    const SizedBox(height: 24),
                    _FoldRegion(
                      ipController: ipController,
                      portController: portController,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColors.TextBox_Background,
                          foregroundColor: appColors.PrimaryText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onPressed: () {
                          _DoneInitial(context);
                        },
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _DoneInitial(BuildContext context) {
    if (idController.text == "" || nameController.text == "") {
      SnackMessage(text: "Name 跟 ID 任一不可為空白").show(context);
      return;
    }

    TUser myself = TUser(
      userId: idController.text,
      userName: nameController.text,
      email: emailController.text,
      profileImage: "",
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Homepage(MySelf: myself)),
    );
  }
}

class _InputField extends StatelessWidget {
  final String placeholder;
  final TextEditingController controller;

  const _InputField({
    required this.placeholder,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: appColors.TextBox_Background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: appColors.SettingTextColor),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          hintText: placeholder,
          hintStyle: TextStyle(color: appColors.SettingTextHintColor),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _CheckboxSetting extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController idController;
  final TextEditingController emailController;

  const _CheckboxSetting({
    required this.nameController,
    required this.idController,
    required this.emailController,
    super.key,
  });

  @override
  State<_CheckboxSetting> createState() => _CheckboxSettingState();
}

class _CheckboxSettingState extends State<_CheckboxSetting> {
  bool _checked = false;

  void _applyRandomInfo(bool checked) {
    if (checked) {
      final info = GenerateRandomUserInfo();
      widget.nameController.text = info.Name;
      widget.idController.text = info.ID;
      if (info.Email != null) {
        widget.emailController.text = info.Email!;
      } else {
        widget.emailController.text = "";
      }
    } else {
      widget.nameController.clear();
      widget.idController.clear();
      widget.emailController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: appColors.ScaffoldBackground),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Randomize Settings',
              style: TextStyle(color: appColors.SettingTextColor, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Checkbox(
            value: _checked,
            onChanged: (val) {
              setState(() {
                _checked = val ?? false;
                _applyRandomInfo(_checked);
              });
            },
            checkColor: appColors.CheckBox_CheckColor,
            activeColor: appColors.CheckBox_ActiveColor,
            side: BorderSide(color: appColors.CheckBox_BorderColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoldRegion extends StatefulWidget {
  final TextEditingController ipController;
  final TextEditingController portController;

  const _FoldRegion({
    required this.ipController,
    required this.portController,
    super.key,
  });

  @override
  State<_FoldRegion> createState() => _FoldRegionState();
}

class _FoldRegionState extends State<_FoldRegion> {
  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFF264532),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            'Luama Server Setting',
            style: TextStyle(
              color: appColors.PrimaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          backgroundColor: const Color(0xFF122118),
          collapsedBackgroundColor: Colors.transparent,
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          children: [
            _InputField(
              placeholder: 'Server IP Address',
              controller: widget.ipController,
            ),
            _InputField(
              placeholder: 'Server Port',
              controller: widget.portController,
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfo {
  String Name;
  String ID;
  String? Email;

  UserInfo({required this.Name, required this.ID, this.Email});
}

String generateRandomID(int length) {
  final random = Random();
  String result = '';

  for (int i = 0; i < length; i++) {
    result += random.nextInt(10).toString(); // 產生 0~9 的單一位數
  }
  return result;
}

UserInfo GenerateRandomUserInfo() {
  String id = generateRandomID(4);
  return UserInfo(Name: "User$id", ID: id);
}
