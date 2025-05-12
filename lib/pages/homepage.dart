// import 'package:flutter/material.dart';
// import '../app_colors.dart'; // 假設你有自訂的顏色

// class Homepage extends StatefulWidget {
//   @override
//   _HomepageState createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryDark,
//       appBar: AppBar(
//         title: const Text(
//           'Luama',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // 搜尋框
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16.0,
//               vertical: 8.0,
//             ),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: '搜尋',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//             ),
//           ),

//           // 聊天對象列表
//           Expanded(
//             child: ListView.builder(
//               itemCount: 10, // 假設有 10 個聊天對象
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: CircleAvatar(child: Text('U$index')),
//                   title: Text(
//                     'User$index',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text('message'),
//                   onTap: () {
//                     // 點擊可以觸發進入聊天頁
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => NewPage()),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),

//       // 底部導覽欄
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (int index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         selectedItemColor: Colors.blueAccent,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: '主頁'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat_bubble_outline),
//             label: '聊天',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: '功能三'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle),
//             label: '功能四',
//           ),
//         ],
//       ),
//     );
//   }
// }


// // class UserManager {



// //   void UserManager(){

// //   }


// //   void LoadUser(String jsonpath = "users.json"){

// //   }


// // }