import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/localization/locale_cubit.dart';
import 'core/widgets/custom_sidebar.dart';
import 'core/widgets/header_bar.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/transactions/bloc/transaction_bloc.dart';
import 'features/transactions/bloc/transaction_event.dart';
import 'features/users/bloc/user_bloc.dart';
import 'features/users/bloc/user_event.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/transactions/presentation/ledger_screen.dart';
import 'features/projects/presentation/projects_screen.dart';
import 'features/accounts/presentation/accounts_screen.dart';
import 'features/excel_tool/presentation/excel_import_export_screen.dart';
import 'features/users/presentation/users_screen.dart';
import 'features/transactions/presentation/widgets/transaction_dialog.dart';
import 'core/services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.initialize();
  runApp(const ImhErpApp());
}

class ImhErpApp extends StatelessWidget {
  const ImhErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocaleCubit()),
        BlocProvider(create: (context) => UserBloc()..add(LoadUsers())),
        BlocProvider(create: (context) => TransactionBloc()..add(LoadTransactions())),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'IMHOSYS - Enterprise ERP & Ledger',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const RootAuthWrapper(),
          );
        },
      ),
    );
  }
}

class RootAuthWrapper extends StatefulWidget {
  const RootAuthWrapper({super.key});

  @override
  State<RootAuthWrapper> createState() => _RootAuthWrapperState();
}

class _RootAuthWrapperState extends State<RootAuthWrapper> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: () {
          setState(() {
            _isLoggedIn = true;
          });
        },
      );
    }

    return MainShellScreen(
      onLogout: () {
        setState(() {
          _isLoggedIn = false;
        });
      },
    );
  }
}

class MainShellScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const MainShellScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentNavIndex = 0;

  final List<String> _pageTitleKeys = [
    'dashHeader',
    'ledgerHeader',
    'projectsHeader',
    'accountsHeader',
    'excelHeader',
    'usersHeader',
    'reportsHeader',
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        drawer: isMobile
            ? Drawer(
                backgroundColor: AppColors.surface,
                child: CustomSidebar(
                  selectedIndex: _currentNavIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _currentNavIndex = index;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              )
            : null,
        bottomNavigationBar: isMobile
            ? Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentNavIndex > 5 ? 0 : _currentNavIndex,
                  onTap: (index) {
                    setState(() {
                      _currentNavIndex = index;
                    });
                  },
                  backgroundColor: AppColors.surface,
                  selectedItemColor: AppColors.primaryLight,
                  unselectedItemColor: AppColors.textSecondary,
                  type: BottomNavigationBarType.fixed,
                  selectedFontSize: 11,
                  unselectedFontSize: 10,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.dashboard_rounded),
                      label: isArabic ? 'الرئيسية' : 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.table_rows_rounded),
                      label: isArabic ? 'السجل' : 'Ledger',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.engineering_rounded),
                      label: isArabic ? 'المشاريع' : 'Projects',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.account_balance_wallet_rounded),
                      label: isArabic ? 'الخزينة' : 'Accounts',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.file_present_rounded),
                      label: isArabic ? 'إكسيل' : 'Excel',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.admin_panel_settings_rounded),
                      label: isArabic ? 'الأدوار' : 'Users',
                    ),
                  ],
                ),
              )
            : null,
        body: Row(
          children: [
            // Persistent Desktop Navigation Sidebar
            if (!isMobile)
              CustomSidebar(
                selectedIndex: _currentNavIndex,
                onItemSelected: (index) {
                  setState(() {
                    _currentNavIndex = index;
                  });
                },
              ),

            // Main Screen Content Body
            Expanded(
              child: Column(
                children: [
                  // Top Header Bar
                  Builder(
                    builder: (headerCtx) => HeaderBar(
                      titleKey: _pageTitleKeys[_currentNavIndex],
                      isMobile: isMobile,
                      onOpenDrawer: isMobile ? () => Scaffold.of(headerCtx).openDrawer() : null,
                      onSearch: (query) {
                        context.read<TransactionBloc>().add(SearchTransactions(query));
                      },
                      onAddTransaction: () => _openNewTransactionDialog(context),
                      onImportExcel: () {
                        setState(() {
                          _currentNavIndex = 4; // Switch to Excel Tool Tab
                        });
                      },
                      onLogout: widget.onLogout,
                    ),
                  ),

                  // Active Tab Body View
                  Expanded(
                    child: IndexedStack(
                      index: _currentNavIndex,
                      children: const [
                        DashboardScreen(),
                        LedgerScreen(),
                        ProjectsScreen(),
                        AccountsScreen(),
                        ExcelImportExportScreen(),
                        UsersScreen(),
                        LedgerScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openNewTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => TransactionDialog(
        onSave: (newTransaction) {
          context.read<TransactionBloc>().add(AddTransaction(newTransaction));
        },
      ),
    );
  }
}
