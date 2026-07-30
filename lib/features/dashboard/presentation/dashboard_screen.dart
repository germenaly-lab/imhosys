import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/constants/app_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/localization/app_translations.dart';
import '../../transactions/bloc/transaction_bloc.dart';
import '../../transactions/bloc/transaction_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is TransactionLoaded) {
          final transactions = state.allTransactions;

          // Totals
          final totalEgp = transactions.fold(0.0, (sum, item) => sum + item.amountEgp);
          final totalEur = transactions.fold(0.0, (sum, item) => sum + item.amountEur);
          final totalUsd = transactions.fold(0.0, (sum, item) => sum + item.amountUsd);

          // Expense Categories Map
          final Map<String, double> categoryEgpMap = {};
          for (var t in transactions) {
            categoryEgpMap[t.category] = (categoryEgpMap[t.category] ?? 0.0) + t.totalInEgp();
          }

          // Top 5 Projects Map
          final Map<String, double> projectEgpMap = {};
          for (var t in transactions) {
            projectEgpMap[t.projectTag] = (projectEgpMap[t.projectTag] ?? 0.0) + t.totalInEgp();
          }
          final sortedProjects = projectEgpMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final top5Projects = sortedProjects.take(5).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Cards Grid (Desktop Row or Mobile Column/Wrap)
                if (!isMobile)
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: AppTranslations.get('egpBalance', isArabic),
                          value: CurrencyFormatter.format(totalEgp, Currency.EGP),
                          subtitle: isArabic ? 'الخزينة الرئيسية للتشغيل' : 'Primary Operating Treasury',
                          icon: Icons.account_balance,
                          accentColor: AppColors.egp,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          title: AppTranslations.get('eurBalance', isArabic),
                          value: CurrencyFormatter.format(totalEur, Currency.EUR),
                          subtitle: isArabic ? 'مشاريع سيمنس والواردات' : 'EU Imports & Siemens Projects',
                          icon: Icons.euro_rounded,
                          accentColor: AppColors.eur,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          title: AppTranslations.get('usdBalance', isArabic),
                          value: CurrencyFormatter.format(totalUsd, Currency.USD),
                          subtitle: isArabic ? 'العقود الدولية والشحن' : 'International Contracts & Freight',
                          icon: Icons.monetization_on_rounded,
                          accentColor: AppColors.usd,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          title: AppTranslations.get('activeProjects', isArabic),
                          value: isArabic ? '7 مشاريع' : '7 Projects',
                          subtitle: isArabic ? 'سيمنس، السنغال، والمزيد' : 'Siemens UAE, FCB Senegal, etc.',
                          icon: Icons.engineering_rounded,
                          accentColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      KpiCard(
                        title: AppTranslations.get('egpBalance', isArabic),
                        value: CurrencyFormatter.format(totalEgp, Currency.EGP),
                        subtitle: isArabic ? 'الخزينة الرئيسية للتشغيل' : 'Primary Operating Treasury',
                        icon: Icons.account_balance,
                        accentColor: AppColors.egp,
                      ),
                      const SizedBox(height: 12),
                      KpiCard(
                        title: AppTranslations.get('eurBalance', isArabic),
                        value: CurrencyFormatter.format(totalEur, Currency.EUR),
                        subtitle: isArabic ? 'مشاريع سيمنس والواردات' : 'EU Imports & Siemens Projects',
                        icon: Icons.euro_rounded,
                        accentColor: AppColors.eur,
                      ),
                      const SizedBox(height: 12),
                      KpiCard(
                        title: AppTranslations.get('usdBalance', isArabic),
                        value: CurrencyFormatter.format(totalUsd, Currency.USD),
                        subtitle: isArabic ? 'العقود الدولية والشحن' : 'International Contracts & Freight',
                        icon: Icons.monetization_on_rounded,
                        accentColor: AppColors.usd,
                      ),
                      const SizedBox(height: 12),
                      KpiCard(
                        title: AppTranslations.get('activeProjects', isArabic),
                        value: isArabic ? '7 مشاريع' : '7 Projects',
                        subtitle: isArabic ? 'سيمنس، السنغال، والمزيد' : 'Siemens UAE, FCB Senegal, etc.',
                        icon: Icons.engineering_rounded,
                        accentColor: AppColors.secondary,
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Visualizations Section (Charts)
                if (!isMobile)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pie Chart - Expense Breakdown by Category
                      Expanded(
                        flex: 5,
                        child: _buildPieChartCard(categoryEgpMap, isArabic),
                      ),
                      const SizedBox(width: 20),
                      // Top 5 Most Expensive Engineering Projects
                      Expanded(
                        flex: 4,
                        child: _buildTopProjectsCard(top5Projects, isArabic),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildPieChartCard(categoryEgpMap, isArabic),
                      const SizedBox(height: 16),
                      _buildTopProjectsCard(top5Projects, isArabic),
                    ],
                  ),

                const SizedBox(height: 24),

                // Cash Outflow Trend Bar Chart
                Container(
                  height: 280,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.get('cashOutflowTrend', isArabic),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: const BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    final months = isArabic
                                        ? ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو']
                                        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
                                    final index = val.toInt();
                                    if (index >= 0 && index < months.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          months[index],
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.divider, strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _makeBarGroup(0, 180, AppColors.egp),
                              _makeBarGroup(1, 240, AppColors.egp),
                              _makeBarGroup(2, 310, AppColors.eur),
                              _makeBarGroup(3, 280, AppColors.usd),
                              _makeBarGroup(4, 390, AppColors.primary),
                              _makeBarGroup(5, 450, AppColors.secondary),
                              _makeBarGroup(6, 520, AppColors.egp),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPieChartCard(Map<String, double> categoryEgpMap, bool isArabic) {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.get('expenseDist', isArabic),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(Icons.pie_chart_outline_rounded, color: AppColors.secondary, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 50,
                      sections: _generatePieSections(categoryEgpMap),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ListView(
                    children: categoryEgpMap.entries.take(6).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppCategories.getLocalizedName(entry.key, isArabic),
                                style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProjectsCard(List<MapEntry<String, double>> top5Projects, bool isArabic) {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.get('topProjects', isArabic),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(Icons.leaderboard_rounded, color: AppColors.usd, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: top5Projects.length,
              separatorBuilder: (_, _) => const Divider(color: AppColors.divider, height: 16),
              itemBuilder: (context, idx) {
                final proj = top5Projects[idx];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${idx + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proj.key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isArabic ? 'خدمات هندسية وأتمتة' : 'Automation & Engineering Services',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(proj.value, Currency.EGP),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.egp,
                          ),
                        ),
                        const SizedBox(height: 2),
                        StatusBadge(text: isArabic ? 'نشط' : 'Active', color: AppColors.success),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, double> categoryEgpMap) {
    final total = categoryEgpMap.values.fold(0.0, (s, v) => s + v);
    if (total == 0) return [];

    final colors = [
      AppColors.officeOverhead,
      AppColors.hrPayroll,
      AppColors.travelLogistics,
      AppColors.commercialAdmin,
      AppColors.primary,
      AppColors.secondary,
    ];

    int i = 0;
    return categoryEgpMap.entries.take(6).map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getCategoryColor(String name) {
    if (name.contains('Office') || name.contains('Rent')) return AppColors.officeOverhead;
    if (name.contains('Salaries') || name.contains('HR')) return AppColors.hrPayroll;
    if (name.contains('Flight') || name.contains('Visa') || name.contains('Hotel')) return AppColors.travelLogistics;
    return AppColors.commercialAdmin;
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
      ],
    );
  }
}
