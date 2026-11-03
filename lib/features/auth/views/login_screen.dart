import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'director@psisvh.com');
  final _passwordController = TextEditingController(text: 'Password123!');
  bool _obscurePassword = true;
  bool _showHostSelector = false;
  int _logoTapCount = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF071426),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // School Crest Header (Secret 5-tap to toggle server settings)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _logoTapCount++;
                      if (_logoTapCount >= 5) {
                        setState(() {
                          _showHostSelector = !_showHostSelector;
                          _logoTapCount = 0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_showHostSelector ? '🔧 Server Host Settings Revealed' : 'Server Host Settings Hidden'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.accentGold, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'PSI',
                          style: TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PSI-VH SCHOOL SYSTEM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Preah Sihanouk International School\nEnterprise Management Portal',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                if (auth.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.lightRed,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.dangerRed.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.error_outline, color: AppColors.dangerRed, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(color: AppColors.dangerRed, fontSize: 11, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                        if (auth.errorMessage!.contains('Cannot connect') || auth.errorMessage!.contains('Connection')) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(Icons.refresh, size: 14, color: AppColors.primaryBlue),
                              label: const Text('Retry Connection', style: TextStyle(fontSize: 11, color: AppColors.primaryBlue)),
                              onPressed: () {
                                auth.login(_emailController.text, _passwordController.text);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Server Endpoint Selector Bar (Hidden by default - tap PSI logo 5 times to reveal)
                if (_showHostSelector)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_done, size: 16, color: AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('API Host (Cloud Domain Default)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              Text(
                                ApiEndpoints.baseUrl,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Switch API Server Endpoint',
                          icon: const Icon(Icons.swap_horiz, size: 18, color: AppColors.primaryBlue),
                          onSelected: (url) {
                            setState(() {
                              ApiEndpoints.setBaseUrl(url);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Switched API Endpoint to: $url')),
                            );
                          },
                          itemBuilder: (ctx) => const [
                            PopupMenuItem(
                              value: ApiEndpoints.productionBaseUrl,
                              child: Text('🚀 Cloud Domain: https://app.psisvh.com/api/v1 (Default)'),
                            ),
                            PopupMenuItem(
                              value: ApiEndpoints.lanBaseUrl,
                              child: Text('🏢 LAN IP: http://192.168.9.34:8000/api/v1'),
                            ),
                            PopupMenuItem(
                              value: ApiEndpoints.publicWanBaseUrl,
                              child: Text('🌐 Public WAN: http://136.228.158.203:8000/api/v1'),
                            ),
                            PopupMenuItem(
                              value: ApiEndpoints.localBaseUrl,
                              child: Text('💻 Localhost: http://localhost:8000/api/v1'),
                            ),
                            PopupMenuItem(
                              value: ApiEndpoints.androidEmulatorBaseUrl,
                              child: Text('📱 Android Emulator: http://10.0.2.2:8000/api/v1'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Email field
                const Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                    hintText: 'Enter registered school email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    hintText: 'Enter account password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign In Button
                ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => auth.login(_emailController.text, _passwordController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Sign In to PSI-VH System',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 24),

                // Quick Demo Login Pills
                const Center(
                  child: Text(
                    '--- ONE-CLICK DEMO ACCOUNTS ---',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _demoChip('Director', 'director@psisvh.com'),
                    _demoChip('Admin', 'admin@psisvh.com'),
                    _demoChip('Accountant', 'accountant@psisvh.com'),
                    _demoChip('Dept Head', 'head.academics@psisvh.com'),
                    _demoChip('FT Teacher', 'teacher.sok@psisvh.com'),
                    _demoChip('PT Teacher', 'teacher.chen@psisvh.com'),
                    _demoChip('Parent (Dara)', 'parent.dara@psisvh.com'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoChip(String label, String email) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.lightBlue,
      side: const BorderSide(color: Color(0xFFBFDBFE)),
      onPressed: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = 'Password123!';
        });
        Provider.of<AuthProvider>(context, listen: false).login(email, 'Password123!');
      },
    );
  }
}

