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
                _buildProjectLedgerDrilldown(
                  _selectedProjectName!,
                  allTransactions.where((t) => t.projectTag == _selectedProjectName).toList(),
                  isArabic,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectLedgerDrilldown(String projectName, List<TransactionModel> txns, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.engineering, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'PROJECT LEDGER DRILL-DOWN: $projectName',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(context)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => setState(() => _selectedProjectName = null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (txns.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No direct expenses recorded for this project yet.', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: txns.length,
              separatorBuilder: (_, _) => Divider(color: AppColors.getDivider(context), height: 12),
              itemBuilder: (context, index) {
                final t = txns[index];
                return Row(
                  children: [
                    Text(t.id, style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Text(t.description, style: TextStyle(fontSize: 12, color: AppColors.getTextPrimary(context))),
                    ),
                    Expanded(
                      flex: 2,
                      child: StatusBadge(text: AppCategories.getLocalizedName(t.category, isArabic), color: AppColors.primaryLight),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(t.responsiblePerson, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    if (t.amountEgp > 0) Text(CurrencyFormatter.format(t.amountEgp, Currency.EGP), style: const TextStyle(fontSize: 12, color: AppColors.egp, fontWeight: FontWeight.bold)),
                    if (t.amountEur > 0) Text(CurrencyFormatter.format(t.amountEur, Currency.EUR), style: const TextStyle(fontSize: 12, color: AppColors.eur, fontWeight: FontWeight.bold)),
                    if (t.amountUsd > 0) Text(CurrencyFormatter.format(t.amountUsd, Currency.USD), style: const TextStyle(fontSize: 12, color: AppColors.usd, fontWeight: FontWeight.bold)),
                  ],
                );
              },
            ),
        ],
      ),
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
