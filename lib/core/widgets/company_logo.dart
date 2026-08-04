import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'glass_container.dart';

class CompanyLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDarkBackground;

  const CompanyLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.isDarkBackground = true,
  });

  static const String logoUrl = 'https://img1.wsimg.com/isteam/ip/ea35782c-b43a-418b-90e0-3d4991e13696/blob-7688f45.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // High-Contrast Glass Pod Container for Logo
        GlassContainer(
          blur: 16,
          padding: EdgeInsets.all(size * 0.12),
          borderRadius: BorderRadius.circular(size * 0.4),
          fillContainerColor: Colors.white.withValues(alpha: 0.95),
          glowColor: AppColors.primaryLight,
          elevation: 6,
          border: Border.all(
            color: AppColors.primaryLight,
            width: 2.2,
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Image.network(
              logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildHighContrastFallback(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildHighContrastFallback();
              },
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.16),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.cyanGradient.createShader(bounds),
            child: const Text(
              'IMHOSYS',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: const Text(
              'INDUSTRIAL AUTOMATION & ELECTRICAL SOLUTIONS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHighContrastFallback() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'IMH',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            shadows: const [
              Shadow(
                color: Colors.black45,
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
