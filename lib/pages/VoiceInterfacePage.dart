import 'package:flutter/material.dart';
import 'dart:convert';

import '../util/STTAndTTSManager.dart';
import '../util/user.dart';
import '../util/chatmsg.dart';

class VoiceInterfacePage extends StatefulWidget {
  final TUser selfUser;
  final TUser targetUser;
  final List<ChatMsg> _JSON_ChatHistory;

  const VoiceInterfacePage(
    this.selfUser,
    this.targetUser,
    this._JSON_ChatHistory,
  );

  @override
  _VoiceInterfacePageState createState() => _VoiceInterfacePageState();
}

class _VoiceInterfacePageState extends State<VoiceInterfacePage> {
  STTAndTTSManager sttTtsManager = STTAndTTSManager();
  late TUser SelfUser;
  late TUser TargetUser;
  late List<ChatMsg> _JSON_ChatHistory;

  bool _isRecording = false;
  String _ShowText = "";

  @override
  void initState() {
    super.initState();
    SelfUser = widget.selfUser;
    TargetUser = widget.targetUser;
    _JSON_ChatHistory = widget._JSON_ChatHistory;

    // 初始化語音辨識
    sttTtsManager.init();

    sttTtsManager.setOnStatusCallback((status) {
      if (!mounted) return;

      setState(() {
        _isRecording = (status == 'listening');
      });
    });

    sttTtsManager.setOnResultCallback((_recognizedText) {
      // 接收到 語音識別的 文字
      if (!mounted) return;

      setState(() {
        _ShowText = _recognizedText;
      });

      ChatMsg chatmsg = ChatMsg(
        sender: SelfUser.userName,
        receiver: TargetUser.userName,
        type: MessageType.text,
        service: ServiceType.ai_reply,
        content: _ShowText,
        timestamp: GetNowTimeStamp(),
      );

      SelfUser.sendMessage(chatmsg);
      _JSON_ChatHistory.add(chatmsg);
    });

    SelfUser.onMessageReceived = (messageString) {
      // 將 JSON 字串轉換成 ChatMessage 物件
      final jsonData = jsonDecode(messageString);
      final chatmsg = ChatMsg.fromJson(jsonData);

      print(jsonData);
      _JSON_ChatHistory.add(chatmsg);

      // 呼叫 UI 更新（只處理物件，不直接處理 json 字串）
      setState(() {
        _ShowText = _JSON_ChatHistory.last.content;
      });
      sttTtsManager.speak(chatmsg.content);
      print("Speak Done");
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 中央圓形圖
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/LuamaCircleArt.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // 圖片與文字之間的間距
                  // Text(
                  //   _recognizedText.isEmpty ? "請按下按鈕開始說話..." : _recognizedText,
                  //   style: TextStyle(color: Colors.white, fontSize: 18),
                  //   textAlign: TextAlign.center,          // 水平置中（可選）
                  //   maxLines: 3,                          // 限制最多 3 行
                  //   overflow: TextOverflow.ellipsis,     // 超出以 "..." 省略
                  //   softWrap: true,                      // 啟用自動換行
                  // ),
                  Container(
                    height: 100, // 可自行調整顯示高度
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Text(
                        _ShowText.isEmpty ? "請按下按鈕開始說話..." : _ShowText,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 左下角麥克風按鈕
            Positioned(
              left: 20,
              bottom: 20,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Color.fromARGB(255, 31, 31, 31),
                child: IconButton(
                  icon: Icon(Icons.mic, color: Colors.white),
                  onPressed: () {
                    sttTtsManager.startListening();
                    // TODO: 麥克風功能
                  },
                ),
              ),
            ),

            // 右下角 X 按鈕
            Positioned(
              right: 20,
              bottom: 20,
              child: CircleAvatar(
                // 退出按鈕
                radius: 30,
                backgroundColor: Color.fromARGB(255, 31, 31, 31),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    sttTtsManager.stopListening();
                    sttTtsManager.Stopspeak();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            // 右上角工具列圖示（加上灰色外框）
            Positioned(
              right: 20,
              top: 20,
              child: Row(
                children: [
                  CircleAvatar(
                    // Info 按鈕
                    radius: 20,
                    backgroundColor: Color.fromARGB(255, 31, 31, 31),
                    child: IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Color.fromARGB(255, 146, 146, 146),
                      ),
                      onPressed: () {
                        // TODO: 顯示資訊
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("功能尚未解鎖")));
                      },
                    ),
                  ),
                  SizedBox(width: 15),
                  CircleAvatar(
                    // 上傳按鈕
                    radius: 20,
                    backgroundColor: Color.fromARGB(255, 31, 31, 31),
                    child: IconButton(
                      icon: Icon(
                        Icons.upload,
                        color: Color.fromARGB(255, 146, 146, 146),
                      ),
                      onPressed: () {
                        // TODO: 上傳功能
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("功能尚未解鎖")));
                      },
                    ),
                  ),
                  SizedBox(width: 15),
                  CircleAvatar(
                    // 調整設定按鈕
                    radius: 20,
                    backgroundColor: Color.fromARGB(255, 31, 31, 31),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: Color.fromARGB(255, 146, 146, 146),
                      ),
                      onPressed: () {
                        // TODO: 調整設定
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("功能尚未解鎖")));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    sttTtsManager.setOnStatusCallback(null);
    sttTtsManager.setOnResultCallback(null);
    sttTtsManager.stopListening();
    sttTtsManager.Stopspeak();
    super.dispose();
  }
}
