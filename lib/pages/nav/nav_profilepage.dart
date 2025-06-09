import 'package:flutter/material.dart';
import 'package:luama/pages/serversettingpage.dart';
import 'package:luama/util/user.dart';

import '../../util/Page_animation.dart';
import '../../util/app_colors.dart';

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
    final appColors = AppColorsProvider.of(context);

    return Scaffold(
      backgroundColor: appColors.ScaffoldBackground,
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
                      mySelf.userName,
                      style: TextStyle(
                        color: appColors.PrimaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'id :${mySelf.userId}',
                      style: TextStyle(
                        color: appColors.SearchBarHintColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Name 欄位
              _buildInputField(
                context,
                'Name',
                mySelf.userName,
                nameController,
              ),

              // ID欄位
              _buildInputField(context, 'Id', mySelf.userId, idController),
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
                  backgroundColor: appColors.ButtonBGColor,
                  foregroundColor: appColors.PrimaryText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (idController.text == "" || nameController.text == "") {
                    SnackMessage(text: "Name 跟 ID 任一不可為空白").show(context);
                    return;
                  }

                  mySelf.userName = nameController.text;
                  mySelf.userId = idController.text;
                  (context as Element).markNeedsBuild();

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
    BuildContext context,
    String label,
    String value,
    TextEditingController controller,
  ) {
    final appColors = AppColorsProvider.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: appColors.PrimaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: appColors.TextBox_Background,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: appColors.SettingTextHintColor),
            ),
            style: TextStyle(color: appColors.SettingTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
