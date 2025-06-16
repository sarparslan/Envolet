import 'package:flutter/material.dart';

/// Route that slides the new page in from the right while fading it in.
Route<T> slideFadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      return SlideTransition(
        position:
            Tween(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

/// Route that simply fades the new page in.
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Replaces the whole navigation stack with [page].
void resetTo(BuildContext context, Widget page) {
  Navigator.of(context).pushAndRemoveUntil(slideFadeRoute(page), (_) => false);
}
