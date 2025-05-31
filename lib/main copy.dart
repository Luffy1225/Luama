import 'package:flutter/material.dart';

import 'util/app_colors.dart'; // 引用自訂顏色
import 'util/user.dart';
import 'util/Page_animation.dart';
import 'util/global_Setting.dart';

import 'pages/chatpage.dart';
import 'pages/nav/nav_chatpage.dart';
import 'pages/nav/nav_homepage.dart';
import 'pages/nav/nav_postpage.dart';
import 'pages/nav/nav_profilepage.dart';

void main() {
  runApp(Luama());
}

class Luama extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final AppColors appColors =
        (brightness == Brightness.dark) ? DarkTheme : LightTheme;

    return AppContextProvider(
      appColors: appColors,
      isDarkMode: brightness == Brightness.dark,

      // MySelf: mySelf,
      child: MaterialApp(
        title: 'Luama',
        debugShowCheckedModeBanner: false,
        home: Homepage(), // 其他頁面都可以用 AppColorsProvider.of(context)
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _NavSelectedIndex = 1;

  final TUser MySelf = TUser(
    userId: "1225",
    userName: "Luffy",
    profileImage: "",
    email: "Luffy1225",
  );
  final _userManager = UserManager();

  @override
  void initState() {
    MySelf.startClient();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.of(context);

    return Scaffold(
      // backgroundColor: const Color(0xFFF8FBFA),
      backgroundColor: appColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Luama',
                      style: TextStyle(
                        fontFamily: 'Spline Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        // color: Color(0xFF0E1A13),
                        color: appColors.TopBar_Title,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.edit, color: appColors.TopBar_IconColor),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: appColors.searchBarHintColor,
                    fontSize: 18,
                  ),
                  filled: true,
                  fillColor: appColors.searchBarHintBackground,
                  prefixIcon: Icon(
                    Icons.search,
                    color: appColors.searchBarLeftIcon,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _userManager.length,
                itemBuilder: (context, index) {
                  TUser user = _userManager.getUserbyIndex(index);
                  return ContactItem(
                    user: user,
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBIHF7EUmgGz-GfxYYs8sA6b_AoLTVatLIjS-_6ZJEQUKLoA9wYwtaWAgokmhYdeWm0Wkfqc5PZ1dXDSHVP-Kh_evGtg--cIE2aY2V04HsROqySx5qPFrLoFj06fm7Xtl3k50YzgLbZJQtu7nOQnJjehfbq1yXdRvap9IkB1yoZ3wddjJ5GJYjaqStHd2QqmLrPitZf2e3C7YWge3qlQikYOkd9AMhCezsTGPeReDLg69Xm-HBSbxKQeYvE4nbheCfA4Tq4eg6V_UIt',
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
      ),

      // 底部導覽欄
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _NavSelectedIndex,
        backgroundColor: appColors.navigationBarBackground,
        onTap: (int index) {
          setState(() {
            _NavSelectedIndex = index;
          });
        },
        selectedItemColor: appColors.navigationBarSelect,
        unselectedItemColor: appColors.navigationBarUnselect,
        items: [
          BottomNavigationBarItem(
            backgroundColor: appColors.navigationBarBackground,
            icon: Icon(Icons.home_rounded), // 替代 home，更有儀表板感
            label: '主頁',
          ),
          BottomNavigationBarItem(
            backgroundColor: appColors.navigationBarBackground,
            icon: Icon(Icons.forum_outlined), // 替代 chat_bubble_outline，較有「聊天室」感
            label: '聊天',
          ),
          BottomNavigationBarItem(
            backgroundColor: appColors.navigationBarBackground,
            icon: Icon(Icons.article_outlined), // 替代 settings，更像是貼文內容
            label: '貼文',
          ),
          BottomNavigationBarItem(
            backgroundColor: appColors.navigationBarBackground,
            icon: Icon(Icons.account_circle_outlined), // 替代 person，更立體、更個人化
            label: '個人頁面',
          ),
        ],
      ),
    );
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
                      color: appColors.contactItemUserName,
                    ),
                  ),
                  Text(
                    "Message example",
                    style: TextStyle(
                      fontSize: 14,
                      color: appColors.contactItemMessage,
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
