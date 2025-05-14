import 'package:flutter/material.dart';

import '../util/app_colors.dart'; // 引用自訂顏色
import '../util/user.dart';
import '../util/Page_animation.dart';

import 'settingpage.dart';

class ChatPage extends StatefulWidget {
  final TUser selfUser;
  final TUser targetUser;

  // 定義建構子來接收自訂參數
  const ChatPage(this.selfUser, this.targetUser);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TUser SelfUser;
  late TUser TargetUser;

  final List<String> _messages = [];
  final List<String> _senders = []; // 記錄每條訊息的發送者
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 使用傳遞的參數來初始化 SelfUser 和 TargetUser
    SelfUser = widget.selfUser;
    TargetUser = widget.targetUser;

    // TargetUser.startServer();
    SelfUser.startClient();

    // 自己收到訊息callback
    SelfUser.onMessageReceived = (message) {
      setState(() {
        _messages.add(message);
        _senders.add(TargetUser.userName); // 表示這是伺服器發送的訊息
      });

      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TargetUser.userName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: '返回',
          onPressed: _onReturnPressed,
        ),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            tooltip: '打電話',
            onPressed: _onCallPressed,
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            tooltip: '視訊',
            onPressed: _onVideoCallPressed,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: '設定',
            onPressed: _onSettingsPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isMe =
                    _senders[index] ==
                    SelfUser.userName; // 判斷這條訊息是否是自己發送的 /////////

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          isMe ? AppColors.userMessage : AppColors.otherMessage,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(13),
                        topRight: Radius.circular(13),
                        bottomLeft: Radius.circular(isMe ? 13 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 13),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMe ? SelfUser.userName : TargetUser.userName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isMe ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ), // 設定最大寬度
                          child: Text(
                            _messages[index],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                            textAlign:
                                isMe
                                    ? TextAlign.right
                                    : TextAlign.left, // 根據發送者調整對齊方式
                            maxLines: null, // 允許多行顯示
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // 處理點擊事件
                  },
                  iconSize: 30, // 控制 + 按鈕的大小
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 50, // 設定 TextField 的高度
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: '輸入訊息...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        // 調整上下內部間距，避免文字被截斷
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  height: 50, // 設定發送按鈕的高度
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    child: Text("發送"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    SelfUser.sendMessage(text);

    setState(() {
      _messages.add(text);
      _senders.add(SelfUser.userName); // client 傳出的
    });

    _controller.clear();

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _onCallPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("打電話功能尚未實作")));
  }

  void _onReturnPressed() {
    SelfUser.closeConnection();
    Navigator.pop(context);
  }

  void _onSettingsPressed() {
    Navigator.of(context).push(
      createRoute(
        SettingPage(user: widget.selfUser),
        Anima_Direction.FromRightIn,
      ),
    );
  }

  void _onVideoCallPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("視訊功能尚未實作")));
  }
}
