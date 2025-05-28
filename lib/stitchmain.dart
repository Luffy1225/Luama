import 'package:flutter/material.dart';
import 'util/app_colors.dart'; // 引用自訂顏色
import 'util/user.dart';
import 'util/Page_animation.dart';

// import 'pages/chatpage.dart';
// import 'pages/stitchChatpage.dart';
// import 'pages/stitchpage.dart';
import 'pages/chatpage.dart';
import "stitchmain.dart";
import 'main.dart';

class StitchDesignPage extends StatelessWidget {
  const StitchDesignPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  const Text(
                    'Luama',
                    style: TextStyle(
                      fontFamily: 'Spline Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E1A13),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF0E1A13)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Color(0xFF51946B)),
                  filled: true,
                  fillColor: const Color(0xFFE8F2EC),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF51946B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: const [
                  ContactItem(
                    name: 'Sophia',
                    message: 'Hey, how are you?',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBIHF7EUmgGz-GfxYYs8sA6b_AoLTVatLIjS-_6ZJEQUKLoA9wYwtaWAgokmhYdeWm0Wkfqc5PZ1dXDSHVP-Kh_evGtg--cIE2aY2V04HsROqySx5qPFrLoFj06fm7Xtl3k50YzgLbZJQtu7nOQnJjehfbq1yXdRvap9IkB1yoZ3wddjJ5GJYjaqStHd2QqmLrPitZf2e3C7YWge3qlQikYOkd9AMhCezsTGPeReDLg69Xm-HBSbxKQeYvE4nbheCfA4Tq4eg6V_UIt',
                  ),
                  ContactItem(
                    name: 'Liam',
                    message: 'See you tomorrow',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA_M057JJr6vQFO8k2gOdq9Lz-cCfaKxL7TqnxmNr9buvNs286Lx-Wogv3pb9UwZXy5u1URDfXzHpKX6lBVY48FUzmuAfR8kOj7McQTP7_xUbusSG1jUrgKpB9E16y06GF_9dHgzKB8fjXFrSzIgkeqYg4zCS5wDD6bSnI8DNTrCv5FxJiNQ1o7SQJsfAGYnHc41GZFrVyPUB7TAdT8U-wWOeBo0of4QB7Qq0bM3bwPgshn-PPoOTbJ0t0cGfIOQXooXeifXu2rcjUS',
                  ),
                  ContactItem(
                    name: 'Olivia',
                    message: 'Im on my way',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBXr_klfp8JwxPfuvS3rnF1RasLi6QkDCLNxG6FD-opM7lsfo_BnoBfE1h4A0DShThkggI09X1UlOz5E8OL0lx0DUEcJ06VX_BYaBSPqntyFA0pOmZGzmOyoNFZzDRwIgwuB1eRfYpxLjgR-rLPLxeSQO_Q6zq76PGbxTt09z9L-AjZ7qq6Huw71WJJDJZ-hrmGehciIodoltD3MXnKnHSp4mQi2CXdUGdRlVwzGzK6M8mR9hUO__Df1AhkeyLGOtxvWqkNEAD9bt_n',
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

class ContactItem extends StatelessWidget {
  final String name;
  final String message;
  final String imageUrl;

  const ContactItem({
    required this.name,
    required this.message,
    required this.imageUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0E1A13),
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF51946B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
