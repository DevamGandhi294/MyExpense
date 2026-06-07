// lib/app/modules/profile/widgets/profile_menu_tile_widget.dart
import 'package:flutter/material.dart';

class ProfileMenuTileWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showDivider;

  const ProfileMenuTileWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Colors.black87;
    final iconBgColor = isDestructive ? Colors.red.shade50 : Colors.grey.shade100;
    final iconColor = isDestructive ? Colors.red : Colors.grey.shade600;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Leading icon with square bg
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                // Trailing chevron (only if not destructive)
                if (!isDestructive)
                  const Icon(Icons.chevron_right,
                      color: Colors.grey, size: 22),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 70,
            endIndent: 16,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}