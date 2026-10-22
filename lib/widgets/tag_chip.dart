import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_typography.dart';

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
          gradient: LinearGradient(
            colors: [
              chipColor.withValues(alpha: 0.22),
              chipColor.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipColor.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: chipColor.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedTag01,
              size: 13,
              color: chipColor,
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 1.5,
              ),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: chipColor.withValues(alpha: 0.35),
                  width: 0.5,
                ),
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
