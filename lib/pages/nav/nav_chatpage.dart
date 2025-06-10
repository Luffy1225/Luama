import 'package:flutter/material.dart';
import 'dart:convert';



import '../../util/user.dart';
import '../../util/chatmsg.dart';
import '../../util/app_colors.dart'; // 引用自訂顏色
import '../../util/Page_animation.dart';

import '../chatpage.dart';

// class Nav_ChatWidget extends StatelessWidget {
//   final TUser mySelf;
//   final UserManager userManager;
//   // final AppColors appColors;

//   // final List<ChatMsg> _JSON_ChatHistory = [];
//   // final Map<String, List<ChatMsg>> userChatHistory = {};

//   const Nav_ChatWidget({
//     required this.mySelf,
//     required this.userManager,
//     // required this.appColors,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: userManager.length,
//       itemBuilder: (context, index) {
//         TUser user = userManager.getUserbyIndex(index);
//         return ContactItem(
//           user: user,
//           imageUrl:
//               'https://lh3.googleusercontent.com/aida-public/AB6AXuBIHF7EUmgGz-GfxYYs8sA6b_AoLTVatLIjS-_6ZJEQUKLoA9wYwtaWAgokmhYdeWm0Wkfqc5PZ1dXDSHVP-Kh_evGtg--cIE2aY2V04HsROqySx5qPFrLoFj06fm7Xtl3k50YzgLbZJQtu7nOQnJjehfbq1yXdRvap9IkB1yoZ3wddjJ5GJYjaqStHd2QqmLrPitZf2e3C7YWge3qlQikYOkd9AMhCezsTGPeReDLg69Xm-HBSbxKQeYvE4nbheCfA4Tq4eg6V_UIt',
//           onTap: () {
//             Navigator.of(context).push(
//               createRoute(
//                 ChatPage(
//                   mySelf,
//                   userManager.getUserbyIndex(index),
//                   userManager,
//                 ),
//                 Anima_Direction.FromRightIn,
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // 新增一個發送訊息並接收回應的示範函式
//   void _requestFromServer() {
//     // 建立一筆要求新聞的 ChatMsg
//     ChatMsg Req_load_user_Msg = ChatMsg(
//       sender: mySelf.userName,
//       receiver: "NewsServer",
//       service: ServiceType.load_user,
//       content: "",
//       type: MessageType.text,
//       timestamp: GetNowTimeStamp(),
//     );

//     mySelf.onMessageReceived = (String jsonMessage) {
//       List<dynamic> userList = [];
//       try {
//         var json_obj = jsonDecode(jsonMessage);
//         final String userFrom = json_obj["sender"] ?? "";
//         final String receiver = json_obj["receiver"] ?? "";
//         final String msgTypeStr = json_obj["type"] ?? "text";
//         final MessageType msgType = MessageType.values.firstWhere(
//           (e) => e.toString().split('.').last == msgTypeStr,
//           orElse: () => MessageType.text,
//         );

//         final dynamic contentData = json_obj["content"];
//         if (contentData is List) {
//           for (var usersInfo in contentData) {
//             TUser user = TUser(
//               userID: usersInfo["userID"],
//               userName: usersInfo["userName"],
//               profileImage: usersInfo["profileImage"],
//               email: usersInfo["email"],
//             );
//             userManager.addUser(user);
//           }
//         } else {
//           print("❌ content 欄位不是 List！");
//         }
//       } catch (e) {
//         print("Error: $e");
//       }
//       // content 是字串形式的 JSON 陣列 → 再解一次

//       // ✅ 使用 setState 更新畫面
//       setState(() {
//         for (var usersInfo in userList) {
//           TUser news = TUser(
//             userID: usersInfo["userID"],
//             userName: usersInfo["userName"],
//             profileImage: usersInfo["profileImage"],
//             email: usersInfo["email"],
//           );
//           userManager.addUser(news);
//         }
//       });
//     };
//     mySelf.sendMessage(Req_load_user_Msg); // 呼叫發送訊息給 Server
//   }

// }



class Nav_ChatWidget extends StatefulWidget {
  final TUser mySelf;
  final UserManager userManager;

  const Nav_ChatWidget({
    required this.mySelf,
    required this.userManager,
    super.key,
  });

  @override
  State<Nav_ChatWidget> createState() => _Nav_ChatWidgetState();
}

