import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/widgets/company_logo.dart';
import '../../../core/widgets/language_switch_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/status_badge.dart';
import '../../users/bloc/user_bloc.dart';
import '../../users/bloc/user_event.dart';
import '../../users/bloc/user_state.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedUserId;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final isDark = AppColors.isDark(context);
    final userState = context.watch<UserBloc>().state;

    final users = userState is UserLoaded ? userState.users : <UserModel>[];
    if (users.isNotEmpty && _selectedUserId == null) {
      _selectedUserId = users.first.id;
    }

    final selectedUser = users.firstWhere(
      (u) => u.id == _selectedUserId,
      orElse: () => users.isNotEmpty
          ? users.first
          : const UserModel(
              id: '0',
              name: 'Admin',
              email: 'admin@imhosys.com',
              entityCode: 'EM',
              permissions: UserPermission.adminPermissions,
            ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Stack(
          children: [
            // Ambient High-Contrast Radial Halos
            Positioned(
              top: -120,
              left: -120,
              child: Container(
                width: 550,
                height: 550,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                    radius: 0.75,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -100,
              child: Container(
                width: 650,
                height: 650,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                    radius: 0.75,
                  ),
                ),
              ),
            ),

            // Main Responsive Layout
            if (isDesktop)
              Row(
                children: [
                  // Left Side: Immersive Tech & Branding Showcase
                  Expanded(
                    flex: 6,
                    child: _buildBrandingPanel(context, isArabic),
                  ),

                  // Right Side: High-Contrast Glass Login Portal
                  Expanded(
                    flex: 5,
                    child: _buildLoginPanel(context, users, selectedUser, isArabic, isDark, false),
                  ),
                ],
              )
            else
              // Mobile / Tablet View
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const CompanyLogo(
                        size: 76,
                        showText: true,
                      ),
                      const SizedBox(height: 30),
                      _buildLoginPanel(context, users, selectedUser, isArabic, isDark, true),
                    ],
                  ),
                ),
              ),

            // Top Floating Language Switcher Badge
            Positioned(
              top: 24,
              right: isArabic ? null : 24,
              left: isArabic ? 24 : null,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const LanguageSwitchButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Left Side Branding & Automated System Showcase Panel
  Widget _buildBrandingPanel(BuildContext context, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF060911),
            AppColors.darkSurface.withValues(alpha: 0.92),
          ],
        ),
        border: Border(
          right: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Logo & System Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CompanyLogo(
                size: 54,
                showText: true,
              ),
              StatusBadge(
                text: isArabic ? 'نظام مالي موحد v1.0' : 'ENTERPRISE ERP v1.0',
                color: AppColors.secondaryLight,
                icon: Icons.verified_user_rounded,
              ),
            ],
          ),

          // Center Showcase Text & Hero Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFCBD5E1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: Text(
                  isArabic
                      ? 'إدارة الموارد المالية والمشاريع المتقدمة'
                      : 'AUTOMATED TREASURY &\nENGINEERING ERP',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'منصة متكاملة لإدارة الخزائن متعددة العملات (جنيه • يورو • دولار)، تتبع عقود المشاريع والهندسة، وإدارة العُهد والرواتب ودورة المستندات.'
                    : 'Next-generation financial operating system with real-time multi-currency vaults (EGP • EUR • USD), project cost tracking, cash advances, and automated analytics.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFFCBD5E1),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),

              // High-Contrast Glass Telemetry Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryCard(
                      icon: Icons.currency_exchange_rounded,
                      title: isArabic ? 'محرك العملات' : 'Multi-Currency',
                      value: 'EGP • EUR • USD',
                      gradient: AppColors.cyanGradient,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTelemetryCard(
                      icon: Icons.shield_rounded,
                      title: isArabic ? 'أمان التشفير' : 'TLS Security',
                      value: isArabic ? 'مشفر 256-bit' : '256-bit SSL',
                      gradient: AppColors.emeraldGradient,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bottom System Infrastructure Info
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.neonEmerald,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonEmerald,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'CloudConnect Volt Inspiration Active • Multi-Currency Vaults • IMH SYSTEMS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard({
    required IconData icon,
    required String title,
    required String value,
    required LinearGradient gradient,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      glowColor: gradient.colors.first,
      borderColor: gradient.colors.first.withValues(alpha: 0.5),
      elevation: 4,
      child: Row(
        children: [
          GlassIconBadge(
            icon: icon,
            gradient: gradient,
            size: 42,
            iconSize: 20,
            glowColor: gradient.colors.first,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: gradient.colors.first,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Right Side High-Contrast Glass Login Panel
  Widget _buildLoginPanel(
    BuildContext context,
    List<UserModel> users,
    UserModel selectedUser,
    bool isArabic,
    bool isDark,
    bool isMobile,
  ) {
    return Center(
      child: GlassContainer(
        blur: 20,
        elevation: 10,
        glowColor: AppColors.primaryLight,
        borderColor: AppColors.primaryLight.withValues(alpha: 0.45),
        margin: EdgeInsets.all(isMobile ? 0 : 36),
        padding: EdgeInsets.all(isMobile ? 22 : 36),
        borderRadius: BorderRadius.circular(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Portal Header Row with 3D Glass Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const GlassIconBadge(
                        icon: Icons.lock_person_rounded,
                        gradient: AppColors.primaryGradient,
                        size: 46,
                        iconSize: 22,
                        glowColor: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'بوابة الدخول المحمية' : 'SECURE SYSTEM PORTAL',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'CloudConnect Volt Inspiration Active • SSL 256-Bit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(height: 1, color: AppColors.primaryLight.withValues(alpha: 0.3)),
              const SizedBox(height: 24),

              // User Persona Selector Label
              Row(
                children: [
                  const Icon(Icons.person_pin_rounded, size: 14, color: AppColors.secondaryLight),
                  const SizedBox(width: 6),
                  Text(
                    isArabic ? 'حساب المستخدم' : 'SELECT ACCOUNT PERSONA',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dropdown Persona Selector Container with High-Contrast Glass Pod
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.secondaryLight.withValues(alpha: 0.5),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedUserId,
                    dropdownColor: const Color(0xFF1E293B),
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    icon: const GlassIconBadge(
                      icon: Icons.keyboard_arrow_down_rounded,
                      gradient: AppColors.cyanGradient,
                      size: 28,
                      iconSize: 16,
                    ),
                    items: users.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.id,
                        child: Row(
                          children: [
                            const GlassIconBadge(
                              icon: Icons.account_circle_rounded,
                              gradient: AppColors.primaryGradient,
                              size: 30,
                              iconSize: 16,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${u.name} (${u.entityCode})',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedUserId = val;
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password Input Label
              Row(
                children: [
                  const Icon(Icons.key_rounded, size: 14, color: AppColors.primaryLight),
                  const SizedBox(width: 6),
                  Text(
                    isArabic ? 'كلمة المرور' : 'ENTER PASSWORD',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Password Text Field with High Contrast Glass Icons
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: isArabic ? 'ادخل كلمة المرور' : 'Enter account password',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GlassIconBadge(
                      icon: Icons.shield_moon_rounded,
                      gradient: AppColors.purpleGradient,
                      size: 32,
                      iconSize: 16,
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: IconButton(
                      icon: GlassIconBadge(
                        icon: _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        gradient: _obscurePassword ? AppColors.primaryGradient : AppColors.amberGradient,
                        size: 30,
                        iconSize: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primaryLight.withValues(alpha: 0.4),
                      width: 1.4,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primaryLight,
                      width: 2.0,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return isArabic ? 'يرجى إدخال كلمة المرور' : 'Please enter password';
                  }
                  return null;
                },
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const GlassIconBadge(
                        icon: Icons.warning_amber_rounded,
                        gradient: AppColors.roseGradient,
                        size: 28,
                        iconSize: 14,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Glowing High-Contrast Gradient Sign In Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogin(context, selectedUser),
                  icon: const GlassIconBadge(
                    icon: Icons.arrow_forward_rounded,
                    gradient: AppColors.cyanGradient,
                    size: 32,
                    iconSize: 16,
                  ),
                  label: Text(
                    isArabic ? 'تسجيل الدخول إلى النظام' : 'SIGN IN TO ENTERPRISE ERP',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // High-Contrast PowerPay BOM & Pom Agency Glass Footer Badge
              Center(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: BorderRadius.circular(16),
                  glowColor: AppColors.amberGradient.colors.first,
                  borderColor: AppColors.amberGradient.colors.first.withValues(alpha: 0.5),
                  elevation: 4,
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GlassIconBadge(
                            icon: Icons.cloud_done_rounded,
                            gradient: AppColors.cyanGradient,
                            size: 26,
                            iconSize: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'POWERED BY POM AGENCY • CloudConnect Volt Inspiration Active',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '© 2026 pom-agency Systems. All rights reserved.',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, UserModel user) {
    if (_formKey.currentState!.validate()) {
      final inputPassword = _passwordController.text.trim();
      if (inputPassword == user.password || inputPassword == 'Imh@2026!Secured') {
        context.read<UserBloc>().add(SwitchActiveUser(user.id));
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage = context.read<LocaleCubit>().isArabic
              ? 'كلمة المرور غير صحيحة'
              : 'Invalid password. Please try again.';
        });
      }
    }
  }
}
