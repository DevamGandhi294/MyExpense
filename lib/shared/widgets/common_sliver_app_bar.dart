import 'package:flutter/material.dart';
import 'package:myexpense/app/theme/app_colors.dart';
import 'hand_and_bag_logo.dart';

class CommonSliverAppBar extends StatelessWidget {
  final Widget? title;
  final String? titleText;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showLogo;
  final bool showBackButton;

  const CommonSliverAppBar({
    super.key,
    this.title,
    this.titleText,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.showLogo = false,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? titleWidget = title;

    if (titleWidget == null && titleText != null) {
      titleWidget = Text(
        titleText!,
        style: const TextStyle(
          color: AppColors.accentPurple,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      );
    }

    if (showLogo) {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HandAndBagLogo(),

          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'My',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPurple,
                  ),
                ),
                TextSpan(
                  text: 'Expense',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton) {
      leadingWidget = IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.accentPurple,
          size: 22,
        ),
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    return SliverAppBar(
      backgroundColor: AppColors.neutral50,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      leading: leadingWidget,
      title: titleWidget,
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.accentPurple),
    );
  }
}
