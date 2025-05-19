import 'package:flutter/material.dart';

import 'util/app_colors.dart'; // 引用自訂顏色
import 'util/user.dart';
import 'util/Page_animation.dart';

import 'pages/chatpage.dart';

void main() {
  runApp(Luama());
}

TUser taruser = TUser(
  userId: "0000",
  userName: "AI_Agent",
  profileImage: "",
  email: "",
);
TUser selfuser = TUser(
  userId: "0002",
  userName: "Luffy",
  profileImage: "",
  email: "",
);

class Luama extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luama',
      debugShowCheckedModeBanner: false,
      home: Homepage(),
      // home: ChatPage(selfuser, taruser),
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _NavSelectedIndex = 0;
  late final TUser MySelf;
  final _userManager = UserManager();

  @override
  void initState() {
    super.initState();
    MySelf = TUser.loadSelfData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Luama',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜尋框
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜尋',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),

          // 聊天對象列表
          Expanded(
            child: ListView.builder(
              itemCount: 10, // 假設有 10 個聊天對象
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person), // 這裡可以換成你要的 icon
                  ),
                  title: Text(
                    _userManager.getUserbyIndex(index).userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('message'),
                  onTap: () {
                    Navigator.of(context).push(
                      createRoute(
                        ChatPage(MySelf, _userManager.getUserbyIndex(index)),
                        Anima_Direction.FromRightIn,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 底部導覽欄
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _NavSelectedIndex,
        backgroundColor: Color.fromARGB(10, 50, 50, 50),
        onTap: (int index) {
          setState(() {
            _NavSelectedIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '主頁'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '聊天',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '功能三'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '個人頁面'),
        ],
      ),
    );
  }
}

enum SortRule { by_ID, by_Name, by_Time }

class UserManager {
  List<TUser> users = [];

  UserManager() {
    loadSampleUser();
  }

  void loadSampleUser() {
    users = [
      TUser(userId: "0000", userName: "AI_Agent", profileImage: "", email: ""),
      TUser(userId: "0002", userName: "Zoro", profileImage: "", email: ""),
      TUser(userId: "0003", userName: "Nami", profileImage: "", email: ""),
      TUser(userId: "0004", userName: "Usopp", profileImage: "", email: ""),
      TUser(userId: "0005", userName: "Sanji", profileImage: "", email: ""),
      TUser(userId: "0006", userName: "Chopper", profileImage: "", email: ""),
      TUser(userId: "0007", userName: "Robin", profileImage: "", email: ""),
      TUser(userId: "0008", userName: "Franky", profileImage: "", email: ""),
      TUser(userId: "0009", userName: "Brook", profileImage: "", email: ""),
      TUser(userId: "0010", userName: "Jinbe", profileImage: "", email: ""),
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
}
