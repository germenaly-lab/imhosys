import 'package:flutter/material.dart';
import 'company_logo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../localization/locale_cubit.dart';
import '../localization/app_translations.dart';

class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.divider, width: 1),
          left: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Company Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Row(
              children: [
                const CompanyLogo(
                  size: 42,
                  showText: false,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.get('appTitle', isArabic),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        AppTranslations.get('appSubtitle', isArabic),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Menu Header Label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppTranslations.get('mainMenu', isArabic),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Scrollable Navigation Links
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildNavItem(context, 0, AppTranslations.get('dashboard', isArabic), Icons.dashboard_rounded),
                  _buildNavItem(context, 1, AppTranslations.get('ledger', isArabic), Icons.table_rows_rounded),
                  _buildNavItem(context, 2, AppTranslations.get('projects', isArabic), Icons.engineering_rounded),
                  _buildNavItem(context, 3, AppTranslations.get('accounts', isArabic), Icons.account_balance_wallet_rounded),
                  _buildNavItem(context, 4, AppTranslations.get('excelTool', isArabic), Icons.file_present_rounded),
                  _buildNavItem(context, 5, AppTranslations.get('users', isArabic), Icons.admin_panel_settings_rounded),
                  _buildNavItem(context, 6, AppTranslations.get('reports', isArabic), Icons.analytics_rounded),
                ],
              ),
            ),
          ),

          // System Info Footer
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic ? 'المحرك متعدد العملات نشط' : 'Multi-Currency Engine Active',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isArabic ? 'الخزائن: جنيه • يورو • دولار' : 'Vaults: EGP • EUR • USD',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String title, IconData icon) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onItemSelected(index),
          hoverColor: AppColors.primary.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.16) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
