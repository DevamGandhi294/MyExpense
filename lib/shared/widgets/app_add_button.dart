import 'package:flutter/material.dart';
import 'package:myexpense/app/theme/app_colors.dart';

/// Round purple "+" button — same look as the dashboard FAB.
class AppAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const AppAddButton({super.key, required this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppColors.accentPurple,
      elevation: 6,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
