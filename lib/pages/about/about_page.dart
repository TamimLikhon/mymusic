import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => context
                .findRootAncestorStateOfType<ScaffoldState>()
                ?.openDrawer(),
          ),
        ),
        title: Text('About', style: AppTypography.heading),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icon.png', width: 120, height: 120),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  'v1.0.0',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.amber,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Retro vibe music player',
                style: AppTypography.body.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Fully offline. Your music, your tags.',
                style: AppTypography.caption.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildFeature(Icons.label, 'Tag-based organization'),
              const SizedBox(height: 12),
              _buildFeature(Icons.offline_bolt, 'Completely offline'),
              const SizedBox(height: 12),
              _buildFeature(Icons.album, 'Retro aesthetic'),
              const SizedBox(height: 8),
              Text(
                'Made by tamimbuilds',
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.amber),
        const SizedBox(width: 12),
        Text(text, style: AppTypography.body.copyWith(fontSize: 13)),
      ],
    );
  }
}
