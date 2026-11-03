import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Production Cloud Domain Endpoint (Primary Default)
  static const String productionBaseUrl = 'https://app.psisvh.com/api/v1';
  static const String lanBaseUrl = 'http://192.168.9.34:8000/api/v1';
  static const String publicWanBaseUrl = 'http://136.228.158.203:8000/api/v1';
  static const String localBaseUrl = 'http://localhost:8000/api/v1';
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api/v1';

  // Strict Default: Login with Cloud (app.psisvh.com)
  static String baseUrl = productionBaseUrl;

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  // Authentication
  static String get login => '$baseUrl/auth/login';
  static String get me => '$baseUrl/auth/me';
  static String get users => '$baseUrl/auth/users';

  // Academics
  static String get preschoolStudents => '$baseUrl/academics/preschool/students';
  static String get preschoolDailyLog => '$baseUrl/academics/preschool/daily-log';
  static String get generalEdClasses => '$baseUrl/academics/general-ed/classes';
  static String classStudents(String classId) => '$baseUrl/academics/general-ed/classes/$classId/students';
  static String updateGrade(String recordId) => '$baseUrl/academics/general-ed/records/$recordId/update-grade';
  static String get partTimeShifts => '$baseUrl/academics/part-time-languages/shifts';

  // POS & Inventory
  static String get inventoryProducts => '$baseUrl/pos-inventory/products';
  static String get busRoutes => '$baseUrl/pos-inventory/bus-routes';
  static String get posCheckout => '$baseUrl/pos-inventory/checkout';
  static String get posInvoices => '$baseUrl/pos-inventory/invoices';

  // Procurement Workflow
  static String get procurementRequests => '$baseUrl/procurement/requests';
  static String headReview(String reqId) => '$baseUrl/procurement/requests/$reqId/head-review';
  static String accountingReview(String reqId) => '$baseUrl/procurement/requests/$reqId/accounting-review';

  // Payroll & Monthly Closing
  static String get timeLog => '$baseUrl/payroll/time-log';
  static String get timeLogsList => '$baseUrl/payroll/time-logs';
  static String get generatePayrollCycle => '$baseUrl/payroll/cycles/generate';
  static String get payrollCycles => '$baseUrl/payroll/cycles';
  static String cycleSlips(String cycleId) => '$baseUrl/payroll/cycles/$cycleId/slips';
  static String monthlyCloseLock(String cycleId) => '$baseUrl/payroll/cycles/$cycleId/monthly-close-lock';

  // Finance & GDT Reports
  static String get financialLedger => '$baseUrl/finance-reports/ledger';
  static String get annualSummary => '$baseUrl/finance-reports/annual-summary';
  static String get gdtTaxDeclaration => '$baseUrl/finance-reports/gdt-tax-declaration';

  // Attendance & Gate-Pass & Employee GPS
  static String get gatePassScan => '$baseUrl/attendance/gate-pass/scan';
  static String get gatePassLogs => '$baseUrl/attendance/gate-pass/logs';
  static String get employeeGpsStatus => '$baseUrl/attendance/employee/gps-status';
  static String get employeeGpsPunch => '$baseUrl/attendance/employee/gps-punch';
  static String get employeeGpsLogs => '$baseUrl/attendance/employee/gps-logs';

  // Parent Portal & Student Tracking
  static String get parentChildren => '$baseUrl/academics/parent/children';
  static String get parentStudentTracking => '$baseUrl/academics/parent/student-tracking';

  // Role-Based Dashboard
  static String get dashboardSummary => '$baseUrl/dashboard/summary';
}
