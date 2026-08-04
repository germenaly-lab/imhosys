import 'package:flutter/material.dart';
import 'company_logo.dart';
import 'glass_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../localization/locale_cubit.dart';
import '../localization/app_translations.dart';
import '../../features/users/bloc/user_bloc.dart';
import '../../features/users/bloc/user_state.dart';

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
    final isDark = AppColors.isDark(context);

    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: AppColors.getSurface(context).withValues(alpha: isDark ? 0.60 : 0.85),
        border: Border(
          right: BorderSide(
            color: AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12),
            width: 1.2,
          ),
          left: BorderSide(
            color: AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Company Header Pod
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.primary.withValues(alpha: 0.18),
                        AppColors.secondary.withValues(alpha: 0.08),
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.08),
                        AppColors.secondary.withValues(alpha: 0.04),
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12),
                  width: 1.2,
                ),
              ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppTranslations.get('appSubtitle', isArabic),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Navigation Menu Label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppTranslations.get('mainMenu', isArabic).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppColors.primaryLight.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Scrollable Navigation Links with Glass Icons & Glow
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    title: AppTranslations.get('dashboard', isArabic),
                    icon: Icons.dashboard_rounded,
                    gradient: AppColors.primaryGradient,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    title: AppTranslations.get('ledger', isArabic),
                    icon: Icons.table_rows_rounded,
                    gradient: AppColors.cyanGradient,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    title: AppTranslations.get('projects', isArabic),
                    icon: Icons.engineering_rounded,
                    gradient: AppColors.emeraldGradient,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    title: AppTranslations.get('accounts', isArabic),
                    icon: Icons.account_balance_wallet_rounded,
                    gradient: AppColors.amberGradient,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 4,
                    title: AppTranslations.get('cashAdvance', isArabic),
                    icon: Icons.request_quote_rounded,
                    gradient: AppColors.roseGradient,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 5,
                    title: AppTranslations.get('payroll', isArabic),
                    icon: Icons.badge_rounded,
                    gradient: AppColors.purpleGradient,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 6,
                    title: AppTranslations.get('excelTool', isArabic),
                    icon: Icons.file_present_rounded,
                    gradient: AppColors.primaryGradient,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 7,
                    title: AppTranslations.get('users', isArabic),
                    icon: Icons.admin_panel_settings_rounded,
                    gradient: AppColors.cyanGradient,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 8,
                    title: AppTranslations.get('reports', isArabic),
                    icon: Icons.analytics_rounded,
                    gradient: AppColors.emeraldGradient,
                  ),
                ],
              ),
            ),
          ),

          // Glassmorphic Footer System Info Card
          Padding(
            padding: const EdgeInsets.all(12),
            child: GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(14),
              glowColor: AppColors.neonEmerald,
              borderColor: AppColors.neonEmerald.withValues(alpha: 0.35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.neonEmerald,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonEmerald,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isArabic ? 'المحرك متعدد العملات نشط' : 'Multi-Currency Engine Active',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neonEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Builder(
                    builder: (context) {
                      final activeUser = context.watch<UserBloc>().state is UserLoaded
                          ? (context.watch<UserBloc>().state as UserLoaded).activeUser
                          : null;
                      final canViewVaults = activeUser?.permissions.canViewVaultBalances ?? false;

                      return Text(
                        canViewVaults
                            ? (isArabic ? 'الخزائن: جنيه • يورو • دولار' : 'Vaults: EGP • EUR • USD')
                            : (isArabic ? 'أرصدة الخزائن: محمية بحساب المسؤول 🔒' : 'Vault Balances: Admin Protected 🔒'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getTextSecondary(context),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String title,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    final isSelected = selectedIndex == index;
    final isDark = AppColors.isDark(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    gradient.colors.first.withValues(alpha: isDark ? 0.28 : 0.18),
                    gradient.colors.last.withValues(alpha: isDark ? 0.12 : 0.08),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          border: isSelected
              ? Border.all(
                  color: gradient.colors.first.withValues(alpha: isDark ? 0.6 : 0.4),
                  width: 1.2,
                )
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onItemSelected(index),
            hoverColor: gradient.colors.first.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  GlassIconBadge(
                    icon: icon,
                    gradient: isSelected
                        ? gradient
                        : LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF334155), const Color(0xFF1E293B)]
                                : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
                          ),
                    size: 34,
                    iconSize: 17,
                    iconColor: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    glowColor: isSelected ? gradient.colors.first : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? (isDark ? Colors.white : gradient.colors.first)
                            : AppColors.getTextSecondary(context),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 6,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.colors.first,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
