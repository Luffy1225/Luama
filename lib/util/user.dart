// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'client.dart';
import 'server.dart';
import 'chatmsg.dart';

class TUser {
  //User Information
  String userId; // 用戶ID，可以用來識別不同的用戶
  String userName; // 用戶名稱
  String profileImage; // 使用者頭像URL
  String email; // 使用者電子郵件
  bool isOnline = false; // 使用者是否在線上

  bool isAIAgent = false;

  IconData iconData = Icons.person;

  late Server server;
  late Client client;

  // static const DEFAULT_IP = '192.168.56.1';
  // static const int DEFAULT_PORT = 8888;
  // static const DEFAULT_IP = "127.0.0.1";
  // static const int DEFAULT_PORT = 50007;

  static const DEFAULT_IP = "192.168.56.1";
  static const int DEFAULT_PORT = 50007;

  // 建構子
  TUser({
    required this.userId,
    required this.userName,
    required this.profileImage,
    required this.email,
    IconData? iconData, // 可選的 icon 參數
    bool? isAIAgent,
  }) : iconData = iconData ?? Icons.person,
       isAIAgent = isAIAgent ?? false {
    server = Server(ip: DEFAULT_IP, port: DEFAULT_PORT, userName: userName);
    client = Client(ip: DEFAULT_IP, port: DEFAULT_PORT, userName: userName);

    isOnline = true; // 預設值為 false，表示離線
  }

  // 用來顯示使用者訊息的函式
  @override
  String toString() {
    return 'User{id: $userId, name: $userName, email: $email, isOnline: $isOnline}';
  }

  // 更新使用者的在線狀態
  void updateOnlineStatus(bool status) {
    isOnline = status;
  }

  // 用來檢查是否為有效使用者
  bool isValidUser() {
    return userId.isNotEmpty && userName.isNotEmpty && email.isNotEmpty;
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
          userId == other.userId &&
          userName == other.userName &&
          email == other.email;

  // 關閉與該用戶的 Socket 連線
  void closeConnection() {
    client.closeConnection();
  }

  void startServer() {
    server.startServer();
  }

  void startClient() {
    client.connectToServer();
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
      'userId': userId,
      'userName': userName,
      'profileImage': profileImage,
      'email': email,
      'isOnline': isOnline,
    };
  }

  /// 儲存 JSON 資料到檔案
  void save2Json(String path) async {
    final file = File('user_$userId.json');
    String jsonData = jsonEncode(toJson());
    await file.writeAsString(jsonData);
    print('User data saved to user_$userId.json');
  }

  /// 將 JSON Map 還原為 TUser 物件
  TUser readfromJson(Map<String, dynamic> json) {
    return TUser(
      userId: json['userId'],
      userName: json['userName'],
      profileImage: json['profileImage'],
      email: json['email'],
    );
  }

  // static TUser loadSelfData() {
  //   return TUser(
  //     userId: "1225",
  //     userName: "Luffy",
  //     profileImage: "",
  //     email: "Luffy1225",
  //   );
  // }
}

enum SortRule { by_ID, by_Name, by_Time }

class UserManager {
  List<TUser> users = [];

  UserManager() {
    loadSampleUser();
  }

  void loadSampleUser() {
    users = [
      TUser(
        userId: "0000",
        userName: "llama3.2:latest",
        profileImage: "",
        email: "",
        isAIAgent: true,
      ),
      TUser(
        userId: "0001",
        userName: "deepseek-r1:7b",
        profileImage: "",
        email: "",
        isAIAgent: true,
      ),
      TUser(userId: "0002", userName: "Yuniko", profileImage: "", email: ""),
      TUser(userId: "0003", userName: "Nami", profileImage: "", email: ""),
      TUser(userId: "0004", userName: "Usopp", profileImage: "", email: ""),
      TUser(userId: "0005", userName: "Sanji", profileImage: "", email: ""),
      TUser(userId: "0006", userName: "Chopper", profileImage: "", email: ""),
      TUser(userId: "0007", userName: "Robin", profileImage: "", email: ""),
      TUser(userId: "0008", userName: "Franky", profileImage: "", email: ""),
      TUser(userId: "0009", userName: "Brook", profileImage: "", email: ""),
      TUser(userId: "0010", userName: "Jinbe", profileImage: "", email: ""),
      TUser(userId: "0011", userName: "Vivi", profileImage: "", email: ""),
      TUser(userId: "0012", userName: "Carrot", profileImage: "", email: ""),
      TUser(userId: "0013", userName: "Yamato", profileImage: "", email: ""),
      TUser(userId: "0014", userName: "Bonney", profileImage: "", email: ""),
      TUser(userId: "0015", userName: "Hancock", profileImage: "", email: ""),
    ];
  }

  void addUser(TUser user) {
    users.add(user);
  }

  void sortBy(SortRule rule) {
    switch (rule) {
      case SortRule.by_ID:
        users.sort((a, b) => a.userId.compareTo(b.userId));
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

  int get length => users.length;
}
