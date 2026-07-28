import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/localization/app_translations.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import 'widgets/filter_bar.dart';
import 'widgets/ledger_table.dart';
import 'widgets/transaction_dialog.dart';
import '../../models/transaction_model.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is TransactionLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ledger Summary Header & Total Aggregates
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        AppTranslations.get('totalEgpIncurred', isArabic),
                        CurrencyFormatter.format(state.totalEgp, Currency.EGP),
                        isArabic ? '${state.filteredTransactions.where((t) => t.amountEgp > 0).length} معاملات' : '${state.filteredTransactions.where((t) => t.amountEgp > 0).length} Entries',
                        AppColors.egp,
                        Icons.account_balance_wallet_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        AppTranslations.get('totalEurIncurred', isArabic),
                        CurrencyFormatter.format(state.totalEur, Currency.EUR),
                        isArabic ? '${state.filteredTransactions.where((t) => t.amountEur > 0).length} معاملات' : '${state.filteredTransactions.where((t) => t.amountEur > 0).length} Entries',
                        AppColors.eur,
                        Icons.euro_symbol_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        AppTranslations.get('totalUsdIncurred', isArabic),
                        CurrencyFormatter.format(state.totalUsd, Currency.USD),
                        isArabic ? '${state.filteredTransactions.where((t) => t.amountUsd > 0).length} معاملات' : '${state.filteredTransactions.where((t) => t.amountUsd > 0).length} Entries',
                        AppColors.usd,
                        Icons.attach_money_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Filter Bar
                FilterBar(
                  selectedProject: state.selectedProject,
                  selectedCategory: state.selectedCategory,
                  selectedAccount: state.selectedAccount,
                  selectedPerson: state.selectedPerson,
                  onFilterChanged: (proj, cat, acc, person) {
                    context.read<TransactionBloc>().add(FilterTransactions(
                          project: proj,
                          category: cat,
                          account: acc,
                          responsiblePerson: person,
                        ));
                  },
                  onReset: () {
                    context.read<TransactionBloc>().add(FilterTransactions(
                          project: AppTranslations.get('allProjects', isArabic),
                          category: AppTranslations.get('allCategories', isArabic),
                          account: AppTranslations.get('allAccounts', isArabic),
                          responsiblePerson: AppTranslations.get('allPersons', isArabic),
                        ));
                  },
                ),

                const SizedBox(height: 20),

                // Data Table Container Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'معاملات دفتر السجل (${state.filteredTransactions.length})' : 'LEDGER ENTRIES (${state.filteredTransactions.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          isArabic ? 'عرض ${state.filteredTransactions.length} من أصل ${state.allTransactions.length} عنصر' : 'Showing ${state.filteredTransactions.length} of ${state.allTransactions.length} items',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Main Ledger Table
                LedgerTable(
                  transactions: state.filteredTransactions,
                  onEdit: (t) => _openEditDialog(context, t),
                  onDelete: (id) {
                    context.read<TransactionBloc>().add(DeleteTransaction(id));
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(count, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
        ],
      ),
    );
  }

  void _openEditDialog(BuildContext context, TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (dialogCtx) => TransactionDialog(
        transactionToEdit: transaction,
        onSave: (updated) {
          context.read<TransactionBloc>().add(UpdateTransaction(updated));
        },
      ),
    );
  }
}
