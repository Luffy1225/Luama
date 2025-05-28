import 'dart:io'; // file
import 'dart:convert'; // 用於 JSON 編碼
import 'package:intl/intl.dart';

enum MessageType { text, image, file, textAndFile, system }

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

String GetTimeStamp() {
  final now = DateTime.now();
  String formatted = DateFormat('yyyy-MM-dd – kk:mm').format(now);
  return formatted;
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

  ChatMsg({
    required this.sender,
    required this.receiver,
    required this.type,
    required this.content,
    required this.timestamp,
  });

  // 轉成 JSON
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiver': receiver,
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
    );
  }
}
