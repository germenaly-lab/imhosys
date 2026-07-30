import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_projects.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/widgets/status_badge.dart';
import '../../transactions/bloc/transaction_bloc.dart';
import '../../transactions/bloc/transaction_state.dart';
import '../../models/transaction_model.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/localization/locale_cubit.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String? _selectedProjectName;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final projects = AppProjects.defaultProjects;

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 700 ? 1 : (screenWidth < 1100 ? 2 : 3);
    final aspectRatio = screenWidth < 700 ? 1.25 : 1.45;

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
              const Text(
                'ENGINEERING PROJECTS & COST CENTERS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track cost breakdown, multi-currency expenses, and site allowances per project',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final projTxns = allTransactions.where((t) => t.projectTag == project.name).toList();

                  final egpSum = projTxns.fold(0.0, (s, item) => s + item.amountEgp);
                  final eurSum = projTxns.fold(0.0, (s, item) => s + item.amountEur);
                  final usdSum = projTxns.fold(0.0, (s, item) => s + item.amountUsd);

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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.divider,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadge(
                                text: project.id,
                                color: AppColors.secondary,
                                icon: Icons.tag,
                              ),
                              StatusBadge(
                                text: project.status,
                                color: project.status == 'Active' ? AppColors.success : AppColors.warning,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
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
                          const Divider(color: AppColors.divider, height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('EGP COST', style: TextStyle(fontSize: 9, color: AppColors.egp, fontWeight: FontWeight.bold)),
                                  Text(CurrencyFormatter.format(egpSum, Currency.EGP), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('EUR COST', style: TextStyle(fontSize: 9, color: AppColors.eur, fontWeight: FontWeight.bold)),
                                  Text(CurrencyFormatter.format(eurSum, Currency.EUR), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('USD COST', style: TextStyle(fontSize: 9, color: AppColors.usd, fontWeight: FontWeight.bold)),
                                  Text(CurrencyFormatter.format(usdSum, Currency.USD), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                              ),
                            ],
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
        color: AppColors.surface,
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
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
              separatorBuilder: (_, _) => const Divider(color: AppColors.divider, height: 12),
              itemBuilder: (context, index) {
                final t = txns[index];
                return Row(
                  children: [
                    Text(t.id, style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Text(t.description, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
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
