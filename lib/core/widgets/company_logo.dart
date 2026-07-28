import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

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
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Image.network(
            logoUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildFallbackLogo();
            },
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.18),
          const Text(
            'IMHOSYS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'INDUSTRIAL AUTOMATION & ELECTRICAL SOLUTIONS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.primaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          'IMH',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
