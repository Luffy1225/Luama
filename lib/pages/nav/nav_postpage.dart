import 'package:flutter/material.dart';
import 'dart:convert';

import '../../util/user.dart';
import '../../util/app_colors.dart'; // 引用自訂顏色
import '../../util/chatmsg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../util/message_dispatcher.dart'; // 引用自訂顏色

import 'package:uuid/uuid.dart';

var UUID = Uuid();

class Nav_PostWidget extends StatefulWidget {
  final TUser mySelf;
  // final Function(String) OnMessageReceived;

  const Nav_PostWidget({required this.mySelf, super.key});

  @override
  State<Nav_PostWidget> createState() => _Nav_PostWidgetState();
}

class _Nav_PostWidgetState extends State<Nav_PostWidget> {
  PostManager postManager = PostManager();

  bool _isDispatcherInitialized = false;
  var dispatcher = MessageDispatcher();

  @override
  void initState() {
    super.initState();
    _requestFromServer(); // ✅ 初始化時執行並處理 setState
  }

  @override
  void dispose() {
    // if (_isDispatcherInitialized) {
    //   dispatcher.unregisterHandler(ServiceType.request_post);
    //   _isDispatcherInitialized = false;
    // }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registerDispatcherHandlers();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Scaffold(
      body: ListView.builder(
        itemCount: postManager.postList.length,
        itemBuilder: (context, index) {
          final post = postManager.postList[index];
          return PostWidget(post: post);
        },
      ),
      backgroundColor: appColors.ScaffoldBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          EditNewPost(context, (title, content) {
            Post Buildpost = Post(
              userName: widget.mySelf.userName,
              userID: widget.mySelf.userID,
              title: title,
              content: content,
              time: GetNowTimeStamp(),
            );

            setState(() {
              postManager.addNews(Buildpost);
            });
            ChatMsg postmsg = ChatMsg(
              sender: widget.mySelf.userName,
              senderID: widget.mySelf.userID,
              receiver: "LuamaServer",
              timestamp: GetNowTimeStamp(),
              content: jsonEncode(Buildpost.toJson()),
              service: ServiceType.build_post,
              type: MessageType.text,
            );

            widget.mySelf.sendMessage(postmsg);
          });
        },
        shape: const CircleBorder(),
        backgroundColor: appColors.ButtonBGColor,
        child: Icon(Icons.add, color: appColors.TopBar_IconColor),
      ),
    );
  }

  void EditNewPost(
    BuildContext context,
    Function(String title, String content) onPostSubmit,
  ) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "新增貼文",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "標題"),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: "內容"),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    String title = titleController.text.trim();
                    String content = contentController.text.trim();
                    if (title.isNotEmpty || content.isNotEmpty) {
                      onPostSubmit(title, content);
                      Navigator.pop(context); // 關閉 bottom sheet
                    }
                  },
                  child: Text("發佈"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 新增一個發送訊息並接收回應的示範函式
  void _requestFromServer() {
    // 建立一筆要求新聞的 ChatMsg
    ChatMsg Req_NewsMsg = ChatMsg(
      sender: widget.mySelf.userName,
      senderID: widget.mySelf.userID,
      receiver: "NewsServer",
      service: ServiceType.request_post,
      content: "4",
      type: MessageType.text,
      timestamp: GetNowTimeStamp(),
    );

    // widget.mySelf.onMessageReceived = (String jsonMessage) {
    //   List<dynamic> postList = [];
    //   try {
    //     var json_obj = jsonDecode(jsonMessage);
    //     final String userFrom = json_obj["sender"] ?? "";
    //     final String receiver = json_obj["receiver"] ?? "";
    //     final String msgTypeStr = json_obj["type"] ?? "text";
    //     final MessageType msgType = MessageType.values.firstWhere(
    //       (e) => e.toString().split('.').last == msgTypeStr,
    //       orElse: () => MessageType.text,
    //     );

    //     final dynamic contentData = json_obj["content"];
    //     if (contentData is List) {
    //       for (var postInfo in contentData) {
    //         Post post = Post(
    //           userName: postInfo["userName"],
    //           userID: postInfo["userID"],
    //           title: postInfo["title"],
    //           time: postInfo["time"],
    //           content: postInfo["content"],
    //           // comments: postInfo["comments"],
    //         );
    //         postManager.addNews(post);
    //       }
    //     } else {
    //       print("from NAV_POST: ❌ content 欄位不是 List！");
    //     }
    //   } catch (e) {
    //     print("Error: $e");
    //   }
    //   // content 是字串形式的 JSON 陣列 → 再解一次

    //   // ✅ 使用 setState 更新畫面
    //   setState(() {
    //     for (var postInfo in postList) {
    //       Post post = Post(
    //         userName: postInfo["userName"],
    //         userID: postInfo["userid"],
    //         title: postInfo["title"],
    //         time: postInfo["time"],
    //         content: postInfo["content"],
    //         comments: postInfo["comments"],
    //       );
    //       postManager.addNews(post);
    //     }
    //   });
    // };
    widget.mySelf.sendMessage(Req_NewsMsg); // 呼叫發送訊息給 Server
  }

  // 在初始化或 didChangeDependencies 註冊 handler，處理 load_user 的回應
  void _registerDispatcherHandlers() {
    dispatcher = MessageDispatcherProvider.of(context);

    if (_isDispatcherInitialized) return; // 已經註冊過，直接跳過

    dispatcher.registerHandler(ServiceType.request_post, (ChatMsg msg) {
      try {
        final contentData = msg.content; // 假設 content 是 JSON 字串
        final postListJson = jsonDecode(contentData) as List<dynamic>;

        setState(() {
          for (var postInfo in postListJson) {
            Post post = Post(
              userName: postInfo["userName"],
              userID: postInfo["userID"],
              title: postInfo["title"],
              time: postInfo["time"],
              content: postInfo["content"],
              // comments: postInfo["comments"],
            );
            postManager.addNews(post);
          }
        });
      } catch (e) {
        print("解析使用者清單錯誤: $e");
      }
    });
    _isDispatcherInitialized = true; // 避免重複註冊
  }
}

