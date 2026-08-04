import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/constants/app_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/localization/app_translations.dart';
import '../../transactions/bloc/transaction_bloc.dart';
import '../../transactions/bloc/transaction_state.dart';
import '../../users/bloc/user_bloc.dart';
import '../../users/bloc/user_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final isDark = AppColors.isDark(context);
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

          final activeUser = context.watch<UserBloc>().state is UserLoaded
              ? (context.watch<UserBloc>().state as UserLoaded).activeUser
              : null;
          final canViewVaults = activeUser?.permissions.canViewVaultBalances ?? false;

          final egpDisplay = canViewVaults ? CurrencyFormatter.format(totalEgp, Currency.EGP) : '•••••• (Restricted)';
          final eurDisplay = canViewVaults ? CurrencyFormatter.format(totalEur, Currency.EUR) : '•••••• (Restricted)';
          final usdDisplay = canViewVaults ? CurrencyFormatter.format(totalUsd, Currency.USD) : '•••••• (Restricted)';

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Cards Grid
                if (!isMobile)
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: AppTranslations.get('egpBalance', isArabic),
                          value: egpDisplay,
                          subtitle: isArabic ? 'الخزينة الرئيسية للتشغيل' : 'Primary Operating Treasury',
                          icon: Icons.account_balance_rounded,
                          accentColor: AppColors.egp,
                          iconGradient: AppColors.emeraldGradient,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          title: AppTranslations.get('eurBalance', isArabic),
                          value: eurDisplay,
                          subtitle: isArabic ? 'مشاريع سيمنس والواردات' : 'EU Imports & Siemens Projects',
                          icon: Icons.euro_rounded,
                          accentColor: AppColors.eur,
                          iconGradient: AppColors.cyanGradient,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          title: AppTranslations.get('usdBalance', isArabic),
                          value: usdDisplay,
                          subtitle: isArabic ? 'العقود الدولية والشحن' : 'International Contracts & Freight',
                          icon: Icons.monetization_on_rounded,
                          accentColor: AppColors.usd,
                          iconGradient: AppColors.amberGradient,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          title: AppTranslations.get('activeProjects', isArabic),
                          value: isArabic ? '7 مشاريع' : '7 Projects',
                          subtitle: isArabic ? 'سيمنس، السنغال، والمزيد' : 'Siemens UAE, FCB Senegal, etc.',
                          icon: Icons.engineering_rounded,
                          accentColor: AppColors.primary,
                          iconGradient: AppColors.purpleGradient,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      KpiCard(
                        title: AppTranslations.get('egpBalance', isArabic),
                        value: egpDisplay,
                        subtitle: isArabic ? 'الخزينة الرئيسية للتشغيل' : 'Primary Operating Treasury',
                        icon: Icons.account_balance_rounded,
                        accentColor: AppColors.egp,
                        iconGradient: AppColors.emeraldGradient,
                      ),
                      const SizedBox(height: 12),
                      KpiCard(
                        title: AppTranslations.get('eurBalance', isArabic),
                        value: eurDisplay,
                        subtitle: isArabic ? 'مشاريع سيمنس والواردات' : 'EU Imports & Siemens Projects',
                        icon: Icons.euro_rounded,
                        accentColor: AppColors.eur,
                        iconGradient: AppColors.cyanGradient,
                      ),
                      const SizedBox(height: 12),
                      KpiCard(
                        title: AppTranslations.get('usdBalance', isArabic),
                        value: usdDisplay,
                        subtitle: isArabic ? 'العقود الدولية والشحن' : 'International Contracts & Freight',
                        icon: Icons.monetization_on_rounded,
                        accentColor: AppColors.usd,
                        iconGradient: AppColors.amberGradient,
                      ),
                      const SizedBox(height: 12),
                      KpiCard(
                        title: AppTranslations.get('activeProjects', isArabic),
                        value: isArabic ? '7 مشاريع' : '7 Projects',
                        subtitle: isArabic ? 'سيمنس، السنغال، والمزيد' : 'Siemens UAE, FCB Senegal, etc.',
                        icon: Icons.engineering_rounded,
                        accentColor: AppColors.primary,
                        iconGradient: AppColors.purpleGradient,
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Visualizations Section (Frosted Glass Charts)
                if (!isMobile)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildPieChartCard(context, categoryEgpMap, isArabic),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 4,
                        child: _buildTopProjectsCard(context, top5Projects, isArabic),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildPieChartCard(context, categoryEgpMap, isArabic),
                      const SizedBox(height: 16),
                      _buildTopProjectsCard(context, top5Projects, isArabic),
                    ],
                  ),

                const SizedBox(height: 24),

                // Cash Outflow Trend Bar Chart (Glass Container)
                GlassContainer(
                  padding: const EdgeInsets.all(22),
                  glowColor: AppColors.primary,
                  borderColor: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const GlassIconBadge(
                                icon: Icons.trending_up_rounded,
                                gradient: AppColors.primaryGradient,
                                size: 36,
                                iconSize: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppTranslations.get('cashOutflowTrend', isArabic).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: AppColors.getTextPrimary(context),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              isArabic ? 'التحليل الشهري' : 'Monthly Outflow',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 240,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => isDark ? const Color(0xFF1E293B) : Colors.white,
                                tooltipBorder: BorderSide(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
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
                                          style: TextStyle(
                                            color: AppColors.getTextSecondary(context),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppColors.getDivider(context).withValues(alpha: 0.5),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _makeBarGroup(0, 180, AppColors.emeraldGradient),
                              _makeBarGroup(1, 240, AppColors.emeraldGradient),
                              _makeBarGroup(2, 310, AppColors.cyanGradient),
                              _makeBarGroup(3, 280, AppColors.amberGradient),
                              _makeBarGroup(4, 390, AppColors.purpleGradient),
                              _makeBarGroup(5, 450, AppColors.primaryGradient),
                              _makeBarGroup(6, 520, AppColors.emeraldGradient),
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

  Widget _buildPieChartCard(BuildContext context, Map<String, double> categoryEgpMap, bool isArabic) {
    final isDark = AppColors.isDark(context);

    return GlassContainer(
      padding: const EdgeInsets.all(22),
      glowColor: AppColors.secondary,
      borderColor: AppColors.secondary.withValues(alpha: isDark ? 0.35 : 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const GlassIconBadge(
                    icon: Icons.pie_chart_outline_rounded,
                    gradient: AppColors.cyanGradient,
                    size: 36,
                    iconSize: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppTranslations.get('expenseDist', isArabic).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
              StatusBadge(text: isArabic ? 'التصنيف' : 'Categories', color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 48,
                      sections: _generatePieSections(categoryEgpMap),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: categoryEgpMap.entries.take(6).map((entry) {
                      final categoryColor = _getCategoryColor(entry.key);
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: categoryColor.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppCategories.getLocalizedName(entry.key, isArabic),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.getTextPrimary(context),
                                ),
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

  Widget _buildTopProjectsCard(BuildContext context, List<MapEntry<String, double>> top5Projects, bool isArabic) {
    final isDark = AppColors.isDark(context);

    return GlassContainer(
      padding: const EdgeInsets.all(22),
      glowColor: AppColors.usd,
      borderColor: AppColors.usd.withValues(alpha: isDark ? 0.35 : 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const GlassIconBadge(
                    icon: Icons.leaderboard_rounded,
                    gradient: AppColors.amberGradient,
                    size: 36,
                    iconSize: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppTranslations.get('topProjects', isArabic).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
              StatusBadge(text: isArabic ? 'أعلى 5' : 'Top 5', color: AppColors.usd),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: top5Projects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final proj = top5Projects[idx];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceLight(context).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.getDivider(context).withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      GlassIconBadge(
                        icon: Icons.star_rounded,
                        gradient: idx == 0
                            ? AppColors.amberGradient
                            : (idx == 1 ? AppColors.cyanGradient : AppColors.primaryGradient),
                        size: 34,
                        iconSize: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              proj.key,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.getTextPrimary(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isArabic ? 'خدمات هندسية وأتمتة' : 'Automation & Engineering Services',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.getTextSecondary(context),
                              ),
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
                              fontWeight: FontWeight.w900,
                              color: AppColors.egp,
                            ),
                          ),
                          const SizedBox(height: 4),
                          StatusBadge(text: isArabic ? 'نشط' : 'Active', color: AppColors.success),
                        ],
                      ),
                    ],
                  ),
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
        radius: 44,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
      );
    }).toList();
  }

  Color _getCategoryColor(String name) {
    if (name.contains('Office') || name.contains('Rent')) return AppColors.officeOverhead;
    if (name.contains('Salaries') || name.contains('HR')) return AppColors.hrPayroll;
    if (name.contains('Flight') || name.contains('Visa') || name.contains('Hotel')) return AppColors.travelLogistics;
    return AppColors.commercialAdmin;
  }

  BarChartGroupData _makeBarGroup(int x, double y, LinearGradient gradient) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: gradient,
          width: 22,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        ),
      ],
    );
  }
}
