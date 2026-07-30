import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            pinned: true,
            leading: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: GlassCard.card(radius: 10),
                child: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01,
                    size: 20, color: AppColors.textPrimary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('About', style: AppTypography.heading),
          ),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App icon with gradient background
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset('assets/icon.png',
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // App name
                    Text('MyMusic', style: AppTypography.hero.copyWith(fontSize: 26)),
                    const SizedBox(height: 8),
                    // Version badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFaint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Text(
                        'v1.0.0',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Your music, your tags, your vibe.',
                      style: AppTypography.body.copyWith(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Feature highlights
                    _buildFeatureRow(
                      icon: HugeIcons.strokeRoundedTag01,
                      label: 'Tag-based organization',
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureRow(
                      icon: HugeIcons.strokeRoundedTick02,
                      label: 'Completely offline',
                      color: AppColors.green,
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureRow(
                      icon: HugeIcons.strokeRoundedMusicNote02,
                      label: 'Premium music player',
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Made with ♥ by tamimbuilds',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required dynamic icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: HugeIcon(icon: icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
