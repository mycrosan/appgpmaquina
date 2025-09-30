import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Widget de AppBar customizado
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          color: foregroundColor ?? AppColors.textOnPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.textOnPrimary,
      elevation: elevation ?? 2,
      centerTitle: centerTitle,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: foregroundColor ?? AppColors.textOnPrimary,
      ),
      actionsIconTheme: IconThemeData(
        color: foregroundColor ?? AppColors.textOnPrimary,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}