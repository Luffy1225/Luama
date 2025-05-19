import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../util/app_colors.dart';
import '../util/user.dart';
import '../util/Page_animation.dart';
import '../util/chatmsg.dart';
import 'settingpage.dart';

class ChatPage extends StatefulWidget {
  final TUser selfUser;
  final TUser targetUser;

  const ChatPage(this.selfUser, this.targetUser);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TUser SelfUser;
  late TUser TargetUser;

  bool is_fileExisted = false;

  final List<ChatMsg> _JSON_messages = [];
  final List<String> _messages = [];
  final List<String> _senders = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  File? _selectedImage; // 加入圖片選擇變數

  @override
  void initState() {
    super.initState();
    SelfUser = widget.selfUser;
    TargetUser = widget.targetUser;

    SelfUser.startClient();

    SelfUser.onMessageReceived = (messageString) {
      try {
        // 將 JSON 字串轉換成 ChatMessage 物件
        final jsonData = jsonDecode(messageString);
        final chatmsg = ChatMsg.fromJson(jsonData);

        print(jsonData);

        // 呼叫 UI 更新（只處理物件，不直接處理 json 字串）
        setState(() {
          _JSON_messages.add(chatmsg);
          // _messages.add(message.content);
          // _senders.add(message.sender);
        });

        Future.delayed(Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } catch (e) {
        print("JSON parsing error: $e");
      }
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

              // itemCount: _messages.length,
              itemCount: _JSON_messages.length,

              itemBuilder: (context, index) {
                // final isMe = _senders[index] == SelfUser.userName;

                final isMe = _JSON_messages[index].sender == SelfUser.userName;

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
                          ),
                          child: Text(
                            // _messages[index],
                            _JSON_messages[index].content,

                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                            textAlign: isMe ? TextAlign.right : TextAlign.left,
                            maxLines: null,
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
                  iconSize: 30,
                  onPressed: () => _showImageOptions(context),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: '輸入訊息...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
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
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    child: Icon(Icons.send_rounded),
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
    if (text.isEmpty && _selectedImage == null) return;

    ChatMsg message = ChatMsg(
      sender: SelfUser.userName,
      type: whatMsgType(text, _selectedImage),
      content: text,
      timestamp: GetTimeStamp(),
    );

    // SelfUser.sendMessage(text);
    SelfUser.sendMessage(message);

    setState(() {
      // _messages.add(text);
      // _senders.add(SelfUser.userName);

      _JSON_messages.add(message);
      for (int i = 0; i < _JSON_messages.length; i++) {
        print(ChatMsg2String(_JSON_messages[i]));
      }
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

  void _onVideoCallPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("視訊功能尚未實作")));
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

  void _showImageOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: Text('選擇圖片來源'),
            actions: [
              CupertinoActionSheetAction(
                child: Text('從相簿選擇'),
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              CupertinoActionSheetAction(
                child: Text('使用相機'),
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('取消'),
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });

      // 這裡你可以選擇直接將圖片的路徑傳送出去，或實作上傳邏輯
      String imagePath = picked.path;
      // SelfUser.sendMessage("[圖片] $imagePath");

      setState(() {
        _messages.add("[圖片] $imagePath");
        _senders.add(SelfUser.userName);
      });

      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }
}
