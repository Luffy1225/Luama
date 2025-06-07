import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';

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
  final UserManager userManager;

  const ChatPage(this.selfUser, this.targetUser, this.userManager);

  // const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TUser SelfUser;
  late TUser TargetUser;

  bool is_fileExisted = false;
  // bool _isRecording = false; // 是否正在錄音

  List<ChatMsg> _JSON_ChatHistory = [];
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
    _JSON_ChatHistory = widget.userManager.getChatHistory(TargetUser.userId);
    TargetUser = widget.targetUser;
    _controller.addListener(() {
      setState(() {}); // 輸入框框有值 觸發 UI 更新
    });

    widget.userManager.addListener(_updateChatHistory);

    // SelfUser.startClient();

    // originalOnMessageReceived = (messageString) {
    //   try {
    //     // 將 JSON 字串轉換成 ChatMessage 物件
    //     final jsonData = jsonDecode(messageString);
    //     final chatmsg = ChatMsg.fromJson(jsonData);

    //     print(jsonData);

    //     // 呼叫 UI 更新（只處理物件，不直接處理 json 字串）
    //     setState(() {
    //       _JSON_ChatHistory.add(chatmsg);
    //     });

    //     Future.delayed(Duration(milliseconds: 100), () {
    //       _scrollController.animateTo(
    //         _scrollController.position.maxScrollExtent,
    //         duration: Duration(milliseconds: 300),
    //         curve: Curves.easeOut,
    //       );
    //     });
    //   } catch (e) {
    //     print("JSON parsing error: $e");
    //   }
    // };

    // SelfUser.onMessageReceived = originalOnMessageReceived;
  }

  void _updateChatHistory() {
    if (!mounted) return; // 如果已經 dispose，直接跳過

    setState(() {
      _JSON_ChatHistory = widget.userManager.getChatHistory(TargetUser.userId);
    });

    // 自動滾到最底
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    ServiceType _service = ServiceType.none;
    if (TargetUser.isAIAgent) {
      _service = ServiceType.ai_reply;
    } else {
      _service = ServiceType.send_user_to_user;
    }

    ChatMsg message = ChatMsg(
      sender: SelfUser.userName,
      senderID: SelfUser.userId,
      receiver: TargetUser.userName,
      receiverID: TargetUser.userId,
      service: _service,
      type: whatMsgType(text, _selectedImage),
      content: text,
      timestamp: GetNowTimeStamp(),
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
      backgroundColor: appColors.ScaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 頂部導覽列
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 中央標題
                    Center(
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
                    // 左側返回按鈕
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: appColors.TopBar_IconColor,
                        ),
                        tooltip: '返回',
                        onPressed: _onReturnPressed,
                      ),
                    ),
                    _buildRightIconRegion(
                      widget.targetUser.isAIAgent,
                      appColors,
                    ),
                  ],
                ),
              ),
            ),

            // 聊天訊息列表
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _JSON_ChatHistory.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final currentMsg = _JSON_ChatHistory[index];
                  final previousMsg =
                      index > 0 ? _JSON_ChatHistory[index - 1] : null;

                  DateTime currentTime = ParseToDatetime(currentMsg.timestamp);
                  DateTime? prevTime;
                  if (previousMsg != null) {
                    prevTime = ParseToDatetime(previousMsg.timestamp);
                  }

                  final showTimeLabel =
                      prevTime == null ||
                      currentTime.difference(prevTime).inMinutes >= 1 ||
                      currentTime.day != prevTime.day;

                  final isMe =
                      _JSON_ChatHistory[index].sender == SelfUser.userName;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showTimeLabel)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              _formatTimeLabel(currentTime),
                              style: TextStyle(
                                color: appColors.TimeTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      _chatBubble(
                        appColors: appColors,
                        chatmsg: currentMsg,
                        isSender: isMe,
                        avatarUrl:
                            "https://lh3.googleusercontent.com/aida-public/AB6AXuB0NDoh9uyWemrItrMIqmxBpLwT2RqSv2NtjYhF4D9iDX1J75gULkNDMYjV6JJ-dR7s0xtmnUfPAR1wyWBiaqI2-NyALX6d_Owu5fV45R7gk8X13WZIi58Sv1Yc7LTODGKkbeoUkRNZIYFmaDSKhbqr56TLLtMRLZ8cNoRSxGT9lGeG_FAbKhinM6plhfiuJKqztkSskWeNFBoQbLJQ22wRvdsa3T8kwXpD6gjIOzPzZIbSkxixfBNAo1W7Dr5TsnZ8EJxIOb34Bxzi",
                      ),
                    ],
                  );

                  // return _chatBubble(
                  //   appColors: appColors,
                  //   chatmsg: _JSON_ChatHistory[index],
                  //   isSender: isMe,
                  //   avatarUrl:
                  //       "https://lh3.googleusercontent.com/aida-public/AB6AXuB0NDoh9uyWemrItrMIqmxBpLwT2RqSv2NtjYhF4D9iDX1J75gULkNDMYjV6JJ-dR7s0xtmnUfPAR1wyWBiaqI2-NyALX6d_Owu5fV45R7gk8X13WZIi58Sv1Yc7LTODGKkbeoUkRNZIYFmaDSKhbqr56TLLtMRLZ8cNoRSxGT9lGeG_FAbKhinM6plhfiuJKqztkSskWeNFBoQbLJQ22wRvdsa3T8kwXpD6gjIOzPzZIbSkxixfBNAo1W7Dr5TsnZ8EJxIOb34Bxzi",
                  // );
                },
              ),
            ),

            // 輸入框區域
            Container(
              color: appColors.InputAreaBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: appColors.TextBox_Background,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(
                            color: appColors.TextBoxHint_Background,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: appColors.PrimaryText),
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
                            color: appColors.SendButtonBackground,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            hasText ? Icons.arrow_upward : Icons.mic,
                            color: appColors.SendButtonIconColor,
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
    Navigator.pop(context);
  }

  void _onSettingsPressed() {
    Navigator.of(context).push(
      createRoute(
        SettingPage(SelfUser, TargetUser),
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
            ? appColors.ChatBubbleSender_BGColor
            : appColors.ChatBubbleReceiver_BGColor;
    final textColor =
        isSender
            ? appColors.ChatBubbleSender_TextColor
            : appColors.ChatBubbleReceiver_TextColor;

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

  String _formatTimeLabel(DateTime timestamp) {
    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final ampm = timestamp.hour >= 12 ? 'Pm' : 'Am';
    return '$hour:$minute $ampm';
  }

  void ResetAIAgent() {
    // TODO
    ChatMsg Resetmessage = ChatMsg(
      sender: SelfUser.userName,
      senderID: SelfUser.userId,
      receiver: TargetUser.userName,
      receiverID: TargetUser.userId,
      service: ServiceType.ai_reply,
      type: MessageType.system,
      content: "Reset",
      timestamp: GetNowTimeStamp(),
    );

    SelfUser.sendMessage(Resetmessage);

    SnackMessage(text: "重設AI").show(context);
  }

  Widget _buildRightIconRegion(bool isAgent, AppColors appColors) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAgent)
            IconButton(
              icon: Icon(Icons.restart_alt, color: appColors.TopBar_IconColor),
              tooltip: '重設AIAgent',
              onPressed: ResetAIAgent,
            ),
          IconButton(
            icon: Icon(Icons.settings, color: appColors.TopBar_IconColor),
            tooltip: '設定',
            onPressed: _onSettingsPressed,
          ),
        ],
      ),
    );
  }
}
