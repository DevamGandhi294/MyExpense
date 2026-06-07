import 'package:flutter/material.dart';
import 'package:myexpense/app/theme/app_colors.dart';

class FilterToggleWidget extends StatelessWidget {
  final String filterMode;
  final void Function(String) onToggle;

  const FilterToggleWidget({
    super.key,
    required this.filterMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleSegment(
            label: 'By Category',
            isActive: filterMode == 'category',
            onTap: () => onToggle('category'),
          ),
          _ToggleSegment(
            label: 'By Date',
            isActive: filterMode == 'date',
            onTap: () => onToggle('date'),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleSegment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.neutral900 : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.white : AppColors.neutral500,
          ),
        ),
      ),
    );
  }
}