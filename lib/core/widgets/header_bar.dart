import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../localization/locale_cubit.dart';
import '../localization/app_translations.dart';
import '../../features/users/bloc/user_bloc.dart';
import '../../features/users/bloc/user_state.dart';
import '../../features/users/bloc/user_event.dart';
import 'language_switch_button.dart';
import 'glass_container.dart';

import '../../features/transactions/bloc/transaction_bloc.dart';
import '../../features/transactions/bloc/transaction_event.dart';
import '../theme/theme_cubit.dart';

class HeaderBar extends StatelessWidget {
  final String titleKey;
  final String? title;
  final bool isMobile;
  final VoidCallback? onOpenDrawer;
  final Function(String) onSearch;
  final VoidCallback onAddTransaction;
  final VoidCallback onImportExcel;
  final VoidCallback? onLogout;

  const HeaderBar({
    super.key,
    this.titleKey = 'dashHeader',
    this.title,
    this.isMobile = false,
    this.onOpenDrawer,
    required this.onSearch,
    required this.onAddTransaction,
    required this.onImportExcel,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final isDarkMode = context.watch<ThemeCubit>().isDarkMode;
    final userState = context.watch<UserBloc>().state;

    final activeUser = userState is UserLoaded ? userState.activeUser : null;
    final allUsers = userState is UserLoaded ? userState.users : [];

    final displayTitle = title ?? AppTranslations.get(titleKey, isArabic);

    return GlassContainer(
      blur: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
      borderRadius: BorderRadius.circular(16),
      borderColor: AppColors.primary.withValues(alpha: isDarkMode ? 0.30 : 0.18),
      elevation: 6,
      glowColor: AppColors.primary,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (isMobile && onOpenDrawer != null) ...[
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.primaryLight, size: 24),
                onPressed: onOpenDrawer,
                tooltip: isArabic ? 'القائمة' : 'Menu',
              ),
              const SizedBox(width: 6),
            ],

            // Title with Glowing Bullet
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.getTextPrimary(context),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Active Profile Switcher Dropdown (Glass Pill)
            if (activeUser != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.20),
                      AppColors.secondary.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: activeUser.id,
                    dropdownColor: AppColors.getSurface(context),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.getTextPrimary(context)),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryLight,
                    ),
                    items: allUsers.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.id,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              size: 14,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 6),
                            Text(u.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (selectedId) {
                      if (selectedId != null) {
                        context.read<UserBloc>().add(SwitchActiveUser(selectedId));
                      }
                    },
                  ),
                ),
              ),

            const SizedBox(width: 14),

            // Glass Search Bar
            SizedBox(
              width: isMobile ? 160 : 240,
              height: 38,
              child: TextField(
                onChanged: onSearch,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.getTextPrimary(context)),
                decoration: InputDecoration(
                  hintText: AppTranslations.get('searchHint', isArabic),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.primaryLight),
                  filled: true,
                  fillColor: AppColors.getBackground(context).withValues(alpha: 0.6),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Language Switcher Button
            const LanguageSwitchButton(),

            const SizedBox(width: 8),

            // Dark / Light Mode Switcher Toggle Button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [AppColors.primary.withValues(alpha: 0.3), AppColors.secondary.withValues(alpha: 0.2)]
                      : [Colors.amber.withValues(alpha: 0.15), Colors.orange.withValues(alpha: 0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? AppColors.primaryLight : Colors.amber.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: IconButton(
                tooltip: isDarkMode
                    ? (isArabic ? 'التبديل إلى الوضع الفاتح' : 'Switch to Light Mode')
                    : (isArabic ? 'التبديل إلى الوضع الداكن' : 'Switch to Dark Mode'),
                icon: Icon(
                  isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: isDarkMode ? Colors.amber : AppColors.primary,
                  size: 18,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ),

            const SizedBox(width: 8),

            // Refresh Data Button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: IconButton(
                tooltip: isArabic ? 'تحديث البيانات وحالة النظام' : 'Refresh System & Cloud Data',
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.secondary,
                  size: 18,
                ),
                onPressed: () {
                  context.read<TransactionBloc>().add(LoadTransactions());
                  context.read<UserBloc>().add(LoadUsers());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isArabic ? 'تم إرسال طلب تحديث البيانات! 🔄' : 'System data refresh triggered! 🔄'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // Action Buttons
            if (activeUser == null || activeUser.permissions.canImportExportExcel)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.6), width: 1.2),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onImportExcel,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.file_upload_outlined, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          AppTranslations.get('importExcel', isArabic),
                          style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(width: 8),

            if (activeUser == null || activeUser.permissions.canAddTransaction)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onAddTransaction,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          AppTranslations.get('newEntry', isArabic),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (onLogout != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: isArabic ? 'تسجيل الخروج' : 'Log Out',
                icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                onPressed: onLogout,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
