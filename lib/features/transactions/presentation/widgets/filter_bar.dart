import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_projects.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/constants/app_accounts.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/localization/app_translations.dart';

class FilterBar extends StatelessWidget {
  final String? selectedProject;
  final String? selectedCategory;
  final String? selectedAccount;
  final String? selectedPerson;
  final Function(String?, String?, String?, String?) onFilterChanged;
  final VoidCallback onReset;

  const FilterBar({
    super.key,
    this.selectedProject,
    this.selectedCategory,
    this.selectedAccount,
    this.selectedPerson,
    required this.onFilterChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final isMobile = MediaQuery.of(context).size.width < 900;

    final List<String> projects = [AppTranslations.get('allProjects', isArabic), ...AppProjects.getProjectNames()];
    final List<String> categories = [AppTranslations.get('allCategories', isArabic), ...AppCategories.getAllSubcategories()];
    final List<String> accounts = [AppTranslations.get('allAccounts', isArabic), ...AppAccounts.getAccountCodes()];
    final List<String> persons = [
      AppTranslations.get('allPersons', isArabic),
      'BS (Bishoy S.)',
      'MR (Mena R.)',
      'ES (Eng. Sameh)',
      'MF (Eng. Mostafa)',
      'AH (Ahmed H.)',
      'Finance Dept',
      'Office Admin',
      'Treasury Manager',
    ];

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list_rounded, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      AppTranslations.get('filters', isArabic),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: isArabic ? 'مسح الفلاتر' : 'Clear Filters',
                  icon: const Icon(Icons.restart_alt_rounded, color: AppColors.textSecondary, size: 20),
                  onPressed: onReset,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    value: selectedProject ?? AppTranslations.get('allProjects', isArabic),
                    items: projects,
                    hint: 'Project',
                    icon: Icons.business,
                    isArabic: isArabic,
                    onChanged: (val) => onFilterChanged(val, selectedCategory, selectedAccount, selectedPerson),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown(
                    value: selectedCategory ?? AppTranslations.get('allCategories', isArabic),
                    items: categories,
                    hint: 'Category',
                    icon: Icons.category,
                    isArabic: isArabic,
                    onChanged: (val) => onFilterChanged(selectedProject, val, selectedAccount, selectedPerson),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    value: selectedAccount ?? AppTranslations.get('allAccounts', isArabic),
                    items: accounts,
                    hint: 'Account',
                    icon: Icons.account_balance_wallet,
                    isArabic: isArabic,
                    onChanged: (val) => onFilterChanged(selectedProject, selectedCategory, val, selectedPerson),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown(
                    value: selectedPerson ?? AppTranslations.get('allPersons', isArabic),
                    items: persons,
                    hint: 'Person',
                    icon: Icons.person_outline,
                    isArabic: isArabic,
                    onChanged: (val) => onFilterChanged(selectedProject, selectedCategory, selectedAccount, val),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            AppTranslations.get('filters', isArabic),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 16),

          // Project Filter
          Expanded(
            child: _buildFilterDropdown(
              value: selectedProject ?? AppTranslations.get('allProjects', isArabic),
              items: projects,
              hint: 'Project Tag',
              icon: Icons.business,
              isArabic: isArabic,
              onChanged: (val) => onFilterChanged(val, selectedCategory, selectedAccount, selectedPerson),
            ),
          ),
          const SizedBox(width: 12),

          // Category Filter
          Expanded(
            child: _buildFilterDropdown(
              value: selectedCategory ?? AppTranslations.get('allCategories', isArabic),
              items: categories,
              hint: 'Expense Category',
              icon: Icons.category,
              isArabic: isArabic,
              onChanged: (val) => onFilterChanged(selectedProject, val, selectedAccount, selectedPerson),
            ),
          ),
          const SizedBox(width: 12),

          // Source Account Filter
          Expanded(
            child: _buildFilterDropdown(
              value: selectedAccount ?? AppTranslations.get('allAccounts', isArabic),
              items: accounts,
              hint: 'Source Vault/Bank',
              icon: Icons.account_balance_wallet,
              isArabic: isArabic,
              onChanged: (val) => onFilterChanged(selectedProject, selectedCategory, val, selectedPerson),
            ),
          ),
          const SizedBox(width: 12),

          // Person Filter
          Expanded(
            child: _buildFilterDropdown(
              value: selectedPerson ?? AppTranslations.get('allPersons', isArabic),
              items: persons,
              hint: 'Responsible Person',
              icon: Icons.person_outline,
              isArabic: isArabic,
              onChanged: (val) => onFilterChanged(selectedProject, selectedCategory, selectedAccount, val),
            ),
          ),

          const SizedBox(width: 12),

          // Reset Button
          IconButton(
            tooltip: isArabic ? 'مسح الفلاتر' : 'Clear Filters',
            icon: const Icon(Icons.restart_alt_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: onReset,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required bool isArabic,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          dropdownColor: AppColors.surface,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 20),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                AppCategories.getLocalizedName(item, isArabic),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
