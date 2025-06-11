import 'package:flutter/material.dart';
import 'dart:convert';

import '../../util/user.dart';
import '../../util/app_colors.dart'; // 引用自訂顏色
import '../../util/chatmsg.dart';
import '../../util/message_dispatcher.dart'; // 引用自訂顏色

import 'package:url_launcher/url_launcher.dart';

class Nav_HomeWidget extends StatefulWidget {
  final TUser mySelf;
  // final Function(String) OnMessageReceived;

  const Nav_HomeWidget({
    required this.mySelf,
    // required this.OnMessageReceived,
    super.key,
  });

  @override
  State<Nav_HomeWidget> createState() => _Nav_HomeWidgetState();
}

class _Nav_HomeWidgetState extends State<Nav_HomeWidget> {
  bool _isDispatcherInitialized = false;
  var dispatcher = MessageDispatcher();

  @override
  void initState() {
    super.initState();
    NewsManager.clearNews();
    _requestFromServer(); // ✅ 初始化時執行並處理 setState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registerDispatcherHandlers();
  }

  @override
  Widget build(BuildContext context) {
    final newsList = NewsManager.getAllNews();

    return SingleChildScrollView(
      child: // 列出新聞
          ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final news = newsList[index];
          return NewsWidget(
            title: news.title,
            time: news.time,
            pictureUrl: news.pictureUrl,
            newsUrl: news.newsUrl,
          );
        },
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

    // widget.mySelf.onMessageReceived = (String jsonMessage) {
    //   List<dynamic> newsList = [];
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
    //       for (var newsInfo in contentData) {
    //         News news = News(
    //           pictureUrl: newsInfo["pictureUrl"],
    //           title: newsInfo["title"],
    //           time: newsInfo["time"],
    //           newsUrl: newsInfo["newsUrl"],
    //         );
    //         NewsManager.addNews(news);
    //       }
    //     } else {
    //       print("from NAV_HOME: ❌ content 欄位不是 List！");
    //     }
    //   } catch (e) {
    //     print("Error: $e");
    //   }
    //   // content 是字串形式的 JSON 陣列 → 再解一次

    //   // ✅ 使用 setState 更新畫面
    //   setState(() {
    //     for (var newsInfo in newsList) {
    //       News news = News(
    //         pictureUrl: newsInfo["pictureUrl"],
    //         title: newsInfo["title"],
    //         time: newsInfo["time"],
    //         newsUrl: newsInfo["newsUrl"],
    //       );
    //       NewsManager.addNews(news);
    //     }
    //   });
    // };
    widget.mySelf.sendMessage(Req_NewsMsg); // 呼叫發送訊息給 Server
  }

  // 在初始化或 didChangeDependencies 註冊 handler，處理 load_user 的回應
  void _registerDispatcherHandlers() {
    dispatcher = MessageDispatcherProvider.of(context);

    if (_isDispatcherInitialized) return; // 已經註冊過，直接跳過

    dispatcher.registerHandler(ServiceType.request_news, (ChatMsg msg) {
      try {
        final contentData = msg.content; // 假設 content 是 JSON 字串
        final newsListJson = jsonDecode(contentData) as List<dynamic>;

        setState(() {
          for (var newsInfo in newsListJson) {
            News news = News(
              pictureUrl: newsInfo["pictureUrl"],
              title: newsInfo["title"],
              time: newsInfo["time"],
              newsUrl: newsInfo["newsUrl"],
            );
            NewsManager.addNews(news);
          }
        });
      } catch (e) {
        print("解析使用者清單錯誤: $e");
      }
    });
    _isDispatcherInitialized = true; // 避免重複註冊
  }
}

class NewsWidget extends StatelessWidget {
  final String pictureUrl;
  final String title;
  final String time;
  final String newsUrl;

  const NewsWidget({
    super.key,
    required this.pictureUrl,
    required this.title,
    required this.time,
    required this.newsUrl,
  });

  void _launchURL(BuildContext context) async {
    final Uri url = Uri.parse(newsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('無法開啟連結')));
    }
  }

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

class News {
  final String pictureUrl;
  final String title;
  final String time;
  final String newsUrl;

  News({
    required this.pictureUrl,
    required this.title,
    required this.time,
    // required this.content,
    required this.newsUrl,
  });
}

class NewsManager {
  static final List<News> _newsList = [
    // News(
    //   pictureUrl: 'https://cdn2.ettoday.net/images/8223/c8223521.jpg',
    //   title: '快訊／三峽重大車禍奪3命！　78歲肇事翁今早不治身亡',
    //   time: "13小時前",
    //   newsUrl: 'https://www.ettoday.net/news/20250531/2970008.htm',
    // ),
    // News(
    //   pictureUrl: 'https://cdn2.ettoday.net/images/8223/c8223521.jpg',
    //   title: '快訊／三峽重大車禍奪3命！　78歲肇事翁今早不治身亡',
    //   time: "13小時前",
    //   newsUrl: 'https://www.ettoday.net/news/20250531/2970008.htm',
    // ),
    // News(
    //   pictureUrl: 'https://cdn2.ettoday.net/images/8223/c8223521.jpg',
    //   title: '快訊／三峽重大車禍奪3命！　78歲肇事翁今早不治身亡',
    //   time: "13小時前",
    //   newsUrl: 'https://www.ettoday.net/news/20250531/2970008.htm',
    // ),
    // // 可以繼續新增多則新聞
  ];

  static List<News> getAllNews() {
    return _newsList;
  }

  static void addNews(News news) {
    _newsList.add(news);
  }

  static void clearNews() {
    _newsList.clear();
  }
}