class PostWidget extends StatefulWidget {
  final Post post;
  const PostWidget({required this.post, Key? key}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late String userName;
  late String userid;
  late String title;
  late String time;
  late String content;
  late int likeAmount;
  late List<Post> comments;

  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    likeAmount = widget.post.likeAmount;
    userName = widget.post.userName;
    userid = widget.post.userID;
    title = widget.post.title;
    time = widget.post.time;
    content = widget.post.content;
    likeAmount = widget.post.likeAmount;
    comments = widget.post.comments;
  }

  void _onTapPost(BuildContext context) {
    // 這邊可以實作點擊後跳轉或顯示詳情的功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("點擊了 ${userName} 的貼文")));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onTapPost(context),
        child: Container(
          decoration: BoxDecoration(
            color: appColors.TextBox_Background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 使用者名稱
                Text(
                  "@$userName #$userid",
                  style: TextStyle(
                    color: appColors.PrimaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                /// 標題
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(
                      color: appColors.PrimaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 8),

                /// 內容
                Text(
                  content,
                  style: TextStyle(color: appColors.PrimaryText, fontSize: 16),
                ),

                const SizedBox(height: 12),

                /// 時間與按讚、留言數
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: const Color(0xFFA2B3A9),
                        fontSize: 12,
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // 不撐滿 Row 寬度
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 22,
                              color: isLiked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isLiked = !isLiked;
                                likeAmount += isLiked ? 1 : -1;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "$likeAmount",
                            style: TextStyle(color: Colors.grey),
                            textAlign:
                                TextAlign.left, // 可加可不加，對 Row 中 Text 無明顯影響
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.comment, size: 22, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "${widget.post.comments.length}",
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Post {
  String uuid = '';
  final String userName;
  final String userID;
  final String title;
  final String time;
  final String content;
  List<Post> comments = [];

  int likeAmount = 0;

  Post({
    String? uuid,
    required this.userName,
    required this.userID,
    required this.title,
    required this.time,
    required this.content,
    this.comments = const [],
    this.likeAmount = 0,
  });

  void addComment(Post comment) {
    comments.add(comment);
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "userName": userName,
      "userID": userID,
      "title": title,
      "content": content,
      "likes": likeAmount,
      "time": time,
    };
  }
}

class PostManager {
  final List<Post> postList = [
    // Post(
    //   userName: "alice",
    //   userID: "0324",
    //   title: "Flutter 真香",
    //   time: "2025-06-09 10:00",
    //   content: "最近開始學 Flutter，感覺超有趣！",
    //   comments: [
    //     Post(
    //       userName: "bob",
    //       userID: "3660",
    //       title: "",
    //       time: "2025-06-09 10:05",
    //       content: "真的！我用它做了一個 app！",
    //     ),
    //     Post(
    //       userName: "charlie",
    //       userID: "5812",
    //       title: "",
    //       time: "2025-06-09 10:10",
    //       content: "有推薦的教學影片嗎？",
    //     ),
    //   ],
    // ),

    // Post(
    //   userName: "david",
    //   userID: "7781",
    //   title: "Dart 的 Map 用法分享",
    //   time: "2025-06-08 21:30",
    //   content: "今天學會了 Dart 中 Map 的一些技巧，分享給大家！",
    // ),

    // Post(
    //   userName: "emma",
    //   userID: "0321",
    //   title: "這週學習計畫",
    //   time: "2025-06-07 08:20",
    //   content: "打算這週完成：1. Flutter UI 2. ListView 操作 3. 接 Firebase！",
    //   comments: [
    //     Post(
    //       userName: "frank",
    //       userID: "0317",
    //       title: "",
    //       time: "2025-06-07 09:00",
    //       content: "加油！我也在學類似的內容～",
    //     ),
    //   ],
    // ),
    // Post(
    //   userName: "david",
    //   userID: "7781",
    //   title: "Dart 的 Map 用法分享",
    //   time: "2025-06-08 21:30",
    //   content: "今天學會了 Dart 中 Map 的一些技巧，分享給大家！",
    // ),
  ];

  List<Post> getAllNews() {
    return postList;
  }

  void addNews(Post news) {
    postList.add(news);
  }

  void clearNews() {
    postList.clear();
  }
}
