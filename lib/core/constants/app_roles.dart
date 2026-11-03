class AppRoles {
  static const String superAdmin = 'SUPER_ADMIN';
  static const String schoolDirector = 'SCHOOL_DIRECTOR';
  static const String accountant = 'ACCOUNTANT';
  static const String departmentHead = 'DEPARTMENT_HEAD';
  static const String teacher = 'TEACHER';
  static const String student = 'STUDENT';
  static const String parent = 'PARENT';

  static String getRoleLabelEn(String role) {
    switch (role) {
      case superAdmin:
        return 'System Administrator';
      case schoolDirector:
        return 'School Director';
      case accountant:
        return 'Chief Accountant';
      case departmentHead:
        return 'Department Head';
      case teacher:
        return 'Educator / Teacher';
      case student:
        return 'Enrolled Student';
      case parent:
        return 'Parent / Guardian';
      default:
        return role;
    }
  }

  static String getRoleLabelKh(String role) {
    switch (role) {
      case superAdmin:
        return 'អ្នកគ្រប់គ្រងប្រព័ន្ធ';
      case schoolDirector:
        return 'នាយកសាលា';
      case accountant:
        return 'ប្រធានគណនេយ្យ';
      case departmentHead:
        return 'ប្រធានដេប៉ាតឺម៉ង់';
      case teacher:
        return 'លោកគ្រូ/អ្នកគ្រូ';
      case student:
        return 'សិស្សានុសិស្ស';
      case parent:
        return 'មាតាបិតាសិស្ស';
      default:
        return role;
    }
  }
}

