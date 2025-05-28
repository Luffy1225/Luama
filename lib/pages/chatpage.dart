import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:luama/OLDmain.dart';

import '../util/app_colors.dart';
import '../util/user.dart';
import '../util/Page_animation.dart';
import '../util/chatmsg.dart';
import '../util/STTAndTTSManager.dart';

import 'settingpage.dart';
import 'VoiceInterfacePage.dart';

class ChatPage extends StatefulWidget {
  final TUser selfUser;
  final TUser targetUser;

  const ChatPage(this.selfUser, this.targetUser);

  // const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TUser SelfUser;
  late TUser TargetUser;

  bool is_fileExisted = false;
  // bool _isRecording = false; // 是否正在錄音

  final List<ChatMsg> _JSON_ChatHistory = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Function(String)? originalOnMessageReceived; //
  File? _selectedImage; // 加入圖片選擇變數

  // final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    SelfUser = widget.selfUser;
    TargetUser = widget.targetUser;

    _controller.addListener(() {
      setState(() {}); // 輸入框框有值 觸發 UI 更新
    });

    SelfUser.startClient();

    originalOnMessageReceived = (messageString) {
      try {
        // 將 JSON 字串轉換成 ChatMessage 物件
        final jsonData = jsonDecode(messageString);
        final chatmsg = ChatMsg.fromJson(jsonData);

        print(jsonData);

        // 呼叫 UI 更新（只處理物件，不直接處理 json 字串）
        setState(() {
          _JSON_ChatHistory.add(chatmsg);
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

    SelfUser.onMessageReceived = originalOnMessageReceived;
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    ChatMsg message = ChatMsg(
      sender: SelfUser.userName,
      receiver: TargetUser.userName,
      type: whatMsgType(text, _selectedImage),
      content: text,
      timestamp: GetTimeStamp(),
    );

    SelfUser.sendMessage(message);

    setState(() {
      _JSON_ChatHistory.add(message);

      for (int i = 0; i < _JSON_ChatHistory.length; i++) {
        print(ChatMsg2String(_JSON_ChatHistory[i]));
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

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Scaffold(
      backgroundColor: appColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 頂部導覽列
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded),
                    tooltip: '返回',
                    onPressed: _onReturnPressed,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        TargetUser.userName,
                        style: TextStyle(
                          color: appColors.TopBar_Title,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    tooltip: '設定',
                    onPressed: _onSettingsPressed,
                  ),
                ],
              ),
            ),

            Text(
              // 時間
              'Today 10:30 AM',
              style: TextStyle(
                color: appColors.timeTextColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 聊天訊息列表
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _JSON_ChatHistory.length,
                padding: const EdgeInsets.all(16),

                itemBuilder: (context, index) {
                  final isMe =
                      _JSON_ChatHistory[index].sender == SelfUser.userName;

                  return _chatBubble(
                    appColors: appColors,
                    chatmsg: _JSON_ChatHistory[index],
                    isSender: isMe,
                    avatarUrl:
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuB0NDoh9uyWemrItrMIqmxBpLwT2RqSv2NtjYhF4D9iDX1J75gULkNDMYjV6JJ-dR7s0xtmnUfPAR1wyWBiaqI2-NyALX6d_Owu5fV45R7gk8X13WZIi58Sv1Yc7LTODGKkbeoUkRNZIYFmaDSKhbqr56TLLtMRLZ8cNoRSxGT9lGeG_FAbKhinM6plhfiuJKqztkSskWeNFBoQbLJQ22wRvdsa3T8kwXpD6gjIOzPzZIbSkxixfBNAo1W7Dr5TsnZ8EJxIOb34Bxzi",
                  );
                },
              ),
            ),

            // 輸入框區域
            Container(
              color: const Color(0xFFF1F4F2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: appColors.,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        decoration:  InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: appColors.searchBarHintColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) {
                      final hasText = value.text.trim().isNotEmpty;
                      return GestureDetector(
                        onTap: hasText ? _sendMessage : OpenSSTandTTSpage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: appColors.sendButtonBackground,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            hasText ? Icons.arrow_upward : Icons.mic,
                            color: appColors.sendButtonIconColor,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  void OpenSSTandTTSpage() {
    Navigator.of(context)
        .push(
          createRoute(
            VoiceInterfacePage(SelfUser, TargetUser, _JSON_ChatHistory),
            Anima_Direction.FromRightIn,
          ),
        )
        .then((_) {
          SelfUser.onMessageReceived = originalOnMessageReceived;
          setState(() {});
        });
  }

  Widget _chatBubble({
    required ChatMsg chatmsg,
    required bool isSender,
    required String avatarUrl,
    required AppColors appColors,
  }) {
    final alignment =
        isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor =
        isSender
            ? appColors.chatBubbleSender_BGColor
            : appColors.chatBubbleReceiver_BGColor;
    final textColor =
        isSender
            ? appColors.chatBubbleSender_TextColor
            : appColors.chatBubbleReceiver_TextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSender)
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: alignment,
            children: [
              Text(
                chatmsg.sender,
                style: TextStyle(fontSize: 13, color: Color(0xFF688272)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  chatmsg.content,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (isSender)
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
        ],
      ),
    );
  }
}
