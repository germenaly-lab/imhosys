import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/constants/app_accounts.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/localization/locale_cubit.dart';
import '../bloc/payroll_bloc.dart';
import '../bloc/payroll_event.dart';
import '../bloc/payroll_state.dart';
import '../models/payroll_model.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedPeriodFilter;
  String? _selectedDeptFilter;
  PayrollStatus? _selectedStatusFilter;

  final List<String> _departments = [
    'Executive Management',
    'Control Systems',
    'Power & Drives',
    'Workshop & Fabrication',
    'Software & Automation',
    'Hardware & Design',
    'Finance & Admin',
  ];

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
  ];

  @override
  void initState() {
    super.initState();
    context.read<PayrollBloc>().add(LoadPayroll());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    context.read<PayrollBloc>().add(
          FilterPayroll(
            searchQuery: _searchCtrl.text.trim(),
            periodFilter: _selectedPeriodFilter,
            departmentFilter: _selectedDeptFilter,
            statusFilter: _selectedStatusFilter,
          ),
        );
  }

  void _openPayrollModal(BuildContext context, [PayrollModel? itemToEdit]) {
    showDialog(
      context: context,
      builder: (ctx) => _PayrollFormModal(
        itemToEdit: itemToEdit,
        staffList: _staffList,
        departments: _departments,
        onSave: (entry) {
          if (itemToEdit != null) {
            context.read<PayrollBloc>().add(UpdatePayrollEntry(entry));
          } else {
            context.read<PayrollBloc>().add(CreatePayrollEntry(entry));
          }

          final isArabic = context.read<LocaleCubit>().isArabic;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                itemToEdit != null
                    ? (isArabic ? 'تم تحديث كشف الراتب للموظف ${entry.employeeName} ✏️' : 'Payroll entry updated for ${entry.employeeName} ✏️')
                    : (isArabic ? 'تم تسجيل كشف الراتب للموظف ${entry.employeeName} بنجاح 💰' : 'Payroll entry created for ${entry.employeeName} 💰'),
              ),
              backgroundColor: AppColors.success,
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

    return BlocBuilder<PayrollBloc, PayrollState>(
      builder: (context, state) {
        if (state is PayrollLoading || state is PayrollInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is PayrollError) {
          return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
        }

        final loaded = state as PayrollLoaded;
        final entries = loaded.filteredEntries;
        final all = loaded.allEntries;

        // Executive Totals
        final baseEgp = all.where((p) => p.currency == 'EGP').fold(0.0, (s, p) => s + p.baseSalary);
        final baseEur = all.where((p) => p.currency == 'EUR').fold(0.0, (s, p) => s + p.baseSalary);
        final baseUsd = all.where((p) => p.currency == 'USD').fold(0.0, (s, p) => s + p.baseSalary);

        final allowEgp = all.where((p) => p.currency == 'EGP').fold(0.0, (s, p) => s + p.totalAllowances);
        final allowEur = all.where((p) => p.currency == 'EUR').fold(0.0, (s, p) => s + p.totalAllowances);
        final allowUsd = all.where((p) => p.currency == 'USD').fold(0.0, (s, p) => s + p.totalAllowances);

        final dedEgp = all.where((p) => p.currency == 'EGP').fold(0.0, (s, p) => s + p.totalDeductions);
        final dedEur = all.where((p) => p.currency == 'EUR').fold(0.0, (s, p) => s + p.totalDeductions);
        final dedUsd = all.where((p) => p.currency == 'USD').fold(0.0, (s, p) => s + p.totalDeductions);

        final netEgp = all.where((p) => p.currency == 'EGP').fold(0.0, (s, p) => s + p.netSalary);
        final netEur = all.where((p) => p.currency == 'EUR').fold(0.0, (s, p) => s + p.netSalary);
        final netUsd = all.where((p) => p.currency == 'USD').fold(0.0, (s, p) => s + p.netSalary);

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
                              child: const Icon(Icons.badge_rounded, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isArabic ? 'إدارة كشوفات المرتبات والأجور والبدلات' : 'PAYROLL & SALARY DISBURSEMENT HUB',
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
                              ? 'إدخال ومتابعة كشوف المرتبات الشهرية، البدلات، المكافآت، والاستقطاعات لكل مهندس وموظف'
                              : 'Manage monthly employee salaries, base pay, site allowances, bonuses, taxes & net payouts',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openPayrollModal(context),
                    icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.white),
                    label: Text(
                      isArabic ? 'إضافة راتب جديد +' : '+ Process Payroll Entry',
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

              // Executive KPI Summary Cards
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
                        title: isArabic ? 'إجمالي الرواتب الأساسية' : 'TOTAL BASE SALARIES',
                        icon: Icons.account_balance_rounded,
                        iconColor: AppColors.primary,
                        egp: baseEgp,
                        eur: baseEur,
                        usd: baseUsd,
                        subtitle: isArabic ? 'المرتبات الأساسية المتعاقد عليها' : 'Base Contracted Payroll',
                      ),
                      _buildKpiCard(
                        context: context,
                        title: isArabic ? 'إجمالي البدلات والمكافآت' : 'TOTAL ALLOWANCES & BONUSES',
                        icon: Icons.card_giftcard_rounded,
                        iconColor: AppColors.success,
                        egp: allowEgp,
                        eur: allowEur,
                        usd: allowUsd,
                        subtitle: isArabic ? 'بدلات الموقع والمكافآت التشجيعية' : 'Site Allowances + Bonuses',
                      ),
                      _buildKpiCard(
                        context: context,
                        title: isArabic ? 'إجمالي الاستقطاعات والعهد' : 'TOTAL DEDUCTIONS & ADVANCES',
                        icon: Icons.content_cut_rounded,
                        iconColor: AppColors.error,
                        egp: dedEgp,
                        eur: dedEur,
                        usd: dedUsd,
                        subtitle: isArabic ? 'الضرائب، التأمينات، وخصومات العهد' : 'Taxes, Insurance & Loan Deductions',
                      ),
                      _buildKpiCard(
                        context: context,
                        title: isArabic ? 'صافي الأجور المنصرفة' : 'NET PAYROLL COST',
                        icon: Icons.savings_rounded,
                        iconColor: AppColors.success,
                        egp: netEgp,
                        eur: netEur,
                        usd: netUsd,
                        subtitle: isArabic ? 'صافي المبالغ المسددة بالكامل' : 'Net Total Disbursed Payout',
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
                              hintText: isArabic ? 'بحث باسم الموظف، المسمى الوظيفي، أو القسم...' : 'Search employee name, job title, ID, or dept...',
                              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Department Filter
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String?>(
                            initialValue: _selectedDeptFilter,
                            dropdownColor: AppColors.getSurface(context),
                            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 12),
                            decoration: InputDecoration(
                              labelText: isArabic ? 'القسم' : 'Department',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(value: null, child: Text(isArabic ? 'جميع الأقسام' : 'All Departments')),
                              ..._departments.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedDeptFilter = val);
                              _applyFilter();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Status Filter
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<PayrollStatus?>(
                            initialValue: _selectedStatusFilter,
                            dropdownColor: AppColors.getSurface(context),
                            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 12),
                            decoration: InputDecoration(
                              labelText: isArabic ? 'حالة الصرف' : 'Status',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(value: null, child: Text(isArabic ? 'جميع الحالات' : 'All Statuses')),
                              ...PayrollStatus.values.map(
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

              // Payroll List Entries
              if (entries.isEmpty)
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
                      const Icon(Icons.no_accounts_rounded, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        isArabic ? 'لا توجد كشوفات مرتبات مطابقة للبحث' : 'No payroll entries found matching criteria',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    return _PayrollCard(
                      item: item,
                      isArabic: isArabic,
                      onEdit: () => _openPayrollModal(context, item),
                      onDelete: () {
                        context.read<PayrollBloc>().add(DeletePayrollEntry(item.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isArabic ? 'تم حذف سجل الراتب 🗑️' : 'Payroll entry deleted 🗑️'),
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
}

class _PayrollCard extends StatelessWidget {
  final PayrollModel item;
  final bool isArabic;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PayrollCard({
    required this.item,
    required this.isArabic,
    required this.onEdit,
    required this.onDelete,
  });

  Currency get _currencyEnum {
    switch (item.currency) {
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
    final currEnum = _currencyEnum;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getDivider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar & Employee Info & Actions
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                radius: 22,
                child: Text(
                  item.employeeName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
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
                          item.employeeName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(text: item.id, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        StatusBadge(text: item.department, color: AppColors.primaryLight),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.jobTitle} • Period: ${item.payPeriod}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: item.status.getLocalizedName(isArabic),
                color: item.status == PayrollStatus.paid
                    ? AppColors.success
                    : (item.status == PayrollStatus.approved ? AppColors.primary : AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Breakdown Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.getBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.getDivider(context)),
            ),
            child: Row(
              children: [
                // Base Salary
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isArabic ? 'الراتب الأساسي:' : 'Base Salary:', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(item.baseSalary, currEnum),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(context)),
                      ),
                    ],
                  ),
                ),
                Container(height: 30, width: 1, color: AppColors.getDivider(context)),
                const SizedBox(width: 10),

                // Allowances
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isArabic ? 'البدلات والمكافآت:' : 'Allowances & Bonuses:', style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '+ ${CurrencyFormatter.format(item.totalAllowances, currEnum)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ],
                  ),
                ),
                Container(height: 30, width: 1, color: AppColors.getDivider(context)),
                const SizedBox(width: 10),

                // Deductions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isArabic ? 'الاستقطاعات والخصومات:' : 'Deductions & Advances:', style: const TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '- ${CurrencyFormatter.format(item.totalDeductions, currEnum)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
                Container(height: 30, width: 1, color: AppColors.getDivider(context)),
                const SizedBox(width: 10),

                // Net Salary
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isArabic ? 'صافي المستحق للصرف:' : 'NET PAYOUT:', style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(item.netSalary, currEnum),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Footer info & buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Source Account: ${item.paymentAccount} • Date: ${item.payDate.year}-${item.payDate.month.toString().padLeft(2, '0')}-${item.payDate.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryLight),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayrollFormModal extends StatefulWidget {
  final PayrollModel? itemToEdit;
  final List<String> staffList;
  final List<String> departments;
  final Function(PayrollModel) onSave;

  const _PayrollFormModal({
    this.itemToEdit,
    required this.staffList,
    required this.departments,
    required this.onSave,
  });

  @override
  State<_PayrollFormModal> createState() => _PayrollFormModalState();
}

class _PayrollFormModalState extends State<_PayrollFormModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idCtrl;
  late TextEditingController _jobCtrl;
  late TextEditingController _periodCtrl;
  late TextEditingController _baseCtrl;
  late TextEditingController _allowanceCtrl;
  late TextEditingController _bonusCtrl;
  late TextEditingController _taxCtrl;
  late TextEditingController _insuranceCtrl;
  late TextEditingController _advanceCtrl;
  late TextEditingController _otherCtrl;
  late TextEditingController _notesCtrl;

  late String _employee;
  late String _dept;
  late String _currency;
  late String _account;
  late PayrollStatus _status;

  @override
  void initState() {
    super.initState();
    final p = widget.itemToEdit;
    _idCtrl = TextEditingController(text: p?.id ?? 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    _jobCtrl = TextEditingController(text: p?.jobTitle ?? 'Automation Engineer');
    _periodCtrl = TextEditingController(text: p?.payPeriod ?? 'August 2026');
    _baseCtrl = TextEditingController(text: p != null ? p.baseSalary.toString() : '0.00');
    _allowanceCtrl = TextEditingController(text: p != null ? p.siteAllowance.toString() : '0.00');
    _bonusCtrl = TextEditingController(text: p != null ? p.bonus.toString() : '0.00');
    _taxCtrl = TextEditingController(text: p != null ? p.taxDeduction.toString() : '0.00');
    _insuranceCtrl = TextEditingController(text: p != null ? p.insuranceDeduction.toString() : '0.00');
    _advanceCtrl = TextEditingController(text: p != null ? p.advanceDeduction.toString() : '0.00');
    _otherCtrl = TextEditingController(text: p != null ? p.otherDeductions.toString() : '0.00');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');

    _employee = p?.employeeName ?? widget.staffList.first;
    _dept = p?.department ?? widget.departments.first;
    _currency = p?.currency ?? 'EGP';
    _account = p?.paymentAccount ?? AppAccounts.getAccountCodes().first;
    _status = p?.status ?? PayrollStatus.paid;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _jobCtrl.dispose();
    _periodCtrl.dispose();
    _baseCtrl.dispose();
    _allowanceCtrl.dispose();
    _bonusCtrl.dispose();
    _taxCtrl.dispose();
    _insuranceCtrl.dispose();
    _advanceCtrl.dispose();
    _otherCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final isEditing = widget.itemToEdit != null;
    final textColor = AppColors.getTextPrimary(context);

    return Dialog(
      backgroundColor: AppColors.getSurface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 620,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
                      child: const Icon(Icons.badge_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? (isArabic ? 'تعديل كشف الراتب' : 'Edit Payroll Entry') : (isArabic ? 'إصدار كشف راتب جديد للموظف' : 'New Payroll Disbursement Entry'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
                Divider(color: AppColors.getDivider(context), height: 24),

                // Employee & Dept
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: _employee,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'اسم المهندس / الموظف *' : 'Employee Name *'),
                        items: widget.staffList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _employee = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _dept,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'القسم *' : 'Department *'),
                        items: widget.departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _dept = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Job Title & Period
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _jobCtrl,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'المسمى الوظيفي *' : 'Job Title *'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _periodCtrl,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'شهر الصرف *' : 'Pay Period *'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Currency & Account
                Row(
                  children: [
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _account,
                        dropdownColor: AppColors.getSurface(context),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'حساب الصرف *' : 'Source Vault Account *'),
                        items: AppAccounts.getAccountCodes().map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _account = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Base Salary & Allowances Section
                Text(isArabic ? 'الراتب والبدلات (Earnings):' : 'Earnings Breakdown:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _baseCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(labelText: isArabic ? 'الراتب الأساسي *' : 'Base Salary *'),
                        validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _allowanceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'بدل الموقع' : 'Site Allowance'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _bonusCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'المكافأة' : 'Performance Bonus'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Deductions Section
                Text(isArabic ? 'الاستقطاعات والخصومات (Deductions):' : 'Deductions Breakdown:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _taxCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'ضريبة الدخل' : 'Tax Deduction'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _insuranceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'التأمينات' : 'Social Insurance'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _advanceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(labelText: isArabic ? 'خصم سلفة/عهدة' : 'Advance Deduction'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                DropdownButtonFormField<PayrollStatus>(
                  initialValue: _status,
                  dropdownColor: AppColors.getSurface(context),
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(labelText: isArabic ? 'حالة الراتب *' : 'Disbursement Status *'),
                  items: PayrollStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.getLocalizedName(isArabic)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 12),

                // Notes
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(labelText: isArabic ? 'ملاحظات' : 'Notes'),
                ),
                const SizedBox(height: 24),

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
                          final item = PayrollModel(
                            id: _idCtrl.text.trim().toUpperCase(),
                            employeeName: _employee,
                            jobTitle: _jobCtrl.text.trim(),
                            department: _dept,
                            payPeriod: _periodCtrl.text.trim(),
                            payDate: DateTime.now(),
                            currency: _currency,
                            baseSalary: double.parse(_baseCtrl.text.trim()),
                            siteAllowance: double.tryParse(_allowanceCtrl.text.trim()) ?? 0.0,
                            bonus: double.tryParse(_bonusCtrl.text.trim()) ?? 0.0,
                            taxDeduction: double.tryParse(_taxCtrl.text.trim()) ?? 0.0,
                            insuranceDeduction: double.tryParse(_insuranceCtrl.text.trim()) ?? 0.0,
                            advanceDeduction: double.tryParse(_advanceCtrl.text.trim()) ?? 0.0,
                            otherDeductions: double.tryParse(_otherCtrl.text.trim()) ?? 0.0,
                            paymentAccount: _account,
                            status: _status,
                            notes: _notesCtrl.text.trim(),
                          );
                          widget.onSave(item);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                      label: Text(
                        isEditing ? (isArabic ? 'حفظ التعديلات' : 'Save Changes') : (isArabic ? 'إصدار الراتب' : 'Disburse Payroll'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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
