import 'dart:io'; // file
import 'dart:convert'; // 用於 JSON 編碼
import 'package:intl/intl.dart';

enum MessageType { text, image, file, textAndFile, system, request_news }

enum ServiceType { ai_reply, request_news, none }

MessageType whatMsgType(String text, File? image) {
  final hasText = text.isNotEmpty;
  final hasImage = image != null;

  if (hasText && hasImage) {
    return MessageType.textAndFile;
  } else if (hasImage) {
    return MessageType.file;
  } else {
    return MessageType.text;
  }
}

String GetNowTimeStamp() {
  final now = DateTime.now();
  String formatted = DateFormat('yyyy-MM-dd – kk:mm').format(now);
  // String formatted = DateTime.now().toIso8601String(); // 例如 2025-05-31T10:32:00.000

  return formatted;
}

DateTime ParseToDatetime(String timestr) {
  try {
    return DateFormat('yyyy-MM-dd – kk:mm').parse(timestr);
  } catch (e) {
    print('解析時間失敗：$e');
    return DateTime(2000); // fallback 時間，避免 crash
  }
}

String ChatMsg2String(ChatMsg msg) {
  return jsonEncode(msg.toJson());
}

class ChatMsg {
  final String sender;
  final String receiver;
  final MessageType type; // text / image / file 等
  final String content;
  final String timestamp;
  final ServiceType service;

  ChatMsg({
    required this.sender,
    required this.receiver,
    this.service = ServiceType.none,
    this.type = MessageType.text,
    required this.content,
    required this.timestamp,
  });

  // 轉成 JSON
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiver': receiver,
      'service': service.name,
      'type': type.name,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory ChatMsg.fromJson(Map<String, dynamic> json) {
    return ChatMsg(
      sender: json['sender'],
      receiver: json['receiver'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'],
      timestamp: json['timestamp'],
      service: ServiceType.values.firstWhere(
        (e) => e.name == json['service'],
        orElse: () => ServiceType.none,
      ),
    );
  }
}
