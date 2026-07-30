import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../localization/locale_cubit.dart';
import '../localization/app_translations.dart';
import '../../features/users/bloc/user_bloc.dart';
import '../../features/users/bloc/user_state.dart';
import '../../features/users/bloc/user_event.dart';
import 'language_switch_button.dart';

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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (isMobile && onOpenDrawer != null) ...[
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 24),
                onPressed: onOpenDrawer,
                tooltip: isArabic ? 'القائمة' : 'Menu',
              ),
              const SizedBox(width: 6),
            ],

            // Title
            Text(
              displayTitle,
              style: TextStyle(
                fontSize: isMobile ? 14 : 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(width: 12),

            // Active Profile Switcher Dropdown
            if (activeUser != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: activeUser.id,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primaryLight,
                    ),
                    items: allUsers.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.id,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
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

            const SizedBox(width: 12),

            // Search Bar
            SizedBox(
              width: isMobile ? 160 : 240,
              height: 36,
              child: TextField(
                onChanged: onSearch,
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: AppTranslations.get('searchHint', isArabic),
                  prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Language Switcher Toggle Button
            const LanguageSwitchButton(),

            const SizedBox(width: 8),

            // Dark / Light Mode Switcher Toggle Button
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDarkMode ? AppColors.primaryLight : AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
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

            const SizedBox(width: 10),

            // Action Buttons
            if (activeUser == null || activeUser.permissions.canImportExportExcel)
              OutlinedButton.icon(
                onPressed: onImportExcel,
                icon: const Icon(Icons.file_upload_outlined, size: 15, color: AppColors.secondary),
                label: Text(
                  AppTranslations.get('importExcel', isArabic),
                  style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.secondary),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

            const SizedBox(width: 8),

            if (activeUser == null || activeUser.permissions.canAddTransaction)
              ElevatedButton.icon(
                onPressed: onAddTransaction,
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: Text(
                  AppTranslations.get('newEntry', isArabic),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
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
