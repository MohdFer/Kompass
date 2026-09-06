import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A styled AppBar widget with the KOMPASS adventure aesthetic.
/// Features a compass-inspired leading icon and warm leather tones.
class KompassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KompassAppBar({
    required this.title,
    super.key,
    this.actions,
    this.leading,
    this.showCompass = false,
    this.bottom,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showCompass;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading ?? (showCompass
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.explore,
              color: AppColors.primaryGoldLight,
              size: 32,
            ),
          )
        : null),
      actions: actions,
      bottom: bottom,
    );
  }
}
