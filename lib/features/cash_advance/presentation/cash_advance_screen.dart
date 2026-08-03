import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/constants/app_accounts.dart';
import '../../../core/constants/app_projects.dart';
import '../../../core/constants/app_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/localization/locale_cubit.dart';
import '../bloc/cash_advance_bloc.dart';
import '../bloc/cash_advance_event.dart';
import '../bloc/cash_advance_state.dart';
import '../models/cash_advance_model.dart';

class CashAdvanceScreen extends StatefulWidget {
  const CashAdvanceScreen({super.key});

  @override
  State<CashAdvanceScreen> createState() => _CashAdvanceScreenState();
}

class _CashAdvanceScreenState extends State<CashAdvanceScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  CashAdvanceType? _selectedTypeFilter;
  CashAdvanceStatus? _selectedStatusFilter;
  String? _selectedRecipientFilter;

  final List<String> _staffList = [
    'Eng. Emad',
    'Eng. Mostafa',
    'Eng. Badawy',
    'Hanafy',
    'BS (Bishoy S.)',
    'MR (Mena R.)',
    'ES (Eng. Sameh)',
    'MF (Eng. Mostafa)',
    'AH (Ahmed H.)',
    'Finance Dept',
    'Office Admin',
  ];

  @override
  void initState() {
    super.initState();
    context.read<CashAdvanceBloc>().add(LoadCashAdvances());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    context.read<CashAdvanceBloc>().add(
          FilterCashAdvances(
            searchQuery: _searchCtrl.text.trim(),
            typeFilter: _selectedTypeFilter,
            statusFilter: _selectedStatusFilter,
            recipientFilter: _selectedRecipientFilter,
          ),
        );
  }

  void _openNewAdvanceModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _NewCashAdvanceModal(
        staffList: _staffList,
        onSave: (advance) {
          context.read<CashAdvanceBloc>().add(CreateCashAdvance(advance));
          final isArabic = context.read<LocaleCubit>().isArabic;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? 'تم إصدار العهدة المالية (${advance.id}) للموظف ${advance.recipientName} بنجاح 💵'
                    : 'Cash advance ${advance.id} issued to ${advance.recipientName} successfully! 💵',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _openRecordExpenseModal(BuildContext context, CashAdvanceModel advance) {
    showDialog(
      context: context,
      builder: (ctx) => _RecordExpenseModal(
        advance: advance,
        onSave: (expense) {
          context.read<CashAdvanceBloc>().add(
                AddExpenseToAdvance(
                  advanceId: advance.id,
                  expense: expense,
                ),
              );
          final isArabic = context.read<LocaleCubit>().isArabic;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? 'تم تسجيل المصروف للعهدة (${advance.id}) بنجاح 🧾'
                    : 'Expense recorded against advance (${advance.id}) successfully! 🧾',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<CashAdvanceBloc, CashAdvanceState>(
      builder: (context, state) {
        if (state is CashAdvanceLoading || state is CashAdvanceInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is CashAdvanceError) {
          return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
        }

        final loaded = state as CashAdvanceLoaded;
        final advances = loaded.filteredAdvances;
        final all = loaded.allAdvances;

        // Executive Totals
        final totalDisbursedEgp = all.where((a) => a.currency == 'EGP').fold(0.0, (s, a) => s + a.initialAmount);
        final totalDisbursedEur = all.where((a) => a.currency == 'EUR').fold(0.0, (s, a) => s + a.initialAmount);
        final totalDisbursedUsd = all.where((a) => a.currency == 'USD').fold(0.0, (s, a) => s + a.initialAmount);

        final totalSpentEgp = all.where((a) => a.currency == 'EGP').fold(0.0, (s, a) => s + a.totalSpent);
        final totalSpentEur = all.where((a) => a.currency == 'EUR').fold(0.0, (s, a) => s + a.totalSpent);
        final totalSpentUsd = all.where((a) => a.currency == 'USD').fold(0.0, (s, a) => s + a.totalSpent);

        final remainingEgp = totalDisbursedEgp - totalSpentEgp;
        final remainingEur = totalDisbursedEur - totalSpentEur;
        final remainingUsd = totalDisbursedUsd - totalSpentUsd;

        final activeCustodians = all.map((a) => a.recipientName).toSet().length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth < 700 ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.request_quote_rounded, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isArabic ? 'إدارة العهد المالية والعهدة الشخصية والمؤقتة' : 'CASH ADVANCES & PETTY CASH CUSTODY',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: AppColors.getTextPrimary(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isArabic
                              ? 'متابعة المبالغ المنصرفة للمهندسين والموظفين، المصروفات، والرصيد المتبقي بالكامل'
                              : 'Track advance disbursements, staff expenses, line-item receipts & remaining balances',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openNewAdvanceModal(context),
                    icon: const Icon(Icons.add_card_rounded, size: 18, color: Colors.white),
                    label: Text(
                      isArabic ? 'إصدار عهدة جديدة +' : '+ Issue New Cash Advance',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Executive KPI Summary Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 850;
                  return GridView.count(
                    crossAxisCount: isSmall ? 2 : 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isSmall ? 1.4 : 1.5,
                    children: [
                      _buildKpiCard(
                        context: context,
                        title: isArabic ? 'إجمالي العهد المنصرفة' : 'TOTAL ADVANCES ISSUED',
                        icon: Icons.payments_rounded,
                        iconColor: AppColors.primary,
                        egp: totalDisbursedEgp,
                        eur: totalDisbursedEur,
                        usd: totalDisbursedUsd,
                        subtitle: isArabic ? '${all.length} عهدة مسجلة للنظام' : '${all.length} Advances Disbursed Total',
                      ),
                      _buildKpiCard(
                        context: context,
                        title: isArabic ? 'إجمالي المصروفات المثبتة' : 'TOTAL SPENT & REPORTED',
                        icon: Icons.receipt_long_rounded,
                        iconColor: AppColors.warning,
                        egp: totalSpentEgp,
                        eur: totalSpentEur,
                        usd: totalSpentUsd,
                        subtitle: isArabic ? 'الفواتير والإيصالات المقدمة' : 'Reported Receipts & Expenses',
                      ),
                      _buildKpiCard(
                        context: context,
                        title: isArabic ? 'الرصيد المتبقي في ذمة الموظفين' : 'REMAINING CASH BALANCE',
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: remainingEgp >= 0 ? AppColors.success : AppColors.error,
                        egp: remainingEgp,
                        eur: remainingEur,
                        usd: remainingUsd,
                        subtitle: isArabic ? 'المبالغ المتبقية للعهدة المفتوحة' : 'Net Active Unspent Balance',
                      ),
                      _buildCustodiansKpiCard(
                        context: context,
                        isArabic: isArabic,
                        activeCustodians: activeCustodians,
                        totalAdvances: all.length,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Filter & Search Toolbar Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.getDivider(context)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Search Bar
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => _applyFilter(),
                            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
                            decoration: InputDecoration(
                              hintText: isArabic ? 'بحث باسم الموظف، كود العهدة، أو المشروع...' : 'Search recipient, advance ID, title, or project...',
                              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Advance Type Filter
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<CashAdvanceType?>(
                            initialValue: _selectedTypeFilter,
                            dropdownColor: AppColors.getSurface(context),
                            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 12),
                            decoration: InputDecoration(
                              labelText: isArabic ? 'نوع العهدة' : 'Advance Type',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(value: null, child: Text(isArabic ? 'جميع الأنواع' : 'All Advance Types')),
                              ...CashAdvanceType.values.map(
                                (t) => DropdownMenuItem(value: t, child: Text(t.getLocalizedName(isArabic))),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedTypeFilter = val);
                              _applyFilter();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Status Filter
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<CashAdvanceStatus?>(
                            initialValue: _selectedStatusFilter,
                            dropdownColor: AppColors.getSurface(context),
                            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 12),
                            decoration: InputDecoration(
                              labelText: isArabic ? 'حالة العهدة' : 'Status',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(value: null, child: Text(isArabic ? 'جميع الحالات' : 'All Statuses')),
                              ...CashAdvanceStatus.values.map(
                                (s) => DropdownMenuItem(value: s, child: Text(s.getLocalizedName(isArabic))),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedStatusFilter = val);
                              _applyFilter();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Advances List Grid
              if (advances.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.getSurface(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.getDivider(context)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.folder_off_rounded, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        isArabic ? 'لا توجد عهد مالية مطابقة لفلاتر البحث' : 'No cash advances found matching criteria',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: advances.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final adv = advances[index];
                    return _AdvanceCard(
                      advance: adv,
                      isArabic: isArabic,
                      onRecordExpense: () => _openRecordExpenseModal(context, adv),
                      onSettle: () {
                        context.read<CashAdvanceBloc>().add(SettleCashAdvance(adv.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isArabic ? 'تم تسوية العهدة بالكامل 🏁' : 'Advance settled and closed 🏁'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      onDelete: () {
                        context.read<CashAdvanceBloc>().add(DeleteCashAdvance(adv.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isArabic ? 'تم حذف العهدة المالية 🗑️' : 'Advance deleted 🗑️'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required double egp,
    required double eur,
    required double usd,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getDivider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (egp != 0.0)
            Text(CurrencyFormatter.format(egp, Currency.EGP), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: egp >= 0 ? AppColors.getTextPrimary(context) : AppColors.error)),
          if (eur != 0.0)
            Text(CurrencyFormatter.format(eur, Currency.EUR), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: eur >= 0 ? AppColors.eur : AppColors.error)),
          if (usd != 0.0)
            Text(CurrencyFormatter.format(usd, Currency.USD), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: usd >= 0 ? AppColors.usd : AppColors.error)),
          if (egp == 0.0 && eur == 0.0 && usd == 0.0)
            Text('0.00 EGP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(context))),
          const Spacer(),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildCustodiansKpiCard({
    required BuildContext context,
    required bool isArabic,
    required int activeCustodians,
    required int totalAdvances,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getDivider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isArabic ? 'أصحاب العهد الماليين' : 'ACTIVE CUSTODIANS',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$activeCustodians ${isArabic ? 'أمناء عهد' : 'Staff Members'}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.getTextPrimary(context)),
          ),
          const Spacer(),
          Text(
            isArabic ? 'إجمالي $totalAdvances عهدة مفعلة' : 'Holding $totalAdvances total advances',
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AdvanceCard extends StatefulWidget {
  final CashAdvanceModel advance;
  final bool isArabic;
  final VoidCallback onRecordExpense;
  final VoidCallback onSettle;
  final VoidCallback onDelete;

  const _AdvanceCard({
    required this.advance,
    required this.isArabic,
    required this.onRecordExpense,
    required this.onSettle,
    required this.onDelete,
  });

  @override
  State<_AdvanceCard> createState() => _AdvanceCardState();
}

class _AdvanceCardState extends State<_AdvanceCard> {
  bool _isExpanded = false;

  Currency get _currencyEnum {
    switch (widget.advance.currency) {
      case 'EUR':
        return Currency.EUR;
      case 'USD':
        return Currency.USD;
      default:
        return Currency.EGP;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adv = widget.advance;
    final isArabic = widget.isArabic;
    final isOverspent = adv.remainingBalance < 0;

    final currEnum = _currencyEnum;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverspent ? AppColors.error : AppColors.getDivider(context),
          width: isOverspent ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Recipient & Badges & Actions
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      radius: 20,
                      child: Text(
                        adv.recipientName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                adv.recipientName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimary(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(text: adv.id, color: AppColors.secondary),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            adv.title,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        StatusBadge(
                          text: adv.advanceType.getLocalizedName(isArabic),
                          color: AppColors.primaryLight,
                        ),
                        StatusBadge(
                          text: adv.status.getLocalizedName(isArabic),
                          color: adv.status == CashAdvanceStatus.active
                              ? AppColors.success
                              : (adv.status == CashAdvanceStatus.overspent ? AppColors.error : AppColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Financial Calculations Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.getBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.getDivider(context)),
                  ),
                  child: Row(
                    children: [
                      // 1. Initial Amount
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'مبلغ العهدة المنصرف:' : 'Initial Disbursed:',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(adv.initialAmount, currEnum),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.getTextPrimary(context),
                              ),
                            ),
                            Text(
                              'From: ${adv.sourceAccount}',
                              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),

                      Container(height: 35, width: 1, color: AppColors.getDivider(context)),
                      const SizedBox(width: 12),

                      // 2. Spent Amount
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'المصروف الفعلي حتى الآن:' : 'Total Spent So Far:',
                              style: const TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(adv.totalSpent, currEnum),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.warning,
                              ),
                            ),
                            Text(
                              '${adv.expenses.length} Receipts',
                              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),

                      Container(height: 35, width: 1, color: AppColors.getDivider(context)),
                      const SizedBox(width: 12),

                      // 3. Remaining Balance
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'الرصيد المتبقي في العهدة:' : 'Remaining Balance:',
                              style: TextStyle(
                                fontSize: 10,
                                color: isOverspent ? AppColors.error : AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(adv.remainingBalance, currEnum),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isOverspent ? AppColors.error : AppColors.success,
                              ),
                            ),
                            Text(
                              isOverspent ? '⚠️ Overspent' : 'In Custody',
                              style: TextStyle(fontSize: 9, color: isOverspent ? AppColors.error : AppColors.success, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Spent Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (adv.totalSpent / (adv.initialAmount > 0 ? adv.initialAmount : 1)).clamp(0.0, 1.0),
                    backgroundColor: AppColors.getDivider(context),
                    color: isOverspent ? AppColors.error : (adv.settlementPercentage > 85 ? AppColors.warning : AppColors.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),

                // Card Footer Actions Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Project: ${adv.projectTag} • Date: ${adv.dateDisbursed.year}-${adv.dateDisbursed.month.toString().padLeft(2, '0')}-${adv.dateDisbursed.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: widget.onRecordExpense,
                          icon: const Icon(Icons.receipt_long, size: 14, color: Colors.white),
                          label: Text(
                            isArabic ? 'إضافة مصروف +' : '+ Record Expense',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => setState(() => _isExpanded = !_isExpanded),
                          icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 16, color: AppColors.primaryLight),
                          label: Text(
                            isArabic ? 'بيانات المصروفات (${adv.expenses.length})' : 'Itemized Expenses (${adv.expenses.length})',
                            style: const TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (adv.status == CashAdvanceStatus.active)
                          OutlinedButton(
                            onPressed: widget.onSettle,
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                            child: Text(isArabic ? 'تسوية' : 'Settle', style: const TextStyle(fontSize: 10, color: AppColors.success)),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                          onPressed: widget.onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable Itemized Expenses Table
          if (_isExpanded) ...[
            Divider(color: AppColors.getDivider(context), height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.getBackground(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'تفاصيل المصروفات المثبتة للعهدة (Spent Line Items):' : 'Spent Line-Item Receipts:',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 10),
                  if (adv.expenses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        isArabic ? 'لم يتم تسجيل أي مصروفات لهذه العهدة بعد.' : 'No expenses recorded against this advance yet.',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: adv.expenses.length,
                      separatorBuilder: (_, _) => Divider(color: AppColors.getDivider(context), height: 10),
                      itemBuilder: (ctx, expIndex) {
                        final exp = adv.expenses[expIndex];
                        return Row(
                          children: [
                            Text(exp.id, style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(
                              '${exp.date.year}-${exp.date.month.toString().padLeft(2, '0')}-${exp.date.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                exp.description,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.getTextPrimary(context)),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: StatusBadge(text: exp.category, color: AppColors.primaryLight),
                            ),
                            if (exp.vendor.isNotEmpty)
                              Expanded(
                                flex: 2,
                                child: Text(exp.vendor, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                              ),
                            Text(
                              CurrencyFormatter.format(exp.amount, currEnum),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                              onPressed: () {
                                context.read<CashAdvanceBloc>().add(
                                      DeleteExpenseFromAdvance(
                                        advanceId: adv.id,
                                        expenseId: exp.id,
                                      ),
                                    );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NewCashAdvanceModal extends StatefulWidget {
  final List<String> staffList;
  final Function(CashAdvanceModel) onSave;

  const _NewCashAdvanceModal({
    required this.staffList,
    required this.onSave,
  });

  @override
  State<_NewCashAdvanceModal> createState() => _NewCashAdvanceModalState();
}

class _NewCashAdvanceModalState extends State<_NewCashAdvanceModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;

  late String _recipient;
  late CashAdvanceType _type;
  late String _currency;
  late String _account;
  late String _project;

  @override
  void initState() {
    super.initState();
    _idCtrl = TextEditingController(text: 'ADV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    _titleCtrl = TextEditingController();
    _amountCtrl = TextEditingController(text: '0.00');
    _notesCtrl = TextEditingController();

    _recipient = widget.staffList.first;
    _type = CashAdvanceType.pettyCash;
    _currency = 'EGP';
    _account = AppAccounts.getAccountCodes().first;
    _project = AppProjects.getProjectNames().first;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final textColor = AppColors.getTextPrimary(context);

    return Dialog(
      backgroundColor: AppColors.getSurface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_card_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isArabic ? 'إصدار عهدة مالية جديدة للموظف' : 'Issue New Cash Advance to Staff',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
                Divider(color: AppColors.getDivider(context), height: 24),

                // Recipient & ID
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _idCtrl,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'كود العهدة *' : 'Advance ID *'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        initialValue: _recipient,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'الموظف المستلم للعهدة *' : 'Recipient Staff Member *'),
                        items: widget.staffList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _recipient = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title / Purpose
                TextFormField(
                  controller: _titleCtrl,
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: isArabic ? 'سبب والغرض من العهدة *' : 'Advance Title / Purpose *',
                    hintText: 'e.g. Site Travel & Spare Parts Custody',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Type & Currency
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CashAdvanceType>(
                        initialValue: _type,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'نوع العهدة *' : 'Advance Type *'),
                        items: CashAdvanceType.values.map((t) {
                          return DropdownMenuItem(value: t, child: Text(t.getLocalizedName(isArabic)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _type = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _currency,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'العملة *' : 'Currency *'),
                        items: ['EGP', 'EUR', 'USD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _currency = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount & Account
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(labelText: isArabic ? 'مبلغ العهدة الأولية *' : 'Initial Disbursed Amount *'),
                        validator: (val) {
                          if (val == null || double.tryParse(val) == null || double.parse(val) <= 0) {
                            return 'Enter valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _account,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'خزينة / حساب الصرف *' : 'Source Vault / Account *'),
                        items: AppAccounts.getAccountCodes().map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _account = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Project
                DropdownButtonFormField<String>(
                  initialValue: _project,
                  dropdownColor: AppColors.getSurface(context),
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(labelText: isArabic ? 'المشروع المرتبط بالعهدة *' : 'Linked Engineering Project *'),
                  items: AppProjects.getProjectNames().map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _project = val);
                  },
                ),
                const SizedBox(height: 12),

                // Notes
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(labelText: isArabic ? 'ملاحظات إضافية' : 'Additional Notes'),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final adv = CashAdvanceModel(
                            id: _idCtrl.text.trim().toUpperCase(),
                            recipientName: _recipient,
                            title: _titleCtrl.text.trim(),
                            advanceType: _type,
                            currency: _currency,
                            initialAmount: double.parse(_amountCtrl.text.trim()),
                            dateDisbursed: DateTime.now(),
                            sourceAccount: _account,
                            projectTag: _project,
                            notes: _notesCtrl.text.trim(),
                          );
                          widget.onSave(adv);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                      label: Text(isArabic ? 'إصدار العهدة' : 'Issue Advance', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordExpenseModal extends StatefulWidget {
  final CashAdvanceModel advance;
  final Function(CashAdvanceExpenseModel) onSave;

  const _RecordExpenseModal({
    required this.advance,
    required this.onSave,
  });

  @override
  State<_RecordExpenseModal> createState() => _RecordExpenseModalState();
}

class _RecordExpenseModalState extends State<_RecordExpenseModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _invoiceCtrl;
  late TextEditingController _vendorCtrl;

  late String _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _idCtrl = TextEditingController(text: 'EXP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    _descCtrl = TextEditingController();
    _amountCtrl = TextEditingController(text: '0.00');
    _invoiceCtrl = TextEditingController();
    _vendorCtrl = TextEditingController();

    _category = AppCategories.getAllSubcategories().first;
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _invoiceCtrl.dispose();
    _vendorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final textColor = AppColors.getTextPrimary(context);

    return Dialog(
      backgroundColor: AppColors.getSurface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long, color: AppColors.warning, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'إثبات مصروف على عهدة: ${widget.advance.recipientName}' : 'Record Expense for: ${widget.advance.recipientName}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          Text(
                            'Advance ID: ${widget.advance.id} (${widget.advance.currency})',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: AppColors.getDivider(context), height: 24),

                // Description
                TextFormField(
                  controller: _descCtrl,
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: isArabic ? 'وصف البند / ما تم شراؤه *' : 'Expense Description / Purchased Item *',
                    hintText: 'e.g. Purchase of Siemens relay modules',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Category & Amount
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _category,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'تصنيف المصروف *' : 'Expense Category *'),
                        items: AppCategories.getAllSubcategories().map((c) {
                          return DropdownMenuItem(value: c, child: Text(AppCategories.getLocalizedName(c, isArabic)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: isArabic ? 'المبلغ المصروف *' : 'Amount Spent *',
                          prefixText: '${widget.advance.currency} ',
                        ),
                        validator: (val) {
                          if (val == null || double.tryParse(val) == null || double.parse(val) <= 0) {
                            return 'Enter valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Invoice # & Vendor
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _invoiceCtrl,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'رقم الإيصال / الفاتورة' : 'Receipt / Invoice #'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _vendorCtrl,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'اسم المورد / المحل' : 'Vendor / Supplier Name'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final expense = CashAdvanceExpenseModel(
                            id: _idCtrl.text.trim().toUpperCase(),
                            date: _date,
                            description: _descCtrl.text.trim(),
                            category: _category,
                            amount: double.parse(_amountCtrl.text.trim()),
                            invoiceNumber: _invoiceCtrl.text.trim(),
                            vendor: _vendorCtrl.text.trim(),
                          );
                          widget.onSave(expense);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                      label: Text(isArabic ? 'خصم وإثبات المصروف' : 'Deduct & Record Expense', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
