import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../localization/locale_cubit.dart';
import '../constants/app_colors.dart';

class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isArabic = locale.languageCode == 'ar';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              context.read<LocaleCubit>().toggleLocale();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isArabic
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.secondary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isArabic ? AppColors.primary : AppColors.secondary,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? '🇪🇬' : '🇬🇧',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'العربية' : 'English',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isArabic ? AppColors.primaryLight : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: isArabic ? AppColors.primaryLight : AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
