import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_projects.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/services/local_persistence_service.dart';
import '../../transactions/bloc/transaction_bloc.dart';
import '../../transactions/bloc/transaction_state.dart';
import '../../users/bloc/user_bloc.dart';
import '../../users/bloc/user_state.dart';
import '../../models/transaction_model.dart';
import '../../transactions/bloc/transaction_event.dart';
import '../../transactions/presentation/widgets/transaction_dialog.dart';
import '../../../core/constants/app_categories.dart';
import '../../../core/localization/locale_cubit.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<EngineeringProject> _projects = AppProjects.defaultProjects;
  String? _selectedProjectName;
  bool _isLoadingProjects = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final saved = await LocalPersistenceService.loadProjects();
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _projects = saved;
        _isLoadingProjects = false;
      });
    } else {
      await LocalPersistenceService.saveProjects(AppProjects.defaultProjects);
      setState(() {
        _isLoadingProjects = false;
      });
    }
  }

  void _saveProject(EngineeringProject project) {
    setState(() {
      final index = _projects.indexWhere((p) => p.id == project.id || p.name == project.name);
      if (index >= 0) {
        _projects[index] = project;
      } else {
        _projects.insert(0, project);
      }
    });
    LocalPersistenceService.saveProjects(_projects);
  }

  void _openProjectFormModal(BuildContext context, [EngineeringProject? projectToEdit]) {
    showDialog(
      context: context,
      builder: (ctx) => _ProjectFormModal(
        projectToEdit: projectToEdit,
        onSave: (project) {
          _saveProject(project);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                projectToEdit != null
                    ? 'Project ${project.id} details updated successfully! 🛠️'
                    : 'New Project Cost Center ${project.id} created successfully! 🚀',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  String _activeDetailTab = 'overview';

  void _openAddTransactionModal(BuildContext context, String projectName, TransactionType type) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    showDialog(
      context: context,
      builder: (ctx) => TransactionDialog(
        initialProjectTag: projectName,
        initialType: type,
        availableProjectNames: _projects.map((p) => p.name).toList(),
        onSave: (txn) {
          context.read<TransactionBloc>().add(AddTransaction(txn));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                type == TransactionType.expense
                    ? (isArabic ? 'تم تسجيل تكلفة إضافية للمشروع ($projectName) بنجاح 💸' : 'Expense cost added to project ($projectName) 💸')
                    : (isArabic ? 'تم تسجيل إيراد جديد للمشروع ($projectName) بنجاح 💰' : 'Revenue inflow added to project ($projectName) 💰'),
              ),
              backgroundColor: type == TransactionType.expense ? AppColors.error : AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _openEditTransactionModal(BuildContext context, TransactionModel txn) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    showDialog(
      context: context,
      builder: (ctx) => TransactionDialog(
        transactionToEdit: txn,
        availableProjectNames: _projects.map((p) => p.name).toList(),
        onSave: (updated) {
          context.read<TransactionBloc>().add(UpdateTransaction(updated));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isArabic ? 'تم تحديث البيانات المالية بنجاح ✏️' : 'Financial entry updated successfully ✏️'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  void _deleteTransaction(BuildContext context, String id) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    context.read<TransactionBloc>().add(DeleteTransaction(id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? 'تم حذف الحركة من مركز التكلفة 🗑️' : 'Entry removed from cost center 🗑️'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 700 ? 1 : (screenWidth < 1100 ? 2 : 3);
    final aspectRatio = screenWidth < 700 ? 1.05 : 1.25;

    final activeUser = context.watch<UserBloc>().state is UserLoaded
        ? (context.watch<UserBloc>().state as UserLoaded).activeUser
        : null;
    final canViewRevenues = activeUser?.permissions.canViewProjectRevenues ?? false;

    if (_isLoadingProjects) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final allTransactions = state.allTransactions;

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
                        Text(
                          isArabic ? 'مراكز تكاليف المشاريع الهندسية' : 'ENGINEERING PROJECTS & COST CENTERS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? 'إدارة بيانات المشاريع، تحديث الحالات، ومتابعة ميزانيات التكاليف والإيرادات'
                              : 'Manage project data entry, status updates, cost budgets & contract revenues',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openProjectFormModal(context),
                    icon: const Icon(Icons.add_business_rounded, size: 18, color: Colors.white),
                    label: Text(
                      isArabic ? 'مشروع جديد +' : '+ New Project Entry',
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

              // Project Cards Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  final projTxns = allTransactions.where((t) => t.projectTag == project.name).toList();

                  final egpSpent = projTxns.fold(0.0, (s, item) => s + item.amountEgp);
                  final eurSpent = projTxns.fold(0.0, (s, item) => s + item.amountEur);
                  final usdSpent = projTxns.fold(0.0, (s, item) => s + item.amountUsd);

                  final isSelected = _selectedProjectName == project.name;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedProjectName = isSelected ? null : project.name;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.getSurface(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.getDivider(context),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Project ID & Status Badge with Edit Action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadge(
                                text: project.id,
                                color: AppColors.secondary,
                                icon: Icons.tag,
                              ),
                              Row(
                                children: [
                                  StatusBadge(
                                    text: project.status,
                                    color: project.status == 'Active'
                                        ? AppColors.success
                                        : (project.status == 'Completed'
                                            ? AppColors.eur
                                            : (project.status == 'Planned' ? AppColors.usd : AppColors.warning)),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryLight),
                                    tooltip: isArabic ? 'تعديل وتحديث المشروع' : 'Edit Project Data & Status',
                                    onPressed: () => _openProjectFormModal(context, project),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Project Name & Client Info
                          Text(
                            project.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${project.client} • ${project.location}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),

                          const Spacer(),
                          Divider(color: AppColors.getDivider(context), height: 12),

                          // Costs Breakdown Row (Actual Costs Incurred)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('EGP COST', style: TextStyle(fontSize: 9, color: AppColors.egp, fontWeight: FontWeight.bold)),
                                  Text(CurrencyFormatter.format(egpSpent, Currency.EGP), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(context))),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('EUR COST', style: TextStyle(fontSize: 9, color: AppColors.eur, fontWeight: FontWeight.bold)),
                                  Text(CurrencyFormatter.format(eurSpent, Currency.EUR), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(context))),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('USD COST', style: TextStyle(fontSize: 9, color: AppColors.usd, fontWeight: FontWeight.bold)),
                                  Text(CurrencyFormatter.format(usdSpent, Currency.USD), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(context))),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Financial Revenue & Contract Value Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.getBackground(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.getDivider(context)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isArabic ? 'إيرادات العقد:' : 'Contract Revenue:',
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  canViewRevenues
                                      ? (project.contractRevenueEgp > 0
                                          ? CurrencyFormatter.format(project.contractRevenueEgp, Currency.EGP)
                                          : project.contractRevenueEur > 0
                                              ? CurrencyFormatter.format(project.contractRevenueEur, Currency.EUR)
                                              : project.contractRevenueUsd > 0
                                                  ? CurrencyFormatter.format(project.contractRevenueUsd, Currency.USD)
                                                  : (isArabic ? 'غير محدد' : 'Unspecified'))
                                      : '•••••• (Restricted)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: canViewRevenues ? AppColors.success : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              if (_selectedProjectName != null) ...[
                const SizedBox(height: 24),
                _buildProjectCostCenterHub(
                  _projects.firstWhere(
                    (p) => p.name == _selectedProjectName,
                    orElse: () => EngineeringProject(id: 'PRJ', name: _selectedProjectName!, client: '', location: '', status: 'Active'),
                  ),
                  allTransactions.where((t) => t.projectTag == _selectedProjectName).toList(),
                  isArabic,
                  canViewRevenues,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectCostCenterHub(
    EngineeringProject project,
    List<TransactionModel> allProjectTxns,
    bool isArabic,
    bool canViewRevenues,
  ) {
    final expenses = allProjectTxns.where((t) => t.type == TransactionType.expense).toList();
    final revenues = allProjectTxns.where((t) => t.type == TransactionType.revenue).toList();

    // Expenses Totals
    final totalExpEgp = expenses.fold(0.0, (sum, t) => sum + t.amountEgp);
    final totalExpEur = expenses.fold(0.0, (sum, t) => sum + t.amountEur);
    final totalExpUsd = expenses.fold(0.0, (sum, t) => sum + t.amountUsd);

    // Direct Revenues Inflows Totals
    final directRevEgp = revenues.fold(0.0, (sum, t) => sum + t.amountEgp);
    final directRevEur = revenues.fold(0.0, (sum, t) => sum + t.amountEur);
    final directRevUsd = revenues.fold(0.0, (sum, t) => sum + t.amountUsd);

    // Total Project Revenues (Contract Value + Direct Inflows)
    final totalRevEgp = project.contractRevenueEgp + directRevEgp;
    final totalRevEur = project.contractRevenueEur + directRevEur;
    final totalRevUsd = project.contractRevenueUsd + directRevUsd;

    // Calculated Net Profit / Performance (Revenues - Expenses)
    final netEgp = totalRevEgp - totalExpEgp;
    final netEur = totalRevEur - totalExpEur;
    final netUsd = totalRevUsd - totalExpUsd;

    // Budget vs Spent Variance Calculations
    final budgetEgp = project.estimatedCostEgp;
    final budgetEur = project.estimatedCostEur;
    final budgetUsd = project.estimatedCostUsd;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Executive Cost Center Header Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isArabic ? 'مركز تكاليف وإيرادات المشروع: ${project.name}' : 'PROJECT COST CENTER & FINANCIAL HUB: ${project.name}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.getTextPrimary(context),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(text: project.id, color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${project.client} • ${project.location} • Status: ${project.status}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Action Buttons Header
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _openAddTransactionModal(context, project.name, TransactionType.expense),
                    icon: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.white),
                    label: Text(
                      isArabic ? 'إضافة تكلفة (Expense) +' : '+ Add Project Cost',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openAddTransactionModal(context, project.name, TransactionType.revenue),
                    icon: const Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
                    label: Text(
                      isArabic ? 'إضافة إيراد (Revenue) +' : '+ Add Project Revenue',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openProjectFormModal(context, project),
                    icon: const Icon(Icons.tune, size: 16, color: AppColors.primary),
                    label: Text(
                      isArabic ? 'الميزانية والعقد' : 'Budget & Details',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => setState(() => _selectedProjectName = null),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Financial KPI Cards Grid
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
                  // Card 1: Total Revenues
                  _buildKpiCard(
                    context: context,
                    title: isArabic ? 'إجمالي الإيرادات (Contract + Inflows)' : 'TOTAL REVENUES',
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.success,
                    egp: canViewRevenues ? totalRevEgp : null,
                    eur: canViewRevenues ? totalRevEur : null,
                    usd: canViewRevenues ? totalRevUsd : null,
                    subtitle: isArabic
                        ? 'العقد: ${project.contractRevenueEgp > 0 ? CurrencyFormatter.format(project.contractRevenueEgp, Currency.EGP) : (project.contractRevenueEur > 0 ? CurrencyFormatter.format(project.contractRevenueEur, Currency.EUR) : CurrencyFormatter.format(project.contractRevenueUsd, Currency.USD))} | إيرادات إضافية: ${revenues.length}'
                        : 'Contract + ${revenues.length} Direct Inflows',
                  ),

                  // Card 2: Total Expenses
                  _buildKpiCard(
                    context: context,
                    title: isArabic ? 'إجمالي التكاليف والمصروفات' : 'TOTAL COSTS & EXPENSES',
                    icon: Icons.trending_down_rounded,
                    iconColor: AppColors.error,
                    egp: totalExpEgp,
                    eur: totalExpEur,
                    usd: totalExpUsd,
                    subtitle: isArabic ? '${expenses.length} حركة مصاريف مسجلة' : '${expenses.length} Expense Transactions Recorded',
                  ),

                  // Card 3: Net Profitability
                  _buildKpiCard(
                    context: context,
                    title: isArabic ? 'صافي أرباح المشروع' : 'NET PROJECT PROFIT',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: canViewRevenues && (netEgp >= 0 && netEur >= 0 && netUsd >= 0)
                        ? AppColors.success
                        : AppColors.warning,
                    egp: canViewRevenues ? netEgp : null,
                    eur: canViewRevenues ? netEur : null,
                    usd: canViewRevenues ? netUsd : null,
                    subtitle: isArabic ? 'صافي هامش الإيرادات مطروحاً التكاليف' : 'Revenues minus Actual Costs Incurred',
                  ),

                  // Card 4: Budget Variance
                  _buildBudgetKpiCard(
                    context: context,
                    isArabic: isArabic,
                    budgetEgp: budgetEgp,
                    budgetEur: budgetEur,
                    budgetUsd: budgetUsd,
                    spentEgp: totalExpEgp,
                    spentEur: totalExpEur,
                    spentUsd: totalExpUsd,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 3. Segmented Tab Navigation Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.getBackground(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.getDivider(context)),
            ),
            child: Row(
              children: [
                _buildTabButton('overview', isArabic ? '📊 نظرة مالية عامة' : '📊 Overview & Analytics', isArabic),
                _buildTabButton('expenses', isArabic ? '🔴 التكاليف والمصروفات (${expenses.length})' : '🔴 Costs & Expenses (${expenses.length})', isArabic),
                _buildTabButton('revenues', isArabic ? '🟢 الإيرادات والتحصيلات (${revenues.length})' : '🟢 Revenues & Inflows (${revenues.length})', isArabic),
                _buildTabButton('all', isArabic ? '📋 جميع الحركات المالية (${allProjectTxns.length})' : '📋 All Ledger Entries (${allProjectTxns.length})', isArabic),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Tab Content Body
          if (_activeDetailTab == 'overview')
            _buildOverviewTab(context, project, expenses, revenues, isArabic)
          else if (_activeDetailTab == 'expenses')
            _buildTransactionsTable(context, expenses, isArabic, isExpenseTable: true)
          else if (_activeDetailTab == 'revenues')
            _buildRevenuesTab(context, project, revenues, isArabic, canViewRevenues)
          else
            _buildTransactionsTable(context, allProjectTxns, isArabic, isExpenseTable: false),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required double? egp,
    required double? eur,
    required double? usd,
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
          if (egp == null || eur == null || usd == null)
            const Text('•••••• (Restricted)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold))
          else ...[
            if (egp != 0.0)
              Text(CurrencyFormatter.format(egp, Currency.EGP), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: egp >= 0 ? AppColors.getTextPrimary(context) : AppColors.error)),
            if (eur != 0.0)
              Text(CurrencyFormatter.format(eur, Currency.EUR), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: eur >= 0 ? AppColors.eur : AppColors.error)),
            if (usd != 0.0)
              Text(CurrencyFormatter.format(usd, Currency.USD), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: usd >= 0 ? AppColors.usd : AppColors.error)),
            if (egp == 0.0 && eur == 0.0 && usd == 0.0)
              Text('0.00 EGP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(context))),
          ],
          const Spacer(),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildBudgetKpiCard({
    required BuildContext context,
    required bool isArabic,
    required double budgetEgp,
    required double budgetEur,
    required double budgetUsd,
    required double spentEgp,
    required double spentEur,
    required double spentUsd,
  }) {
    final hasBudget = budgetEgp > 0 || budgetEur > 0 || budgetUsd > 0;
    double progress = 0.0;
    if (budgetEgp > 0) {
      progress = spentEgp / budgetEgp;
    } else if (budgetEur > 0) {
      progress = spentEur / budgetEur;
    } else if (budgetUsd > 0) {
      progress = spentUsd / budgetUsd;
    }

    final progressPct = (progress * 100).clamp(0, 999).toStringAsFixed(1);
    final isOverBudget = progress > 1.0;

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
              Icon(Icons.flag_rounded, size: 16, color: isOverBudget ? AppColors.error : AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isArabic ? 'مقارنة الميزانية المقدرة' : 'BUDGET VARIANCE',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (!hasBudget)
            Text(isArabic ? 'غير محددة' : 'No Budget Set', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else ...[
            Text('$progressPct% ${isArabic ? 'مستهلك' : 'Used'}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isOverBudget ? AppColors.error : AppColors.success)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.getDivider(context),
                color: isOverBudget ? AppColors.error : (progress > 0.85 ? AppColors.warning : AppColors.success),
                minHeight: 6,
              ),
            ),
          ],
          const Spacer(),
          Text(
            hasBudget
                ? (budgetEgp > 0
                    ? 'Budget: ${CurrencyFormatter.format(budgetEgp, Currency.EGP)}'
                    : (budgetEur > 0 ? 'Budget: ${CurrencyFormatter.format(budgetEur, Currency.EUR)}' : 'Budget: ${CurrencyFormatter.format(budgetUsd, Currency.USD)}'))
                : 'Edit project to set budget',
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String key, String label, bool isArabic) {
    final isSelected = _activeDetailTab == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeDetailTab = key),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.getTextPrimary(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    EngineeringProject project,
    List<TransactionModel> expenses,
    List<TransactionModel> revenues,
    bool isArabic,
  ) {
    final categoryTotals = <String, Map<String, double>>{};
    for (final t in expenses) {
      final cat = t.category;
      categoryTotals.putIfAbsent(cat, () => {'egp': 0, 'eur': 0, 'usd': 0});
      categoryTotals[cat]!['egp'] = (categoryTotals[cat]!['egp'] ?? 0) + t.amountEgp;
      categoryTotals[cat]!['eur'] = (categoryTotals[cat]!['eur'] ?? 0) + t.amountEur;
      categoryTotals[cat]!['usd'] = (categoryTotals[cat]!['usd'] ?? 0) + t.amountUsd;
    }

    final totalEgpSpent = expenses.fold(0.0, (s, t) => s + t.amountEgp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'توزيع المصروفات حسب التصنيف (Expense Category Breakdown):' : 'Expense Category Breakdown:',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
        ),
        const SizedBox(height: 12),
        if (categoryTotals.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(isArabic ? 'لا توجد مصاريف تفصيلية مسجلة بعد' : 'No categorized expenses recorded yet.', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryTotals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cat = categoryTotals.keys.elementAt(index);
              final map = categoryTotals[cat]!;
              final egpVal = map['egp'] ?? 0;
              final eurVal = map['eur'] ?? 0;
              final usdVal = map['usd'] ?? 0;
              final pct = totalEgpSpent > 0 ? (egpVal / totalEgpSpent).clamp(0.0, 1.0) : 0.0;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.getBackground(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.getDivider(context)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            StatusBadge(text: AppCategories.getLocalizedName(cat, isArabic), color: AppColors.primaryLight),
                            const SizedBox(width: 8),
                            Text('${(pct * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            if (egpVal > 0) Text(CurrencyFormatter.format(egpVal, Currency.EGP), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(context))),
                            if (eurVal > 0) ...[const SizedBox(width: 8), Text(CurrencyFormatter.format(eurVal, Currency.EUR), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.eur))],
                            if (usdVal > 0) ...[const SizedBox(width: 8), Text(CurrencyFormatter.format(usdVal, Currency.USD), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.usd))],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.getDivider(context),
                        color: AppColors.primary,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRevenuesTab(
    BuildContext context,
    EngineeringProject project,
    List<TransactionModel> revenues,
    bool isArabic,
    bool canViewRevenues,
  ) {
    if (!canViewRevenues) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(isArabic ? 'عفواً، لا تملك صلاحية عرض التفاصيل المالية للإيرادات 🔒' : 'Access Restricted: You do not have permission to view project revenues 🔒', style: const TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in_rounded, color: AppColors.success, size: 22),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isArabic ? 'إيراد وقيمة العقد الثابت للمشروع (Contract Baseline Value)' : 'Contract Baseline Revenue Value', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                      const SizedBox(height: 2),
                      Text(isArabic ? 'المبلغ المحدد في عقد المشروع الأساسي' : 'Baseline agreed contract amount', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              Text(
                project.contractRevenueEgp > 0
                    ? CurrencyFormatter.format(project.contractRevenueEgp, Currency.EGP)
                    : (project.contractRevenueEur > 0
                        ? CurrencyFormatter.format(project.contractRevenueEur, Currency.EUR)
                        : (project.contractRevenueUsd > 0 ? CurrencyFormatter.format(project.contractRevenueUsd, Currency.USD) : '0.00')),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.success),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isArabic ? 'تحصيلات وإيرادات إضافية للمشروع (${revenues.length}):' : 'Direct Revenue Inflows & Payments (${revenues.length}):', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
            ElevatedButton.icon(
              onPressed: () => _openAddTransactionModal(context, project.name, TransactionType.revenue),
              icon: const Icon(Icons.add, size: 14, color: Colors.white),
              label: Text(isArabic ? 'إضافة إيراد +' : '+ Add Revenue', style: const TextStyle(fontSize: 11, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTransactionsTable(context, revenues, isArabic, isExpenseTable: false),
      ],
    );
  }

  Widget _buildTransactionsTable(
    BuildContext context,
    List<TransactionModel> txns,
    bool isArabic, {
    required bool isExpenseTable,
  }) {
    if (txns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          isExpenseTable
              ? (isArabic ? 'لا توجد مصروفات مسجلة لهذا المشروع بعد. اضغط على "+ إضافة تكلفة" لإدخال بند جديد.' : 'No expenses recorded for this project yet. Click "+ Add Project Cost" to record one.')
              : (isArabic ? 'لا توجد حركات مسجلة في هذا القائمة.' : 'No transactions found in this view.'),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: txns.length,
      separatorBuilder: (_, _) => Divider(color: AppColors.getDivider(context), height: 12),
      itemBuilder: (context, index) {
        final t = txns[index];
        final isRev = t.type == TransactionType.revenue;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              Icon(
                isRev ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                size: 16,
                color: isRev ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(t.id, style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Text(
                '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(
                  t.description,
                  style: TextStyle(fontSize: 12, color: AppColors.getTextPrimary(context), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: StatusBadge(
                  text: AppCategories.getLocalizedName(t.category, isArabic),
                  color: isRev ? AppColors.success : AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  t.responsiblePerson,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (t.amountEgp > 0)
                Text(
                  CurrencyFormatter.format(t.amountEgp, Currency.EGP),
                  style: TextStyle(fontSize: 12, color: isRev ? AppColors.success : AppColors.egp, fontWeight: FontWeight.bold),
                ),
              if (t.amountEur > 0)
                Text(
                  CurrencyFormatter.format(t.amountEur, Currency.EUR),
                  style: TextStyle(fontSize: 12, color: isRev ? AppColors.success : AppColors.eur, fontWeight: FontWeight.bold),
                ),
              if (t.amountUsd > 0)
                Text(
                  CurrencyFormatter.format(t.amountUsd, Currency.USD),
                  style: TextStyle(fontSize: 12, color: isRev ? AppColors.success : AppColors.usd, fontWeight: FontWeight.bold),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryLight),
                tooltip: isArabic ? 'تعديل الحركة' : 'Edit Transaction',
                onPressed: () => _openEditTransactionModal(context, t),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                tooltip: isArabic ? 'حذف الحركة' : 'Delete Transaction',
                onPressed: () => _deleteTransaction(context, t.id),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectFormModal extends StatefulWidget {
  final EngineeringProject? projectToEdit;
  final Function(EngineeringProject) onSave;

  const _ProjectFormModal({
    this.projectToEdit,
    required this.onSave,
  });

  @override
  State<_ProjectFormModal> createState() => _ProjectFormModalState();
}

class _ProjectFormModalState extends State<_ProjectFormModal> {
  late TextEditingController _idCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _clientCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _costEgpCtrl;
  late TextEditingController _costEurCtrl;
  late TextEditingController _costUsdCtrl;
  late TextEditingController _revEgpCtrl;
  late TextEditingController _revEurCtrl;
  late TextEditingController _revUsdCtrl;
  late TextEditingController _notesCtrl;
  late String _status;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.projectToEdit;
    _idCtrl = TextEditingController(text: p?.id ?? 'PRJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _clientCtrl = TextEditingController(text: p?.client ?? '');
    _locationCtrl = TextEditingController(text: p?.location ?? 'Egypt');
    _status = p?.status ?? 'Active';

    _costEgpCtrl = TextEditingController(text: p != null && p.estimatedCostEgp > 0 ? p.estimatedCostEgp.toString() : '');
    _costEurCtrl = TextEditingController(text: p != null && p.estimatedCostEur > 0 ? p.estimatedCostEur.toString() : '');
    _costUsdCtrl = TextEditingController(text: p != null && p.estimatedCostUsd > 0 ? p.estimatedCostUsd.toString() : '');

    _revEgpCtrl = TextEditingController(text: p != null && p.contractRevenueEgp > 0 ? p.contractRevenueEgp.toString() : '');
    _revEurCtrl = TextEditingController(text: p != null && p.contractRevenueEur > 0 ? p.contractRevenueEur.toString() : '');
    _revUsdCtrl = TextEditingController(text: p != null && p.contractRevenueUsd > 0 ? p.contractRevenueUsd.toString() : '');

    _notesCtrl = TextEditingController(text: p?.notes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final isEditing = widget.projectToEdit != null;
    final textColor = AppColors.getTextPrimary(context);

    return Dialog(
      backgroundColor: AppColors.getSurface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 580,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Title Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.business_center_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing
                          ? (isArabic ? 'تعديل مركز تكلفة المشروع' : 'Edit Project Cost Center')
                          : (isArabic ? 'إدخال مشروع هندسي جديد' : 'New Project Cost Center Entry'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
                Divider(color: AppColors.getDivider(context), height: 24),

                // Section 1: Basic Information
                Text(
                  isArabic ? 'بيانات المشروع الأساسية:' : 'Basic Project Details:',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _idCtrl,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: isArabic ? 'كود المشروع *' : 'Project ID *',
                          hintText: 'e.g. PRJ-009',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _nameCtrl,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: isArabic ? 'اسم المشروع *' : 'Project Name *',
                          hintText: 'e.g. Cairo Metro Automation',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _clientCtrl,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: isArabic ? 'اسم العميل *' : 'Client Name *',
                          hintText: 'e.g. Siemens / Suez Cement',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _locationCtrl,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: isArabic ? 'الموقع / الدولة *' : 'Location / Country *',
                          hintText: 'e.g. Egypt / UAE',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  dropdownColor: AppColors.getSurface(context),
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: isArabic ? 'حالة المشروع الحالية *' : 'Current Project Status *',
                    prefixIcon: const Icon(Icons.flag_rounded, color: AppColors.primaryLight, size: 20),
                  ),
                  items: ['Active', 'Completed', 'On-Hold', 'Planned'].map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 20),

                // Section 2: Cost Budgets & Revenues
                Text(
                  isArabic ? 'التفاصيل المالية (الميزانية والإيرادات):' : 'Financial Details (Cost Budgets & Contract Revenues):',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),

                // Estimated Cost Budgets Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.getBackground(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.getDivider(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'ميزانية التكاليف المقدرة (Cost Budget):' : 'Estimated Cost Budget:',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _costEgpCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: textColor, fontSize: 12),
                              decoration: const InputDecoration(labelText: 'EGP Budget', prefixText: 'EGP '),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _costEurCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: textColor, fontSize: 12),
                              decoration: const InputDecoration(labelText: 'EUR Budget', prefixText: '€ '),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _costUsdCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: textColor, fontSize: 12),
                              decoration: const InputDecoration(labelText: 'USD Budget', prefixText: '\$ '),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Contract Revenues Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.getBackground(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.getDivider(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'إيرادات وقيمة العقد (Contract Revenue):' : 'Contract Revenue & Value:',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _revEgpCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: textColor, fontSize: 12),
                              decoration: const InputDecoration(labelText: 'EGP Revenue', prefixText: 'EGP '),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _revEurCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: textColor, fontSize: 12),
                              decoration: const InputDecoration(labelText: 'EUR Revenue', prefixText: '€ '),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _revUsdCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: textColor, fontSize: 12),
                              decoration: const InputDecoration(labelText: 'USD Revenue', prefixText: '\$ '),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes / Manager Area
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: isArabic ? 'ملاحظات / مهندس المشروع المسؤول' : 'Notes / Responsible Project Engineer',
                    hintText: isArabic ? 'تفاصيل إضافية عن المشروع' : 'Additional project notes or scope',
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final project = EngineeringProject(
                            id: _idCtrl.text.trim().toUpperCase(),
                            name: _nameCtrl.text.trim(),
                            client: _clientCtrl.text.trim(),
                            location: _locationCtrl.text.trim(),
                            status: _status,
                            estimatedCostEgp: double.tryParse(_costEgpCtrl.text.trim()) ?? 0.0,
                            estimatedCostEur: double.tryParse(_costEurCtrl.text.trim()) ?? 0.0,
                            estimatedCostUsd: double.tryParse(_costUsdCtrl.text.trim()) ?? 0.0,
                            contractRevenueEgp: double.tryParse(_revEgpCtrl.text.trim()) ?? 0.0,
                            contractRevenueEur: double.tryParse(_revEurCtrl.text.trim()) ?? 0.0,
                            contractRevenueUsd: double.tryParse(_revUsdCtrl.text.trim()) ?? 0.0,
                            notes: _notesCtrl.text.trim(),
                          );

                          widget.onSave(project);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                      label: Text(
                        isEditing
                            ? (isArabic ? 'حفظ التحديثات' : 'Save Updates')
                            : (isArabic ? 'حفظ وإنشاء المشروع' : 'Create Project Entry'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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
