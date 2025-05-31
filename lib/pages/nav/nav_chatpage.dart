import 'package:flutter/material.dart';

import '../../util/user.dart';
import '../../util/app_colors.dart'; // 引用自訂顏色
import '../../util/Page_animation.dart';

import '../chatpage.dart';

class Nav_ChatWidget extends StatelessWidget {
  final TUser mySelf;
  final UserManager userManager;
  // final AppColors appColors;

  const Nav_ChatWidget({
    required this.mySelf,
    required this.userManager,
    // required this.appColors,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: userManager.length,
      itemBuilder: (context, index) {
        TUser user = userManager.getUserbyIndex(index);
        return ContactItem(
          user: user,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBIHF7EUmgGz-GfxYYs8sA6b_AoLTVatLIjS-_6ZJEQUKLoA9wYwtaWAgokmhYdeWm0Wkfqc5PZ1dXDSHVP-Kh_evGtg--cIE2aY2V04HsROqySx5qPFrLoFj06fm7Xtl3k50YzgLbZJQtu7nOQnJjehfbq1yXdRvap9IkB1yoZ3wddjJ5GJYjaqStHd2QqmLrPitZf2e3C7YWge3qlQikYOkd9AMhCezsTGPeReDLg69Xm-HBSbxKQeYvE4nbheCfA4Tq4eg6V_UIt',
          onTap: () {
            Navigator.of(context).push(
              createRoute(
                ChatPage(mySelf, userManager.getUserbyIndex(index)),
                Anima_Direction.FromRightIn,
              ),
            );
          },
        );
      },
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
