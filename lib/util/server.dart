import 'dart:io';
import 'dart:convert';

class Server {
  String ip;
  int port;
  String userName;

  late ServerSocket server; // 用來存儲已連線的 Socket

  Function(String message)? onMessageReceived;
  Function(String message)? onMessageSend;

  Server({required this.ip, required this.port, required this.userName});

  void startServer() async {
    try {
      // 監聽 3000 端口
      server = await ServerSocket.bind(ip, port);
      // server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      // server = await ServerSocket.bind(
      //   InternetAddress.anyIPv4,
      //   8888,
      //   shared: true,
      // );

      print('Server listening on ${server.address.address}:${server.port}');

      // 接受客戶端連線
      await for (var socket in server) {
        print(
          'Client connected: ${socket.remoteAddress.address}:${socket.remotePort}',
        );
        socket.write('Hello from ${userName}!');

        // 接收來自客戶端的資料
        socket.listen((List<int> event) {
          print('Server Listen: ${utf8.decode(event)}');
          String received = "${utf8.decode(event)}";
          onMessageReceived?.call(received);

          // 發送回應給客戶端

          String str = 'Server get : ${utf8.decode(event)}';
          socket.write(str);
          onMessageSend?.call(str);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void closeConnection() {
    server.close();
    print('Connection closed');
  }
}
