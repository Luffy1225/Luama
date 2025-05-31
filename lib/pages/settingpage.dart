import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import '../util/user.dart';
import '../util/app_colors.dart'; // 引用自訂顏色
import '../util/chatmsg.dart'; // 引用自訂顏色

class SettingPage extends StatefulWidget {
  final TUser SelfUser;
  final TUser TargetUser;

  const SettingPage(this.SelfUser, this.TargetUser); // <== 新增 constructor 傳入

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _darkMode = false;
  bool _notifications = true;
  double? _fontSize;

  final TextEditingController _fontSizeController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  final TextEditingController _customPromptController = TextEditingController();

  void _connect() {
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();

    if (!isConnectionValid(ip, port)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("請輸入正確的Ip, Port")));
      return;
    }

    // TODO: 在此處加上實際連線邏輯
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("嘗試連線至 $ip:$port")));

    widget.SelfUser.connect(ip, port);
  }

  void setCustomPrompt() {
    final customPrompt = _customPromptController.text;
    ChatMsg setCustomPromptmsg = ChatMsg(
      sender: widget.SelfUser.userName,
      receiver: widget.TargetUser.userName,
      service: ServiceType.ai_reply,
      type: MessageType.system,
      content: "SetCustomPrompt: " + customPrompt,
      timestamp: GetNowTimeStamp(),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("設置System Prompt: $customPrompt.")));

    widget.SelfUser.sendMessage(setCustomPromptmsg);
  }

  void _saveFontSize() {
    final input = _fontSizeController.text;
    final parsed = double.tryParse(input);
    if (parsed != null && parsed > 0) {
      setState(() {
        _fontSize = parsed;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("字體大小已設定為 $_fontSize")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("請輸入有效的數字")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Scaffold(
      backgroundColor: appColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(appColors: appColors),
            Divider(),
            SwitchListTile(
              title: Text(
                "開啟通知",
                style: TextStyle(color: appColors.PrimaryText),
              ),
              subtitle: Text(
                _notifications ? "已開啟" : "已關閉",
                style: TextStyle(color: appColors.PrimaryText),
              ),
              value: _notifications,
              activeColor: Colors.white,
              activeTrackColor: appColors.switchActiveTrack,
              inactiveTrackColor: appColors.switchInactiveTrack,
              onChanged: (bool value) {
                setState(() {
                  _notifications = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                "深色模式",
                style: TextStyle(color: appColors.PrimaryText),
              ),
              subtitle: Text(
                _darkMode ? "已開啟" : "已關閉",
                style: TextStyle(color: appColors.PrimaryText),
              ),
              value: _darkMode,
              activeColor: Colors.white,
              activeTrackColor: appColors.switchActiveTrack,
              inactiveTrackColor: appColors.switchInactiveTrack,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
            Divider(),
            _CustomInputField(appColors: appColors),
            _buildSetCustomPromptButton(appColors: appColors),
            Divider(),
            // Divider(),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       '連線',
            //       style: TextStyle(
            //         fontSize: 22,
            //         fontWeight: FontWeight.bold,
            //         color: appColors.PrimaryText,
            //       ),
            //     ),
            //   ),
            // ),
            // _buildInputField(
            //   label: 'IP Address',
            //   hint: 'Enter IP Address',
            //   appColors: appColors,
            // ),
            // _buildInputField(
            //   label: 'IP Port',
            //   hint: 'Enter IP Port',
            //   appColors: appColors,
            // ),
            // _buildConnectButton(appColors: appColors),
            // Divider(),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       '設定',
            //       style: TextStyle(
            //         fontSize: 22,
            //         fontWeight: FontWeight.bold,
            //         color: appColors.PrimaryText,
            //       ),
            //     ),
            //   ),
            // ),

            // const Padding(
            //   padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       '文字大小',
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: Color(0xFF121614),
            //       ),
            //     ),
            //   ),
            // ),
            // _buildTextSizeButtons(),
            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required AppColors appColors}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: appColors.TopBar_IconColor,
                ),
                tooltip: '返回',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Center(
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appColors.PrimaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required AppColors appColors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: appColors.PrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: appColors.TextBoxHint_Background),
              filled: true,
              fillColor: appColors.TextBox_Background,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetCustomPromptButton({required AppColors appColors}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.buttonBG,
              foregroundColor: appColors.PrimaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              minimumSize: const Size(84, 40),
            ),
            onPressed: () {
              setCustomPrompt();
            },
            child: const Text(
              'Set',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF121614),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Switch(
          //   value: false,
          //   onChanged: (_) {},
          //   activeColor: Colors.white,
          //   activeTrackColor: Color(0xFF79D29B),
          //   inactiveTrackColor: Color(0xFFF1F4F2),
          // ),
          SwitchListTile(
            title: Text(title),
            subtitle: Text(_notifications ? "已開啟" : "已關閉"),
            value: _notifications,

            onChanged: (bool value) {
              setState(() {
                _notifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSizeButton('Large'),
          _buildSizeButton('Medium'),
          _buildSizeButton('Small'),
        ],
      ),
    );
  }

  Widget _buildSizeButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF1F4F2),
        foregroundColor: const Color(0xFF121614),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size(84, 40),
      ),
      onPressed: () {},
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _CustomInputField({required AppColors appColors}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // 加入左右邊界
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors.TextBox_Background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appColors.Secondary_Color),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 165, maxHeight: 165),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _customPromptController, // 綁定 controller
                  maxLines: null,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: '輸入 AI 的 system prompt...',
                    hintStyle: TextStyle(
                      color: appColors.TextBoxHint_Background,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: appColors.PrimaryText),
                  onChanged: (value) {
                    print("System prompt updated: $value");
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _CustomInputField({required AppColors appColors, required BuildContext context}) {
  //   // 計算左右 padding 為畫面寬度的 5%
  //   double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: horizontalPadding), // 自適應左右邊界
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color: appColors.TextBox_Background,
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: appColors.Secondary_Color),
  //       ),
  //       child: Scrollbar(
  //         thumbVisibility: true,
  //         child: SingleChildScrollView(
  //           scrollDirection: Axis.vertical,
  //           child: ConstrainedBox(
  //             constraints: const BoxConstraints(
  //               minHeight: 165,
  //               maxHeight: 165,
  //             ),
  //             child: Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //               child: TextField(
  //                 maxLines: null,
  //                 decoration: InputDecoration(
  //                   isCollapsed: true,
  //                   hintText: '輸入 AI 的 system prompt...',
  //                   hintStyle: TextStyle(color: appColors.TextBoxHint_Background),
  //                   border: InputBorder.none,
  //                 ),
  //                 style: TextStyle(color: appColors.PrimaryText),
  //                 onChanged: (value) {
  //                   print("System prompt updated: $value");
  //                 },
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _fontSizeController.dispose();
    super.dispose();
  }
}

bool isIpValid(String IP) {
  // Simple IPv4 validation
  final parts = IP.split('.');
  if (parts.length != 4) return false;
  for (final part in parts) {
    final n = int.tryParse(part);
    if (n == null || n < 0 || n > 255) return false;
  }
  return true;
}

bool isPortValid(String port) {
  final n = int.tryParse(port);
  return n != null && n > 0 && n <= 65535;
}

bool isConnectionValid(String ip, String port) {
  return isIpValid(ip) && isPortValid(port);
}
