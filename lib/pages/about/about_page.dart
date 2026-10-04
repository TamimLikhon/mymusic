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
      body: Stack(
        children: [
          // ── Cosmos Ambient Glow Orbs ───────────────────────────────────────
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: GlassCard.card(radius: 12),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'About',
                  style: AppTypography.heading.copyWith(fontSize: 20),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App icon with glowing glass container
                        Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.45),
                                blurRadius: 32,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/icon.png',
                              width: 108,
                              height: 108,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        // App name
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              AppColors.primaryLight,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'MyMusic',
                            style: AppTypography.hero.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Version badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'v1.0.1',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Your music, your tags, your vibe.',
                          style: AppTypography.body.copyWith(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),
                        // Feature highlights
                        _buildFeatureRow(
                          icon: HugeIcons.strokeRoundedTag01,
                          label: 'Tag-based organization',
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          icon: HugeIcons.strokeRoundedTick02,
                          label: 'Completely offline',
                          color: AppColors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          icon: HugeIcons.strokeRoundedMusicNote02,
                          label: 'Lossless & web stream support',
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: 44),
                        Text(
                          'Made with ♥ by tamimbuilds',
                          style: AppTypography.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Center(
              child: HugeIcon(icon: icon, color: color, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
