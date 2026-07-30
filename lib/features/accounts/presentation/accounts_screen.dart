import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_accounts.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/widgets/status_badge.dart';
import '../../transactions/bloc/transaction_bloc.dart';
import '../../transactions/bloc/transaction_state.dart';
import '../../transactions/bloc/transaction_event.dart';
import '../../models/transaction_model.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = AppAccounts.accounts;

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 700 ? 1 : (screenWidth < 1100 ? 2 : 3);
    final aspectRatio = screenWidth < 700 ? 1.3 : 1.5;

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final transactions = state.allTransactions;

        return SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth < 700 ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TREASURY, BANK ACCOUNTS & SUB-ACCOUNTS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Monitor cash vaults, bank liquidity, and responsible sub-account entities (BS, MR, ES, MF)',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openTransferDialog(context),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: Colors.white),
                    label: const Text('Internal Transfer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Accounts Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final acc = accounts[index];
                  final accTxns = transactions.where((t) => t.sourceAccount == acc.code).toList();

                  final egpSpent = accTxns.fold(0.0, (s, i) => s + i.amountEgp);
                  final eurSpent = accTxns.fold(0.0, (s, i) => s + i.amountEur);
                  final usdSpent = accTxns.fold(0.0, (s, i) => s + i.amountUsd);

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getAccountTypeColor(acc.type).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(acc.icon, color: _getAccountTypeColor(acc.type), size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc.code,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    acc.responsiblePerson,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(text: acc.type, color: _getAccountTypeColor(acc.type)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          acc.name,
                          style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        const Divider(color: AppColors.divider, height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Transactions:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text('${accTxns.length} Recorded', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Outflow Total:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text(
                              egpSpent > 0
                                  ? CurrencyFormatter.format(egpSpent, Currency.EGP)
                                  : eurSpent > 0
                                      ? CurrencyFormatter.format(eurSpent, Currency.EUR)
                                      : CurrencyFormatter.format(usdSpent, Currency.USD),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getAccountTypeColor(String type) {
    switch (type) {
      case 'Bank':
        return AppColors.eur;
      case 'Treasury':
        return AppColors.egp;
      default:
        return AppColors.primary;
    }
  }

  void _openTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _InternalTransferModal(),
    );
  }
}

class _InternalTransferModal extends StatefulWidget {
  const _InternalTransferModal();

  @override
  State<_InternalTransferModal> createState() => _InternalTransferModalState();
}

class _InternalTransferModalState extends State<_InternalTransferModal> {
  String _fromAccount = 'CIB-EGP';
  String _toAccount = 'BS';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final accountCodes = AppAccounts.getAccountCodes();

    return Dialog(
      backgroundColor: AppColors.surface,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.swap_horiz_rounded, color: AppColors.secondary, size: 24),
                SizedBox(width: 10),
                Text('Internal Vault Transfer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const Divider(color: AppColors.divider, height: 28),
            DropdownButtonFormField<String>(
              initialValue: _fromAccount,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'From Vault / Account'),
              items: accountCodes.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (val) => setState(() => _fromAccount = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _toAccount,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'To Vault / Account'),
              items: accountCodes.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (val) => setState(() => _toAccount = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Transfer Amount', prefixText: 'EGP / EUR / USD '),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Transfer Reason / Notes'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      final transferTxn = TransactionModel(
                        id: 'TRF-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                        date: DateTime.now(),
                        category: 'Bank & Monthly Fees',
                        description: 'Vault Transfer from $_fromAccount to $_toAccount (${_notesController.text})',
                        amountEgp: amount,
                        amountEur: 0.0,
                        amountUsd: 0.0,
                        invoiceNumber: 'TRF-INTERNAL',
                        responsiblePerson: 'Finance Dept',
                        projectTag: 'General HQ / Internal Overhead',
                        sourceAccount: _fromAccount,
                        type: TransactionType.transfer,
                      );
                      context.read<TransactionBloc>().add(AddTransaction(transferTxn));
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                  child: const Text('Execute Transfer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
