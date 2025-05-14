import 'package:flutter/material.dart';

enum Anima_Direction { FromLeftIn, FromRightIn }

Route createRoute(Widget page, Anima_Direction direction) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 定義動畫的起始位置
      late Offset begin;

      // 根據方向選擇不同的動畫方向
      switch (direction) {
        case Anima_Direction.FromLeftIn:
          begin = Offset(-1.0, 0.0); // 從左邊滑入
          break;
        case Anima_Direction.FromRightIn:
          begin = Offset(1.0, 0.0); // 從右邊滑入
          break;
        // ignore: unreachable_switch_default
        default:
          begin = Offset(1.0, 0.0); // 默認從右邊滑入
      }

      const end = Offset.zero;
      const curve = Curves.ease;

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
