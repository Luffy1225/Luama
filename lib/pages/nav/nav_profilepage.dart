import 'package:flutter/material.dart';
import 'package:luama/pages/serversettingpage.dart';
import 'package:luama/util/user.dart';

import '../../util/Page_animation.dart';

class Nav_ProfileWidget extends StatelessWidget {
  final TUser mySelf;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final UserManager userManager;

  Nav_ProfileWidget({
    super.key,
    required this.mySelf,
    required this.userManager,
  }) {
    nameController.text = mySelf.userName;
    idController.text = mySelf.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // 頭像與名字
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage: NetworkImage(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuA1pxMsTlQZGXqvPKc2d9vBmf3MrnLXQV_wA_imhzxIZS9Pmxy81JTjZqjWiPSzY2aKesfsVvigGo7zWCqqloiKQK9UDdD5kMQ9hTCL1MRujva8df_xlN5GKmeuFlc3upt3TEVcmz-3bNnPlnHRHq5ii6zTJZ4JSyi90PN7lAVVlfAgYLPr8K4cj09dBez5GpJXwGHAuP3qggStGyyURjYfdGE4CWw_8UxwmgZuleho5RmJ0IlgTaFKi4HSLCdj2webq6CfDzi5Ic4N", // 預設圖片
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mySelf.userName ?? 'Ethan Carter',
                      style: const TextStyle(
                        color: Color(0xFF0E1A13),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Edit profile',
                      style: TextStyle(color: Color(0xFF51946C), fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Name 欄位
              _buildInputField('Name', mySelf.userName, nameController),

              // ID欄位
              _buildInputField('Id', mySelf.userId, idController),
            ],
          ),

          // Save 按鈕
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38E07B),
                  foregroundColor: const Color(0xFF0E1A13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (idController.text == "" || nameController.text == "") {
                    SnackMessage(text: "Name 跟 ID 任一不可為空白").show(context);
                    return;
                  }
                  mySelf.userName = idController.text;
                  mySelf.userId = nameController.text;

                  userManager.setupOnMessageReceived(mySelf);
                  mySelf.startClient();
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String value,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0E1A13),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE8F2EC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Enter $label',
              hintStyle: const TextStyle(color: Color(0xFF51946C)),
            ),
            style: const TextStyle(color: Color(0xFF0E1A13), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
