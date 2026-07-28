import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../users/bloc/user_bloc.dart';
import '../../../users/bloc/user_state.dart';
import '../../../models/transaction_model.dart';

class LedgerTable extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onEdit;
  final Function(String) onDelete;

  const LedgerTable({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final userState = context.watch<UserBloc>().state;
    final activeUser = userState is UserLoaded ? userState.activeUser : null;

    final canEdit = activeUser == null || activeUser.permissions.canEditTransaction;
    final canDelete = activeUser == null || activeUser.permissions.canDeleteTransaction;

    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                isArabic ? 'لم يتم العثور على معاملات' : 'No Ledger Entries Found',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                isArabic ? 'جرّب تغيير كلمات البحث أو إعادة ضبط الفلاتر' : 'Try adjusting search query or active filter criteria',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
            dataRowMaxHeight: 64,
            dataRowMinHeight: 56,
            horizontalMargin: 16,
            columnSpacing: 18,
            columns: [
              DataColumn(label: Text(AppTranslations.get('id', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              DataColumn(label: Text(AppTranslations.get('date', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              DataColumn(label: Text(AppTranslations.get('category', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              DataColumn(label: Text(AppTranslations.get('description', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              DataColumn(label: Text(AppTranslations.get('egpCol', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.egp))),
              DataColumn(label: Text(AppTranslations.get('eurCol', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.eur))),
              DataColumn(label: Text(AppTranslations.get('usdCol', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.usd))),
              DataColumn(label: Text(AppTranslations.get('invoiceNum', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              DataColumn(label: Text(AppTranslations.get('responsible', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              DataColumn(label: Text(AppTranslations.get('projectTag', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              DataColumn(label: Text(AppTranslations.get('sourceVault', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              DataColumn(label: Text(AppTranslations.get('actions', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
            ],
            rows: transactions.map((t) {
              return DataRow(
                cells: [
                  // ID
                  DataCell(
                    Text(
                      t.id,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                  // Date
                  DataCell(
                    Text(
                      DateFormatter.formatShort(t.date),
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                    ),
                  ),
                  // Category
                  DataCell(
                    StatusBadge(
                      text: AppCategories.getLocalizedName(t.category, isArabic),
                      color: AppColors.primaryLight,
                      icon: Icons.label_outlined,
                    ),
                  ),
                  // Description
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(
                        t.description,
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // EGP
                  DataCell(
                    Text(
                      t.amountEgp > 0 ? CurrencyFormatter.formatRaw(t.amountEgp) : '-',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: t.amountEgp > 0 ? FontWeight.bold : FontWeight.normal,
                        color: t.amountEgp > 0 ? AppColors.egp : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  // EUR
                  DataCell(
                    Text(
                      t.amountEur > 0 ? CurrencyFormatter.formatRaw(t.amountEur) : '-',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: t.amountEur > 0 ? FontWeight.bold : FontWeight.normal,
                        color: t.amountEur > 0 ? AppColors.eur : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  // USD
                  DataCell(
                    Text(
                      t.amountUsd > 0 ? CurrencyFormatter.formatRaw(t.amountUsd) : '-',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: t.amountUsd > 0 ? FontWeight.bold : FontWeight.normal,
                        color: t.amountUsd > 0 ? AppColors.usd : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  // Invoice #
                  DataCell(
                    Text(
                      t.invoiceNumber.isNotEmpty ? t.invoiceNumber : 'N/A',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                  // Responsible Person
                  DataCell(
                    StatusBadge(
                      text: t.responsiblePerson,
                      color: AppColors.primary,
                      icon: Icons.person,
                    ),
                  ),
                  // Project Tag
                  DataCell(
                    StatusBadge(
                      text: t.projectTag,
                      color: AppColors.secondary,
                      icon: Icons.engineering,
                    ),
                  ),
                  // Source Account
                  DataCell(
                    Text(
                      t.sourceAccount,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  // Actions (Enforced by activeUser permissions)
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: canEdit ? (isArabic ? 'تعديل المعاملة' : 'Edit Transaction') : (isArabic ? 'يتطلب صلاحية المسؤول' : 'Permission Required'),
                          icon: Icon(Icons.edit_outlined, size: 16, color: canEdit ? AppColors.secondary : AppColors.divider),
                          onPressed: canEdit ? () => onEdit(t) : null,
                        ),
                        IconButton(
                          tooltip: canDelete ? (isArabic ? 'حذف المعاملة' : 'Delete Transaction') : (isArabic ? 'يتطلب صلاحية المسؤول' : 'Permission Required'),
                          icon: Icon(Icons.delete_outline_rounded, size: 16, color: canDelete ? AppColors.error : AppColors.divider),
                          onPressed: canDelete ? () => onDelete(t.id) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
