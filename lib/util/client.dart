import 'dart:io';
import 'dart:convert';

class Client {
  String ip;
  int port;
  String userName;
  // late Socket socket; // 用來存儲已連線的 Socket
  Socket? socket; // 用來存儲已連線的 Socket

  Function(String message)? onMessageReceived;
  Function(String message)? onMessageSend;

  bool get isConnected => socket != null;

  Client({required this.ip, required this.port, required this.userName});

  // 連線到伺服器
  void connectToServer() async {
    try {
      await Future.delayed(Duration(seconds: 2)); // 延遲 2 秒

      // 連線到伺服器 (這裡使用傳入的 Ip 和 port)
      socket = await Socket.connect(ip, port);
      print(
        'Connected to: ${socket?.remoteAddress.address}:${socket?.remotePort}',
      );
      bool _isConnect = true;

      // 接收伺服器回應
      socket?.listen(
        (List<int> event) {
          print('Server SAY: ${utf8.decode(event)}');
          String str = '${utf8.decode(event)}';
          onMessageReceived?.call(str);
        },
        onDone: () {
          // 當伺服器關閉連線時，關閉 socket
          // socket.close();
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  // 發送訊息到伺服器
  void sendMessage(String text) {
    if (socket != null &&
        socket?.remoteAddress != null &&
        socket?.remotePort != null) {
      // 檢查是否已經建立連線
      socket?.write(text);
      socket?.flush();
    } else {
      print('No active connection. Please connect to the server first.');
    }
  }

  // 關閉連線
  void closeConnection() {
    socket?.close();
    print('Connection closed');
  }
}
