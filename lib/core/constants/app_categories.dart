import 'package:flutter/material.dart';
import 'app_colors.dart';

class CategoryItem {
  final String group;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.group,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class AppCategories {
  static const String officeOverhead = 'Office & Overhead';
  static const String hrPayroll = 'HR & Payroll';
  static const String travelLogistics = 'Travel & Logistics';
  static const String commercialAdmin = 'Commercial & Admin';

  static const List<String> groups = [
    officeOverhead,
    hrPayroll,
    travelLogistics,
    commercialAdmin,
  ];

  static const List<CategoryItem> items = [
    // Office & Overhead
    CategoryItem(group: officeOverhead, name: 'Office Rent', icon: Icons.location_city, color: AppColors.officeOverhead),
    CategoryItem(group: officeOverhead, name: 'Cleaning & Maintenance', icon: Icons.cleaning_services, color: AppColors.officeOverhead),
    CategoryItem(group: officeOverhead, name: 'Kitchen Supplies', icon: Icons.kitchen, color: AppColors.officeOverhead),
    CategoryItem(group: officeOverhead, name: 'Utilities (Electric/Water/Gas)', icon: Icons.bolt, color: AppColors.officeOverhead),
    CategoryItem(group: officeOverhead, name: 'Internet & Telecom', icon: Icons.wifi, color: AppColors.officeOverhead),
    CategoryItem(group: officeOverhead, name: 'Web & Email Services', icon: Icons.web, color: AppColors.officeOverhead),
    CategoryItem(group: officeOverhead, name: 'Stationary & Office Supplies', icon: Icons.edit_note, color: AppColors.officeOverhead),
    CategoryItem(group: officeOverhead, name: 'Workshop Expenses', icon: Icons.build, color: AppColors.officeOverhead),

    // HR & Payroll
    CategoryItem(group: hrPayroll, name: 'Salaries & Wages', icon: Icons.payments, color: AppColors.hrPayroll),
    CategoryItem(group: hrPayroll, name: 'Social & Health Insurance', icon: Icons.security, color: AppColors.hrPayroll),
    CategoryItem(group: hrPayroll, name: 'Employee Benefits', icon: Icons.card_giftcard, color: AppColors.hrPayroll),
    CategoryItem(group: hrPayroll, name: 'Daily & Site Allowances', icon: Icons.monetization_on, color: AppColors.hrPayroll),

    // Travel & Logistics
    CategoryItem(group: travelLogistics, name: 'Flights & Air Tickets', icon: Icons.flight_takeoff, color: AppColors.travelLogistics),
    CategoryItem(group: travelLogistics, name: 'Visas & Travel Docs', icon: Icons.assignment_ind, color: AppColors.travelLogistics),
    CategoryItem(group: travelLogistics, name: 'Hotel & Accommodation', icon: Icons.hotel, color: AppColors.travelLogistics),
    CategoryItem(group: travelLogistics, name: 'Site Transportation & Fuel', icon: Icons.directions_car, color: AppColors.travelLogistics),
    CategoryItem(group: travelLogistics, name: 'Material & Freight Shipping', icon: Icons.local_shipping, color: AppColors.travelLogistics),

    // Commercial & Admin
    CategoryItem(group: commercialAdmin, name: 'Client Gifts & Hospitality', icon: Icons.card_membership, color: AppColors.commercialAdmin),
    CategoryItem(group: commercialAdmin, name: 'Surveys & Engineering Audits', icon: Icons.analytics, color: AppColors.commercialAdmin),
    CategoryItem(group: commercialAdmin, name: 'Client Dinners & Meetings', icon: Icons.restaurant, color: AppColors.commercialAdmin),
    CategoryItem(group: commercialAdmin, name: 'Marketing, Posters & Cards', icon: Icons.campaign, color: AppColors.commercialAdmin),
    CategoryItem(group: commercialAdmin, name: 'Bank & Monthly Fees', icon: Icons.account_balance_wallet, color: AppColors.commercialAdmin),
    CategoryItem(group: commercialAdmin, name: 'Sales Commissions', icon: Icons.point_of_sale, color: AppColors.commercialAdmin),
  ];

  static const Map<String, String> _arabicNames = {
    'Office & Overhead': 'إيجار والمصاريف العمومية',
    'HR & Payroll': 'الموارد البشرية والمرتبات',
    'Travel & Logistics': 'السفر والخدمات اللوجستية',
    'Commercial & Admin': 'التجارية والإدارية',
    'Office Rent': 'إيجار المكتب',
    'Cleaning & Maintenance': 'النظافة والصيانة',
    'Kitchen Supplies': 'مستلزمات البوفيه والمطبخ',
    'Utilities (Electric/Water/Gas)': 'المرافق (كهرباء/مياه/غاز)',
    'Internet & Telecom': 'الإنترنت والاتصالات',
    'Web & Email Services': 'خدمات الويب والبريد',
    'Stationary & Office Supplies': 'الأدوات المكتبية والطباعة',
    'Workshop Expenses': 'مصروفات الورشة',
    'Salaries & Wages': 'المرتبات والأجور',
    'Social & Health Insurance': 'التأمينات الاجتماعية والصحية',
    'Employee Benefits': 'مزايـا الموظفين',
    'Daily & Site Allowances': 'بدلات السفر والموقع اليومية',
    'Flights & Air Tickets': 'تذاكر الطيران',
    'Visas & Travel Docs': 'التأشيرات ووثائق السفر',
    'Hotel & Accommodation': 'الفنادق والإقامة',
    'Site Transportation & Fuel': 'انتقالات الموقع والوقود',
    'Material & Freight Shipping': 'شحن البضائع والمعدات',
    'Client Gifts & Hospitality': 'هدايا العملاء والضيافة',
    'Surveys & Engineering Audits': 'المعاينات والتدقيق الهندسي',
    'Client Dinners & Meetings': 'اجتماعات وعزائم العملاء',
    'Marketing, Posters & Cards': 'التسويق والمطبوعات',
    'Bank & Monthly Fees': 'الرسوم والعمولات البنكية',
    'Sales Commissions': 'عمولات المبيعات',
  };

  static String getLocalizedName(String name, bool isArabic) {
    if (!isArabic) return name;
    return _arabicNames[name] ?? name;
  }

  static List<String> getAllSubcategories() {
    return items.map((e) => e.name).toList();
  }

  static Color getColorForCategory(String subcategory) {
    final found = items.firstWhere(
      (element) => element.name.toLowerCase() == subcategory.toLowerCase(),
      orElse: () => const CategoryItem(group: 'General', name: 'General', icon: Icons.category, color: AppColors.primary),
    );
    return found.color;
  }
}
