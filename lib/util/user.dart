// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'message_dispatcher.dart';

import 'client.dart';
import 'server.dart';
import 'chatmsg.dart';

class TUser {
  //User Information
  String userID; // 用戶ID，可以用來識別不同的用戶
  String userName; // 用戶名稱
  String profileImage; // 使用者頭像URL
  String email; // 使用者電子郵件
  bool isOnline = false; // 使用者是否在線上

  bool isAIAgent = false;

  IconData iconData = Icons.person;

  late Server server;
  late Client client;

  static const DEFAULT_IP = "4.tcp.ngrok.io";
  static const int DEFAULT_PORT = 11419;

  // 建構子
  TUser({
    required this.userID,
    required this.userName,
    required this.profileImage,
    required this.email,
    IconData? iconData, // 可選的 icon 參數
    bool? isAIAgent,
  }) : iconData = iconData ?? Icons.person,
       isAIAgent = isAIAgent ?? false {
    // server = Server(ip: DEFAULT_IP, port: DEFAULT_PORT, userName: userName);
    client = Client(ip: DEFAULT_IP, port: DEFAULT_PORT, userName: userName);

    isOnline = true; // 預設值為 false，表示離線
  }

  // 用來顯示使用者訊息的函式
  @override
  String toString() {
    return 'User{id: $userID, name: $userName, email: $email, isOnline: $isOnline}';
  }

  // 更新使用者的在線狀態
  void updateOnlineStatus(bool status) {
    isOnline = status;
  }

  // 用來檢查是否為有效使用者
  bool isValidUser() {
    return userID.isNotEmpty && userName.isNotEmpty && email.isNotEmpty;
  }

  // 發送訊息給該用戶
  void sendRawMessage(String message) {
    if (client.isConnected) {
      client.sendMessage(message);
    } else {
      client.connectToServer();
      client.sendMessage(message);
    }
  }

  Future<void> sendMessage(ChatMsg chatmsg) async {
    String message = ChatMsg2String(chatmsg);

    if (client.isConnected) {
      client.sendMessage(message);
    } else {
      await client.connectToServer();
      client.sendMessage(message);
    }
  }

  void SetIP(String IP) {
    if (isIpValid(IP)) {
      client.ip = IP;
    } else {
      return;
    }
  }

  void SetPort(String portstr) {
    if (isPortValid(portstr)) {
      final port = int.tryParse(portstr);
      client.port = port!;
    } else {
      return;
    }
  }

  bool isIpValid(String IP) {
    return true; // Bypassed because the Ngrok server uses an invalid IP address in this region

    // // Simple IPv4 validation
    // final parts = IP.split('.');
    // if (parts.length != 4) return false;
    // for (final part in parts) {
    //   final n = int.tryParse(part);
    //   if (n == null || n < 0 || n > 255) return false;
    // }
    // return true;
  }

  bool isPortValid(String port) {
    final n = int.tryParse(port);
    return n != null && n > 0 && n <= 65535;
  }

  bool isConnectionValid(String ip, String port) {
    return isIpValid(ip) && isPortValid(port);
  }

  //  void sendMessage(ChatMsg chatmsg) {
  //   String message = ChatMsg2String(chatmsg);

  //   if (client.isConnected) {
  //     client.sendMessage(message);
  //   } else {
  //     client.connectToServer();
  //     client.sendMessage(message);
  //   }
  // }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TUser &&
          runtimeType == other.runtimeType &&
          userID == other.userID &&
          userName == other.userName &&
          email == other.email;

  // 關閉與該用戶的 Socket 連線
  void closeConnection() {
    client.closeConnection();
  }

  void startServer() {
    server.startServer();
  }

  void startClient() async {
    // client.connectToServer();
    await client.connectToServer();
    sendMessage(buildLoginChatMsg());
  }

  void connect(String ip, String port) {
    client.connectToServer(ip_: ip, port_: int.tryParse(port));
  }

  set onMessageReceived(Function(String message)? handler) {
    client.onMessageReceived = handler;
  }

  /// 將 TUser 轉為 Map
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'userName': userName,
      'profileImage': profileImage,
      'email': email,
      'isOnline': isOnline,
      'isAIAgent': isAIAgent,
    };
  }

  /// 儲存 JSON 資料到檔案
  void save2Json(String path) async {
    final file = File('user_$userID.json');
    String jsonData = jsonEncode(toJson());
    await file.writeAsString(jsonData);
    print('User data saved to user_$userID.json');
  }

  /// 將 JSON Map 還原為 TUser 物件
  TUser readfromJson(Map<String, dynamic> json) {
    return TUser(
      userID: json['userID'],
      userName: json['userName'],
      profileImage: json['profileImage'],
      email: json['email'],
    );
  }

  ChatMsg buildLoginChatMsg() {
    Map<String, dynamic> UserJsonInfo = toJson();

    return ChatMsg(
      sender: userName,
      senderID: userID,
      receiver: "LuamaServer",
      service: ServiceType.loginRegist,
      type: MessageType.text,
      content: jsonEncode(UserJsonInfo), // 把User
      timestamp: GetNowTimeStamp(),
    );
  }
}

