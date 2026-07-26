import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class TagChip extends StatelessWidget {
  final String name;
  final int color;
  final int songCount;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.name,
    required this.color,
    required this.songCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = Color(color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
            const BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(-3, -3),
              blurRadius: 6,
            ),
          ],
          border: Border.all(
            color: chipColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.label_rounded, size: 14, color: chipColor),
            const SizedBox(width: 6),
            Text(
              name,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: chipColor,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$songCount',
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: chipColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
