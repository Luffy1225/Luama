import 'package:flutter/material.dart';
import 'dart:convert';

import '../../util/user.dart';
import '../../util/app_colors.dart'; // 引用自訂顏色
import '../../util/chatmsg.dart';
import 'package:url_launcher/url_launcher.dart';

class Nav_PostWidget extends StatefulWidget {
  final TUser mySelf;
  // final Function(String) OnMessageReceived;

  const Nav_PostWidget({required this.mySelf, super.key});

  @override
  State<Nav_PostWidget> createState() => _Nav_PostWidgetState();
}

class _Nav_PostWidgetState extends State<Nav_PostWidget> {
  PostManager postManager = PostManager();

  @override
  void initState() {
    super.initState();
    _requestFromServer(); // ✅ 初始化時執行並處理 setState
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Threads 範例',
      home: Scaffold(
        appBar: AppBar(title: Text("Threads 簡易版")),
        body: ListView.builder(
          itemCount: postManager.postList.length,
          itemBuilder: (context, index) {
            final post = postManager.postList[index];
            return PostWidget(post: post);
          },
        ),
      ),
    );
  }

  // 新增一個發送訊息並接收回應的示範函式
  void _requestFromServer() {
    // 建立一筆要求新聞的 ChatMsg
    ChatMsg Req_NewsMsg = ChatMsg(
      sender: widget.mySelf.userName,
      receiver: "NewsServer",
      service: ServiceType.request_news,
      content: "4",
      type: MessageType.request_news,
      timestamp: GetNowTimeStamp(),
    );

    widget.mySelf.onMessageReceived = (String jsonMessage) {
      List<dynamic> newsList = [];
      try {
        var json_obj = jsonDecode(jsonMessage);
        final String userFrom = json_obj["sender"] ?? "";
        final String receiver = json_obj["receiver"] ?? "";
        final String msgTypeStr = json_obj["type"] ?? "text";
        final MessageType msgType = MessageType.values.firstWhere(
          (e) => e.toString().split('.').last == msgTypeStr,
          orElse: () => MessageType.text,
        );

        final dynamic contentData = json_obj["content"];
        if (contentData is List) {
          for (var newsInfo in contentData) {
            Post news = Post(
              pictureUrl: newsInfo["pictureUrl"],
              title: newsInfo["title"],
              time: newsInfo["time"],
              newsUrl: newsInfo["newsUrl"],
            );
            NewsManager.addNews(news);
          }
        } else {
          print("❌ content 欄位不是 List！");
        }
      } catch (e) {
        print("Error: $e");
      }
      // content 是字串形式的 JSON 陣列 → 再解一次

      // ✅ 使用 setState 更新畫面
      setState(() {
        for (var newsInfo in newsList) {
          Post news = Post(
            pictureUrl: newsInfo["pictureUrl"],
            title: newsInfo["title"],
            time: newsInfo["time"],
            newsUrl: newsInfo["newsUrl"],
          );
          NewsManager.addNews(news);
        }
      });
    };
    widget.mySelf.sendMessage(Req_NewsMsg); // 呼叫發送訊息給 Server
  }
}

class PostWidget extends StatelessWidget {
  final String post_Username;
  final String title;
  final String time;
  final String content;

  PostWidget({super.key, required Post post})
    : post_Username = post.post_Username,
      title = post.title,
      time = post.time,
      content = post.content;

  int likeAmount = 0;
  List<Post> comments = [];

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _launchURL(context),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(pictureUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: appColors.PrimaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: const Color(0xFFA2B3A9))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Post {
  final String post_Username;
  final String title;
  final String time;
  final String content;

  int likeAmount = 0;
  List<Post> comments = [];

  Post({
    required this.post_Username,
    required this.title,
    required this.time,
    required this.content,
  });

  void addComment(Post comment) {
    comments.add(comment);
  }
}

class PostManager {
  final List<Post> postList = [
    Post(
        post_Username: "alice",
        title: "Flutter 真香",
        time: "2025-06-09 10:00",
        content: "最近開始學 Flutter，感覺超有趣！",
      )
      ..comments = [
        Post(
          post_Username: "bob",
          title: "",
          time: "2025-06-09 10:05",
          content: "真的！我用它做了一個 app！",
        ),
        Post(
          post_Username: "charlie",
          title: "",
          time: "2025-06-09 10:10",
          content: "有推薦的教學影片嗎？",
        ),
      ],

    Post(
      post_Username: "david",
      title: "Dart 的 Map 用法分享",
      time: "2025-06-08 21:30",
      content: "今天學會了 Dart 中 Map 的一些技巧，分享給大家！",
    ),

    Post(
        post_Username: "emma",
        title: "這週學習計畫",
        time: "2025-06-07 08:20",
        content: "打算這週完成：1. Flutter UI 2. ListView 操作 3. 接 Firebase！",
      )
      ..comments = [
        Post(
          post_Username: "frank",
          title: "",
          time: "2025-06-07 09:00",
          content: "加油！我也在學類似的內容～",
        ),
      ],
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
