import 'dart:io';
import 'dart:convert';

class Client {
  String ip;
  int port;
  String userName;
  Socket? socket; // 用來存儲已連線的 Socket

  static int reconnectAttempts = 0;
  static int maxReconnectAttempts = 3;

  Function(String message)? onMessageReceived;

  bool _isSocketClosed = true;
  bool get isConnected =>
      socket != null && !_isSocketClosed; //建立過後 socket 會不是null

  Client({required this.ip, required this.port, required this.userName});

  // 連線到伺服器
  Future<void> connectToServer({String? ip_, int? port_}) async {
    try {
      if (isConnected) {
        await socket?.close();
        socket?.destroy(); // 強制關閉以防殘留
        socket = null;
        _isSocketClosed = true;
      }

      // 如果傳入了新的 ip 和 port，則更新本地的 ip 和 port
      if (ip_ != null) {
        ip = ip_;
      }
      if (port_ != null) {
        port = port_;
      }

      // 連線到伺服器 (這裡使用傳入的 Ip 和 port)
      socket = await Socket.connect(ip, port);
      print(
        'Connected to: ${socket?.remoteAddress.address}:${socket?.remotePort}',
      );
      _isSocketClosed = false; // ✅ 成功連線後設為 false

      // 接收伺服器回應
      socket?.listen(
        (List<int> event) {
          print('Server SAY: ${utf8.decode(event)}');
          String str = utf8.decode(event);
          onMessageReceived?.call(str);
        },
        onDone: () {
          _isSocketClosed = true;
          socket = null;
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> reconnect() async {
    if (reconnectAttempts >= maxReconnectAttempts) {
      print('超過最大重連次數，停止嘗試');
      return;
    }

    reconnectAttempts++;
    print('第 $reconnectAttempts 次重連中...');

    await Future.delayed(Duration(seconds: 3)); // 每次間隔 3 秒
    await connectToServer();
  }

  // Future<void> connectToServer({String? ip_, int? port_}) async {
  //   try {
  //     if (isConnected) {
  //       await socket?.close();
  //       socket?.destroy();
  //       socket = null;
  //       _isSocketClosed = true;
  //     }

  //     if (ip_ != null) ip = ip_;
  //     if (port_ != null) port = port_;

  //     socket = await Socket.connect(ip, port);
  //     print(
  //       'Connected to: ${socket?.remoteAddress.address}:${socket?.remotePort}',
  //     );
  //     _isSocketClosed = false;
  //     reconnectAttempts = 0; // ✅ 重連成功後重置計數

  //     socket?.listen(
  //       (event) {
  //         String str = utf8.decode(event);
  //         print('Server SAY: $str');
  //         onMessageReceived?.call(str);
  //       },
  //       onDone: () {
  //         print("連線結束，嘗試重連...");
  //         _isSocketClosed = true;
  //         socket = null;
  //         reconnect(); // ✅ 嘗試重連
  //       },
  //     );
  //   } catch (e) {
  //     print('連線錯誤: $e');
  //     reconnect(); // ✅ 連線失敗時重試
  //   }
  // }

  // Future<void> reconnect() async {
  //   if (reconnectAttempts >= maxReconnectAttempts) {
  //     print('已達最大重連次數');
  //     return;
  //   }

  //   reconnectAttempts++;
  //   print('第 $reconnectAttempts 次重連中...');
  //   await Future.delayed(Duration(seconds: 3));
  //   await connectToServer();
  // }

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

  void sendMessageJSON(String text) {
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

  // // 關閉連線
  // void closeConnection() {
  //   socket?.close();
  //   print('Connection closed');
  // }

  Future<void> closeConnection() async {
    if (socket != null && !_isSocketClosed) {
      await socket?.close();
      _isSocketClosed = true;
      socket = null;
      print('Connection closed');
    } else {
      print('No active connection to close.');
    }
  }
}
