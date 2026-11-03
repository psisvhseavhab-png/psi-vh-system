import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_roles.dart';
import '../features/auth/providers/auth_provider.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final role = user?.role ?? 'SUPER_ADMIN';

    final isTeacher = role == 'TEACHER';
    final isParent = role == 'PARENT';
    final isStudent = role == 'STUDENT';
    final isStudentOrParent = isStudent || isParent;
    final isAccountant = role == 'ACCOUNTANT';
    final isAdminOrDirector = role == 'SUPER_ADMIN' || role == 'SCHOOL_DIRECTOR';
    final canAccessPos = isAdminOrDirector || isAccountant;

    return Container(
      width: 260,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          // 1. School Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accentGold, width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      'PSI',
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'PSI-VH SYSTEM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Preah Sihanouk Intl School',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Current User Profile Strip
          if (user != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2640),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E3A5F)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          AppRoles.getRoleLabelEn(user.role),
                          style: const TextStyle(color: AppColors.accentGold, fontSize: 9, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 3. Role-Tailored Navigation Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _navItem(
                  index: 0,
                  icon: isTeacher
                      ? Icons.school_outlined
                      : (isParent
                          ? Icons.family_restroom_outlined
                          : (isStudent ? Icons.account_circle_outlined : Icons.dashboard_outlined)),
                  activeIcon: isTeacher
                      ? Icons.school
                      : (isParent
                          ? Icons.family_restroom
                          : (isStudent ? Icons.account_circle : Icons.dashboard)),
                  title: isTeacher
                      ? 'Teacher Portal'
                      : (isParent
                          ? 'Parent Study Tracking'
                          : (isStudent ? 'Student Smart ID' : 'Dashboard Overview')),
                  titleKh: isTeacher
                      ? 'ផតថលលោកគ្រូ-អ្នកគ្រូ'
                      : (isParent
                          ? 'តាមដានការសិក្សាកូនៗ (Preschool & G10)'
                          : (isStudent ? 'កាតសិស្សឆ្លាតវៃ' : 'ផ្ទាំងគ្រប់គ្រងទូទៅ')),
                ),
                _navItem(
                  index: 1,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  title: isStudentOrParent ? 'Report Card & GPA' : 'Academics & Programs',
                  titleKh: isStudentOrParent ? 'ព្រឹត្តិបត្រពិន្ទុ & GPA' : 'កម្មវិធីសិក្សា (មតេយ្យ-G12-ភាសា)',
                ),
                // POS Terminal: Restricted strictly to Administration & Finance Cashiers (Hidden from Teachers/Students/Parents)
                if (canAccessPos)
                  _navItem(
                    index: 2,
                    icon: Icons.point_of_sale_outlined,
                    activeIcon: Icons.point_of_sale,
                    title: 'POS & School Services',
                    titleKh: 'ប្រព័ន្ធលក់ និងសេវាឡានក្រុង',
                  ),

                // Procurement: Hidden from students
                if (!isStudentOrParent)
                  _navItem(
                    index: 3,
                    icon: Icons.assignment_turned_in_outlined,
                    activeIcon: Icons.assignment_turned_in,
                    title: isTeacher ? 'Teaching Supply Requests' : 'Procurement Workflow',
                    titleKh: 'ស្នើសុំសម្ភារៈ (៣ ដំណាក់កាល)',
                  ),

                // Payroll: Hidden from students
                if (!isStudentOrParent)
                  _navItem(
                    index: 4,
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet,
                    title: isTeacher ? 'My Minutes & Pay Slip' : 'Payroll & Closing Cycle',
                    titleKh: isTeacher ? 'ម៉ោងធ្វើការ & ប័ណ្ណប្រាក់ខែ' : 'ប្រាក់ខែ និងបិទបញ្ជី (២៥-៣០)',
                  ),

                // Finance & GDT: Admin/Director/Accountant only
                if (!isTeacher && !isStudentOrParent)
                  _navItem(
                    index: 5,
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics,
                    title: 'Finance & GDT Tax',
                    titleKh: 'របាយការណ៍ហិរញ្ញវត្ថុ & ពន្ធដារ',
                  ),

                _navItem(
                  index: 6,
                  icon: Icons.qr_code_scanner,
                  activeIcon: Icons.qr_code_scanner,
                  title: isStudentOrParent ? 'Gate-Pass Entry Log' : 'Attendance & Gate-Pass',
                  titleKh: 'វត្តមាន និងស្កេនទ្វារចេញចូល',
                ),
                _navItem(
                  index: 7,
                  icon: Icons.print_outlined,
                  activeIcon: Icons.print,
                  title: isStudentOrParent ? 'Download ID & Certs' : 'Documents & Printing',
                  titleKh: 'បោះពុម្ពវិក្កយបត្រ & កាតសិស្ស',
                ),
              ],
            ),
          ),

          // 4. Quick Demo Role Switcher
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ROLE SWITCHER (DEMO)',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF112A45),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: const Color(0xFF112A45),
                      value: (user?.email != null && user!.email.isNotEmpty)
                          ? user.email.replaceFirst('@psivh.edu.kh', '@psisvh.com')
                          : 'director@psisvh.com',
                      icon: const Icon(Icons.swap_horiz, color: AppColors.accentGold, size: 16),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      items: const [
                        DropdownMenuItem(
                          value: 'director@psisvh.com',
                          child: Text('School Director'),
                        ),
                        DropdownMenuItem(
                          value: 'admin@psisvh.com',
                          child: Text('Super Admin'),
                        ),
                        DropdownMenuItem(
                          value: 'accountant@psisvh.com',
                          child: Text('Chief Accountant'),
                        ),
                        DropdownMenuItem(
                          value: 'head.academics@psisvh.com',
                          child: Text('Department Head'),
                        ),
                        DropdownMenuItem(
                          value: 'teacher.sok@psisvh.com',
                          child: Text('Full-time Teacher (G10)'),
                        ),
                        DropdownMenuItem(
                          value: 'teacher.chen@psisvh.com',
                          child: Text('Part-time Teacher (Minute Wage)'),
                        ),
                        DropdownMenuItem(
                          value: 'parent.dara@psisvh.com',
                          child: Text('Parent (Dara & Bopha)'),
                        ),
                      ],
                      onChanged: (email) {
                        if (email != null) {
                          auth.demoSwitchRole(email);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => auth.logout(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, size: 14, color: AppColors.dangerRed),
                      SizedBox(width: 6),
                      Text('Sign Out', style: TextStyle(color: AppColors.dangerRed, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String titleKh,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.sidebarItemActive : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      Text(
                        titleKh,
                        style: TextStyle(
                          color: isSelected ? AppColors.accentGold : AppColors.textMuted,
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.accentGold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
