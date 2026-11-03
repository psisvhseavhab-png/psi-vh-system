import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/views/login_screen.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/responsive_layout.dart';

import 'features/dashboard/views/admin_dashboard_view.dart';
import 'features/dashboard/views/teacher_portal_view.dart';
import 'features/dashboard/views/student_portal_view.dart';
import 'features/dashboard/views/parent_portal_view.dart';
import 'features/academics/views/academics_screen.dart';
import 'features/pos_inventory/views/pos_terminal_view.dart';
import 'features/procurement/views/procurement_workflow_view.dart';
import 'features/payroll/views/payroll_closing_view.dart';
import 'features/finance_reports/views/finance_reports_view.dart';
import 'features/attendance/views/attendance_gatepass_view.dart';
import 'features/documents/views/document_print_center_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PsiVhSchoolApp());
}

class PsiVhSchoolApp extends StatelessWidget {
  const PsiVhSchoolApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'PSI-VH Enterprise School System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryNavy,
          scaffoldBackgroundColor: AppColors.backgroundLight,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryNavy,
            primary: AppColors.primaryNavy,
            secondary: AppColors.accentGold,
          ),
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AppRootGate(),
      ),
    );
  }
}

class AppRootGate extends StatelessWidget {
  const AppRootGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    return const MainEnterpriseScaffold();
  }
}

class MainEnterpriseScaffold extends StatefulWidget {
  const MainEnterpriseScaffold({Key? key}) : super(key: key);

  @override
  State<MainEnterpriseScaffold> createState() => _MainEnterpriseScaffoldState();
}

class _MainEnterpriseScaffoldState extends State<MainEnterpriseScaffold> {
  int _selectedIndex = 0;
  bool _isKhmerLanguage = false;

  void _onNavigationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody(String role) {
    final canAccessPos = role == 'SUPER_ADMIN' || role == 'SCHOOL_DIRECTOR' || role == 'ACCOUNTANT';
    final canAccessFinance = role == 'SUPER_ADMIN' || role == 'SCHOOL_DIRECTOR' || role == 'ACCOUNTANT';

    switch (_selectedIndex) {
      case 0:
        if (role == 'TEACHER') {
          return TeacherPortalView(onNavigate: _onNavigationSelected);
        } else if (role == 'PARENT') {
          return ParentPortalView(onNavigate: _onNavigationSelected);
        } else if (role == 'STUDENT') {
          return StudentPortalView(onNavigate: _onNavigationSelected);
        } else {
          return AdminDashboardView(onNavigate: _onNavigationSelected);
        }
      case 1:
        return const AcademicsScreen();
      case 2:
        if (!canAccessPos) {
          if (role == 'TEACHER') return TeacherPortalView(onNavigate: _onNavigationSelected);
          if (role == 'PARENT') return ParentPortalView(onNavigate: _onNavigationSelected);
          if (role == 'STUDENT') return StudentPortalView(onNavigate: _onNavigationSelected);
          return AdminDashboardView(onNavigate: _onNavigationSelected);
        }
        return const PosTerminalView();
      case 3:
        return const ProcurementWorkflowView();
      case 4:
        return const PayrollClosingView();
      case 5:
        if (!canAccessFinance) {
          return AdminDashboardView(onNavigate: _onNavigationSelected);
        }
        return const FinanceReportsView();
      case 6:
        return const AttendanceGatepassView();
      case 7:
        return const DocumentPrintCenterView();
      default:
        return AdminDashboardView(onNavigate: _onNavigationSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userRole = auth.currentRole;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'PSI-VH',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _isKhmerLanguage
                  ? 'ប្រព័ន្ធគ្រប់គ្រងសាលាអន្តរជាតិ ព្រះសីហនុ'
                  : 'Preah Sihanouk International School (PSI-VH)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Language Switcher Toggle
          TextButton.icon(
            onPressed: () {
              setState(() => _isKhmerLanguage = !_isKhmerLanguage);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isKhmerLanguage ? 'បានប្តូរទៅភាសាខ្មែរ (Khmer Language)' : 'Switched to English')),
              );
            },
            icon: const Icon(Icons.language, color: Colors.white, size: 16),
            label: Text(
              _isKhmerLanguage ? 'ភាសាខ្មែរ (KH)' : 'English (EN)',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),

          // Active Role Indicator Pill
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  userRole == 'TEACHER'
                      ? Icons.school
                      : (userRole == 'STUDENT' ? Icons.person : Icons.admin_panel_settings),
                  size: 14,
                  color: AppColors.accentGold,
                ),
                const SizedBox(width: 6),
                Text(
                  userRole,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: AppSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  Navigator.pop(context); // Close drawer
                  _onNavigationSelected(index);
                },
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            AppSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onNavigationSelected,
            ),
          Expanded(child: _buildBody(userRole)),
        ],
      ),
    );
  }
}
