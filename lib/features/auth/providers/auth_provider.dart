import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _currentUser != null;

  String get currentRole => _currentUser?.role ?? 'GUEST';

  AuthProvider() {
    _loadStoredSession();
  }

  Future<void> _loadStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      if (savedToken != null) {
        _token = savedToken;
        ApiClient().setAuthToken(savedToken);
        await fetchCurrentUser();
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient().post(
        ApiEndpoints.login,
        data: {'email': email.trim(), 'password': password},
      );

      final data = response.data;
      _token = data['access_token'];
      ApiClient().setAuthToken(_token!);

      _currentUser = UserModel(
        id: data['user_id'],
        email: data['email'],
        fullName: data['full_name'],
        role: data['role'],
        employmentType: data['employment_type'] ?? 'FULL_TIME',
        departmentId: data['department_id'],
        baseSalaryUsd: 0.0,
        hourlyRateUsd: 12.0,
        numDependents: 0,
        isActive: true,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final err = e.toString();
      // If cloud or WAN failed, auto-try local LAN server (192.168.9.34:8000) or localhost
      if ((ApiEndpoints.baseUrl == ApiEndpoints.productionBaseUrl || ApiEndpoints.baseUrl == ApiEndpoints.publicWanBaseUrl) &&
          (err.contains('Connection') || err.contains('XMLHttpRequest') || err.contains('SocketException') || err.contains('Failed host lookup'))) {
        try {
          ApiEndpoints.setBaseUrl(ApiEndpoints.lanBaseUrl);
          final fallbackResponse = await ApiClient().post(
            ApiEndpoints.login,
            data: {'email': email.trim(), 'password': password},
          );
          final fbData = fallbackResponse.data;
          _token = fbData['access_token'];
          ApiClient().setAuthToken(_token!);
          _currentUser = UserModel(
            id: fbData['user_id'],
            email: fbData['email'],
            fullName: fbData['full_name'],
            role: fbData['role'],
            employmentType: fbData['employment_type'] ?? 'FULL_TIME',
            departmentId: fbData['department_id'],
            baseSalaryUsd: 0.0,
            hourlyRateUsd: 12.0,
            numDependents: 0,
            isActive: true,
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', _token!);
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (_) {
          // Revert back if both failed
          ApiEndpoints.setBaseUrl(ApiEndpoints.lanBaseUrl);
        }
      }

      _isLoading = false;
      if (err.contains('XMLHttpRequest') || err.contains('SocketException') || err.contains('Connection Failed') || err.contains('Connection refused')) {
        _errorMessage = 'Cannot connect to PSI-VH server at ${ApiEndpoints.baseUrl}.\n• Local LAN: verify 192.168.9.34:8000 and Windows Firewall\n• Public WAN: verify MikroTik port forward to 192.168.9.34:8000';
      } else {
        _errorMessage = err.replaceAll('Exception: ', '');
      }
      notifyListeners();
      return false;
    }
  }

  /// Quick Switch Role for instant multi-role demonstration
  Future<void> demoSwitchRole(String roleEmail) async {
    await login(roleEmail, 'Password123!');
  }

  Future<void> fetchCurrentUser() async {
    try {
      final response = await ApiClient().get(ApiEndpoints.me);
      _currentUser = UserModel.fromJson(response.data);
      notifyListeners();
    } catch (e) {
      logout();
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    ApiClient().clearAuthToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}