class _Nav_ChatWidgetState extends State<Nav_ChatWidget> {

  final List<ChatMsg> _JSON_ChatHistory = [];
  final Map<String, List<ChatMsg>> userChatHistory = {};

  @override
  void initState() {
    super.initState();
    _requestFromServer();
  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.userManager.length,
      itemBuilder: (context, index) {
        TUser user = widget.userManager.getUserbyIndex(index);
        return ContactItem(
          user: user,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBIHF7EUmgGz-GfxYYs8sA6b_AoLTVatLIjS-_6ZJEQUKLoA9wYwtaWAgokmhYdeWm0Wkfqc5PZ1dXDSHVP-Kh_evGtg--cIE2aY2V04HsROqySx5qPFrLoFj06fm7Xtl3k50YzgLbZJQtu7nOQnJjehfbq1yXdRvap9IkB1yoZ3wddjJ5GJYjaqStHd2QqmLrPitZf2e3C7YWge3qlQikYOkd9AMhCezsTGPeReDLg69Xm-HBSbxKQeYvE4nbheCfA4Tq4eg6V_UIt',
          onTap: () {
            Navigator.of(context).push(
              createRoute(
                ChatPage(
                  widget.mySelf,
                  widget.userManager.getUserbyIndex(index),
                  widget.userManager,
                ),
                Anima_Direction.FromRightIn,
              ),
            );
          },
        );
      },
    );
  }

  // 新增一個發送訊息並接收回應的示範函式
  void _requestFromServer() {
    // 建立一筆要求新聞的 ChatMsg
    ChatMsg Req_load_user_Msg = ChatMsg(
      sender: widget.mySelf.userName,
      senderID: widget.mySelf.userID,
      receiver: "NewsServer",
      service: ServiceType.load_user,
      content: "",
      type: MessageType.text,
      timestamp: GetNowTimeStamp(),
    );

    widget.mySelf.onMessageReceived = (String jsonMessage) { // 可能會收到 Login_Regist 的回應， 跟USer有人傳訊息過來， 跟loadUser
      List<dynamic> userList = [];
      try {
        var json_obj = jsonDecode(jsonMessage);
        final String userFrom = json_obj["sender"] ?? "";
        final String receiver = json_obj["receiver"] ?? "";
        final String msgTypeStr = json_obj["type"] ?? "text";
        // final ServiceType serviceType = json_obj["service"] ?? "text";
        final MessageType msgType = MessageType.values.firstWhere(
          (e) => e.toString().split('.').last == msgTypeStr,
          orElse: () => MessageType.text,
        );

        // if(serviceType == ServiceType.load_user){   //處理 讀取用戶的部分
          final dynamic contentData = json_obj["content"];
          // if (contentData is List) {
            for (var usersInfo in contentData) {
              TUser user = TUser(
                userID: usersInfo["userID"],
                userName: usersInfo["userName"],
                profileImage: usersInfo["profileImage"],
                email: usersInfo["email"],
                isAIAgent: usersInfo["isAIAgent"],
              );
              widget.userManager.addUser(user);
            }

        // }
        // } else {
        //   print("❌ content 欄位不是 List！");
        // }
      } catch (e) {
        print("Error: $e");
      }
      // content 是字串形式的 JSON 陣列 → 再解一次

      // ✅ 使用 setState 更新畫面
      setState(() {
        for (var usersInfo in userList) {
          TUser news = TUser(
            userID: usersInfo["userID"],
            userName: usersInfo["userName"],
            profileImage: usersInfo["profileImage"],
            email: usersInfo["email"],
            isAIAgent: usersInfo["isAIAgent"],
          );
          widget.userManager.addUser(news);
        }
      });
    };
    widget.mySelf.sendMessage(Req_load_user_Msg); // 呼叫發送訊息給 Server
  }

}




class ContactItem extends StatelessWidget {
  final TUser user;

  final String imageUrl;
  final VoidCallback? onTap; // 可選的點擊事件

  const ContactItem({
    required this.user,
    required this.imageUrl,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return InkWell(
      onTap: onTap, // 當被點擊時呼叫
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: appColors.ContactItemUserName,
                    ),
                  ),
                  Text(
                    "Message example",
                    style: TextStyle(
                      fontSize: 14,
                      color: appColors.ContactItemMessage,
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
}
