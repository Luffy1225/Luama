import 'package:flutter/material.dart';
import '../util/user.dart';

class SettingPage extends StatefulWidget {
  final TUser user; // <== 新增這一行

  const SettingPage({required this.user}); // <== 新增 constructor 傳入

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

  @override
  void dispose() {
    _fontSizeController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(title: Text("設定")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // // 深色模式開關
          // SizedBox(
          //   height: 56,
          //   child: SwitchListTile(
          //     title: Text("深色模式"),
          //     subtitle: Text(_darkMode ? "已開啟" : "已關閉"),
          //     value: _darkMode,
          //     onChanged: (bool value) {
          //       setState(() {
          //         _darkMode = value;
          //       });
          //       // TODO: 可套用深色主題變更
          //     },
          //   ),
          // ),
          // Divider(),
          // // 通知開關
          // SizedBox(
          //   height: 56,
          //   child: SwitchListTile(
          //     title: Text("開啟通知"),
          //     subtitle: Text(_notifications ? "已開啟" : "已關閉"),
          //     value: _notifications,
          //     onChanged: (bool value) {
          //       setState(() {
          //         _notifications = value;
          //       });
          //       // TODO: 可加入通知邏輯
          //     },
          //   ),
          // ),
          // Divider(),
          // // 文字大小設定區塊，高度統一為 56
          // SizedBox(
          //   height: 56,
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 16),
          //     child: Row(
          //       children: [
          //         Text("文字大小", style: TextStyle(fontSize: 16)),
          //         Spacer(), // 推開左邊的文字，讓按鈕靠右
          //         OutlinedButton(
          //           onPressed: () {
          //             _fontSizeController.text = "32";
          //             _saveFontSize();
          //           },
          //           child: Text("大"),
          //         ),
          //         SizedBox(width: 8),
          //         OutlinedButton(
          //           onPressed: () {
          //             _fontSizeController.text = "25";
          //             _saveFontSize();
          //           },
          //           child: Text("中"),
          //         ),
          //         SizedBox(width: 8),
          //         OutlinedButton(
          //           onPressed: () {
          //             _fontSizeController.text = "14";
          //             _saveFontSize();
          //           },
          //           child: Text("小"),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Divider(),
          // ===== 分區一：連線 =====
          Text(
            "連線",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _ipController,
            decoration: InputDecoration(
              labelText: "IP 位址",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _portController,
            decoration: InputDecoration(
              labelText: "Port",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),

          // === 新增的連線按鈕 ===
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _connect,
              icon: Icon(Icons.wifi),
              label: Text("連線"),
            ),
          ),
          Divider(height: 32),

          // ===== 分區二：設定 =====
          Text(
            "設定",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          // 深色模式開關
          SizedBox(
            height: 56,
            child: SwitchListTile(
              title: Text("深色模式"),
              subtitle: Text(_darkMode ? "已開啟" : "已關閉"),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
          ),
          Divider(),

          // 通知開關
          SizedBox(
            height: 56,
            child: SwitchListTile(
              title: Text("開啟通知"),
              subtitle: Text(_notifications ? "已開啟" : "已關閉"),
              value: _notifications,
              onChanged: (bool value) {
                setState(() {
                  _notifications = value;
                });
              },
            ),
          ),
          Divider(),

          // 字體大小設定
          SizedBox(
            height: 56,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text("文字大小", style: TextStyle(fontSize: 16)),
                  Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      _fontSizeController.text = "32";
                      _saveFontSize();
                    },
                    child: Text("大"),
                  ),
                  SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      _fontSizeController.text = "25";
                      _saveFontSize();
                    },
                    child: Text("中"),
                  ),
                  SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      _fontSizeController.text = "14";
                      _saveFontSize();
                    },
                    child: Text("小"),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  void _connect() {
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();

    if (ip.isEmpty || port.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("請輸入 IP 和 Port")));
      return;
    }

    // TODO: 在此處加上實際連線邏輯
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("嘗試連線至 $ip:$port")));

    widget.user.connect(ip, port);
  }
}