enum SortRule { by_ID, by_Name, by_Time }

class UserManager extends ChangeNotifier {
  List<TUser> users = [];

  // 用 userID 作為 key，對應該使用者的聊天紀錄
  Map<String, List<ChatMsg>> userChatHistories = {};

  UserManager() {
    loadSampleUser();
  }

  void loadSampleUser() {
    users = [
      TUser(
        userID: "0001",
        userName: "llama3.2:latest",
        profileImage: "",
        email: "",
        isAIAgent: true,
      ),
      TUser(
        userID: "0002",
        userName: "deepseek-r1:7b",
        profileImage: "",
        email: "",
        isAIAgent: true,
      ),
      // TUser(userID: "0003", userName: "Yuniko", profileImage: "", email: ""),
      // TUser(userID: "0004", userName: "Nami", profileImage: "", email: ""),
      TUser(userID: "0005", userName: "Usopp", profileImage: "", email: ""),
      // TUser(userID: "0006", userName: "Sanji", profileImage: "", email: ""),
      // TUser(userID: "0007", userName: "Chopper", profileImage: "", email: ""),
      // TUser(userID: "0008", userName: "Robin", profileImage: "", email: ""),
      // TUser(userID: "0009", userName: "Franky", profileImage: "", email: ""),
      // TUser(userID: "0000", userName: "Brook", profileImage: "", email: ""),
      // TUser(userID: "0011", userName: "Jinbe", profileImage: "", email: ""),
      // TUser(userID: "0012", userName: "Vivi", profileImage: "", email: ""),
      // TUser(userID: "0013", userName: "Carrot", profileImage: "", email: ""),
      // TUser(userID: "0014", userName: "Yamato", profileImage: "", email: ""),
      // TUser(userID: "0015", userName: "Bonney", profileImage: "", email: ""),
      // TUser(userID: "0016", userName: "Hancock", profileImage: "", email: ""),
    ];
  }

  void addUser(TUser user) {
    if (!users.contains(user)) {
      users.add(user);
      // notifyListeners();  // 如果你需要讓 UI 更新，可以呼叫這個
    } else {
      print("用戶已存在，未重複加入: ${user.userID}");
    }
  }

  bool ifUserExist(TUser user) {
    if (!users.contains(user)) {
      return false;
    } else {
      return true;
    }
  }

  void sortBy(SortRule rule) {
    switch (rule) {
      case SortRule.by_ID:
        users.sort((a, b) => a.userID.compareTo(b.userID));
        break;
      case SortRule.by_Name:
        users.sort((a, b) => a.userName.compareTo(b.userName));
        break;
      case SortRule.by_Time:
        // Implement sorting by time if TUser has a time property
        break;
    }
  }

  TUser getUserbyIndex(int index) {
    return users[index];
  }

  void loadUserChatHistories() {}

  void addChatMessage(String userID, ChatMsg msg) {
    if (!userChatHistories.containsKey(userID)) {
      userChatHistories[userID] = [];
    }
    userChatHistories[userID]!.add(msg);
    notifyListeners();
  }

  // void setupOnMessageReceived(TUser user) {
  //   /// NEWWWW
  //   try {
  //     user.onMessageReceived = (messageString) {
  //       final jsonData = jsonDecode(messageString);
  //       final chatmsg = ChatMsg.fromJson(jsonData);
  //       addChatMessage(chatmsg.senderID, chatmsg);
  //       // addChatMessage(chatmsg.receiver, chatmsg);
  //       // addChatMessage(user.userID, chatmsg); //感覺是放
  //     };
  //   } catch (e) {
  //     print("JSON parsing error: $e");
  //   }
  // }

  void setupOnMessageReceived(TUser user, MessageDispatcher dispatcher) {
    user.onMessageReceived = (messageString) {
      dispatcher.dispatch(messageString); // ✅ 不自己解析，讓 dispatcher 處理
    };
  }

  // void setupOnMessageReceived(TUser user) {

  //   user.onMessageReceived = (String msg) {
  //     dispatcher.dispatch(msg);
  //   };
  // }
  // 所有來自 socket 的訊息都交給 dispatcher

  List<ChatMsg> getChatHistory(String userID) {
    if (!userChatHistories.containsKey(userID)) {
      userChatHistories[userID] = <ChatMsg>[]; // 建立一個新的空紀錄
      print("建立新的聊天紀錄給 $userID");
    }
    return userChatHistories[userID]!;
  }

  void clearChatHistory(String userID) {
    userChatHistories.remove(userID);
  }

  void mergeChatHistory(String userID, List<ChatMsg> newHistory) {
    userChatHistories[userID] = [...?userChatHistories[userID], ...newHistory];
  }

  int get length => users.length;
}
