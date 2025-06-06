import 'package:flutter/material.dart';
import 'dart:math';

import 'package:luama/util/user.dart';
import '../main.dart';
import '../util/Page_animation.dart';

class InitialSetupPage extends StatelessWidget {
  InitialSetupPage({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF122118),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Center(
                child: Text(
                  'Luama',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAWjASnsmvnLF9LkSlwqzW3HnDa_PiyZ1wPqQweTedCq9__iJFrF4z8xLyYc4HiEDSqxh0Zk4uC5pqY0AsLOW1pv8P7zx1qT4RBVkDo4WuKIVBRE9B0ljPkzqtgQo2UnZJ3X5lMXD4KRd5MVv1nMs-nFm4sHqohzYElBQhIaF_fvnH3QUjTl1WsJPwRzJrz9BDdn7FKZxqbtbeT25CWwE22IQjnbwULWqCYd6TgaUkekqTujsqX7R-W7Q0kJuWYQrznCvGjwOggITM',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Set Personal Information',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.015,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please provide your details to personalize your experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF96C5A8),
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
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF39E079),
                          foregroundColor: const Color(0xFF122118),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF264532),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFF96C5A8)),
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
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(color: Color(0xFF122118)),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Randomize Settings',
              style: TextStyle(color: Colors.white, fontSize: 16),
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
            checkColor: const Color(0xFF122118),
            activeColor: const Color(0xFF39E079),
            side: const BorderSide(color: Color(0xFF366347), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
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
