import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/widgets/auth_text_field.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_cal/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = true;
  String? _selectedGender;
  String? _passwordError;

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() => _passwordError = null);
      return;
    }
    
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = value.contains(RegExp(r'[!@#\$%\^&\*]'));
    bool hasMinLength = value.length >= 8;
    
    List<String> missing = [];
    if (!hasMinLength) missing.add('at least 8 characters');
    if (!hasUppercase) missing.add('1 uppercase');
    if (!hasLowercase) missing.add('1 lowercase');
    if (!hasDigits) missing.add('1 number');
    if (!hasSpecialCharacters) missing.add('1 special character (!@#\$%^&*)');

    if (missing.isEmpty) {
      setState(() => _passwordError = null);
    } else {
      String errorText = 'Requires ';
      if (missing.length == 1) {
        errorText += missing.first;
      } else if (missing.length == 2) {
        errorText += '${missing[0]} and ${missing[1]}';
      } else {
        errorText += missing.sublist(0, missing.length - 1).join(', ') + ', and ' + missing.last;
      }
      setState(() => _passwordError = errorText);
    }
  }

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _showTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _showPrivacy;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeService.cardColor,
        title: Text('Terms & Conditions', style: TextStyle(color: ThemeService.textColor, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              '''Welcome to Fuel Calculator!

1. Acceptance of Terms
By creating an account and using the Fuel Calculator app, you agree to comply with and be bound by these Terms & Conditions. If you do not agree to these terms, please do not use the app.

2. Description of Service
Fuel Calculator provides tools for tracking vehicle mileage, logging fuel expenses, and setting maintenance reminders. All calculations and statistics are estimates based on user-provided data. The Service Provider (Emishper Raj) does not guarantee the absolute accuracy of these estimates.

3. In-App Purchases & Subscriptions
Certain premium features are available via in-app purchases. Payments are processed securely through the Google Play Store and managed by RevenueCat.

4. Advertisements
The free version of the Application displays banner advertisements provided by Google AdMob. By using the free version, you agree to the display of these ads.

5. User Accounts
You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account. We reserve the right to terminate accounts that violate our policies.

6. Limitation of Liability
Fuel Calculator and its Service Provider shall not be liable for any indirect, incidental, or consequential damages resulting from the use or inability to use the app, including any loss of data. Use the service "AS IS".

7. Contact Us
If you have any questions about these Terms, please contact us at fuelfox@fadowtech.com.''',
              style: TextStyle(color: ThemeService.textColor, fontSize: 13, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Color(0xFFDE2425)))),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeService.cardColor,
        title: Text('Privacy Policy', style: TextStyle(color: ThemeService.textColor, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              '''This privacy policy applies to the Fuel Calculator app (hereby referred to as "Application") for mobile devices that was created by Emishper Raj (hereby referred to as "Service Provider") as a Free and Premium service. This service is intended for use "AS IS".

Information Collection, Data Storage, and Use
The Application collects information when you download and use it. For a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information (such as your name, email address, and vehicle details). This information is transmitted via a secure API and safely stored in the Service Provider's own database. The information that the Service Provider requests will be retained by them and used as described in this privacy policy.

Third-Party Access
Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Application utilizes third-party services that have their own Privacy Policy about handling data, including:
• Google Play Services
• Google AdMob
• RevenueCat

Opt-Out Rights & Data Retention
You can stop all collection of information by the Application easily by uninstalling it. The Service Provider will retain User Provided data for as long as you use the Application. If you'd like them to delete User Provided Data, please contact them at fuelfox@fadowtech.com.

Contact Us
If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at fuelfox@fadowtech.com.''',
              style: TextStyle(color: ThemeService.textColor, fontSize: 13, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Color(0xFFDE2425)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeService.isDarkMode;
    final Color bgColor = isDark ? const Color(0xFF121217) : const Color(0xFFF9FAFB);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color redAccent = const Color(0xFFDE2425);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header
            ClipPath(
              clipper: HeaderCurveClipper(),
              child: Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    // Right-aligned Gas Pump Image
                    Positioned(
                      right: -30,
                      top: 40,
                      child: Image.asset(
                        'assets/images/gas_pump.png',
                        width: 180,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(width: 180, height: 200),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icon/app_icon.png',
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.local_fire_department, color: Colors.red, size: 32),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Fuelvox',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Create your account',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: ThemeService.mutedColor,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: 'Join us and make\nevery journey '),
                                  TextSpan(
                                    text: 'easier.',
                                    style: TextStyle(
                                      color: redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Optional top border curve effect matching the design
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 20),
                        painter: BottomRedLinePainter(color: redAccent),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'First Name ',
                                style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                                children: [TextSpan(text: '*', style: TextStyle(color: redAccent))],
                              ),
                            ),
                            const SizedBox(height: 8),
                            AuthTextField(
                              controller: _firstNameController,
                              hintText: 'First Name',
                              textCapitalization: TextCapitalization.words,
                              prefixIcon: Icons.person_outline,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                                _TitleCaseTextInputFormatter(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Name',
                              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            AuthTextField(
                              controller: _lastNameController,
                              hintText: 'Last Name',
                              textCapitalization: TextCapitalization.words,
                              prefixIcon: Icons.person_outline,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                                _TitleCaseTextInputFormatter(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Text.rich(
                    TextSpan(
                      text: 'Email ',
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                      children: [TextSpan(text: '*', style: TextStyle(color: redAccent))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Enter your email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Mobile Number (Optional)',
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _phoneController,
                    hintText: 'Enter your mobile number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Text.rich(
                    TextSpan(
                      text: 'Gender ',
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                      children: [TextSpan(text: '*', style: TextStyle(color: redAccent))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = 'Male'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedGender == 'Male' ? redAccent.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedGender == 'Male' ? redAccent : ThemeService.mutedColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.male, color: _selectedGender == 'Male' ? redAccent : ThemeService.mutedColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Male',
                                  style: TextStyle(
                                    color: _selectedGender == 'Male' ? redAccent : textColor,
                                    fontWeight: _selectedGender == 'Male' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = 'Female'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedGender == 'Female' ? redAccent.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedGender == 'Female' ? redAccent : ThemeService.mutedColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.female, color: _selectedGender == 'Female' ? redAccent : ThemeService.mutedColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Female',
                                  style: TextStyle(
                                    color: _selectedGender == 'Female' ? redAccent : textColor,
                                    fontWeight: _selectedGender == 'Female' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Text.rich(
                    TextSpan(
                      text: 'Password ',
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                      children: [TextSpan(text: '*', style: TextStyle(color: redAccent))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Create a password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    onChanged: _validatePassword,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ThemeService.isDarkMode ? Colors.black26 : const Color(0xFFF0F4F8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: ThemeService.textColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline, color: redAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _passwordError!,
                              style: TextStyle(color: redAccent, fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  Text.rich(
                    TextSpan(
                      text: 'Confirm Password ',
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                      children: [TextSpan(text: '*', style: TextStyle(color: redAccent))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ThemeService.isDarkMode ? Colors.black26 : const Color(0xFFF0F4F8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: ThemeService.textColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Terms and conditions
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreedToTerms = !_agreedToTerms;
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (val) {
                              setState(() {
                                _agreedToTerms = val ?? false;
                              });
                            },
                            activeColor: redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: ThemeService.mutedColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: textColor, fontSize: 12),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(color: redAccent, fontWeight: FontWeight.bold),
                                  recognizer: _termsRecognizer,
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(color: redAccent, fontWeight: FontWeight.bold),
                                  recognizer: _privacyRecognizer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final firstName = _firstNameController.text.trim();
                        final lastName = _lastNameController.text.trim();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;
                        final confirmPassword = _confirmPasswordController.text;
                        
                        if (!_agreedToTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please agree to the Terms & Conditions.')),
                          );
                          return;
                        }
                        
                        if (firstName.isEmpty || email.isEmpty || password.isEmpty) return;
                        if (_passwordError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please meet the password requirements.')),
                          );
                          return;
                        }
                        if (_selectedGender == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select your gender.')),
                          );
                          return;
                        }
                        if (password != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Passwords do not match.')),
                          );
                          return;
                        }
                        
                        // Trigger initial OTP email
                        final otpSuccess = await ref.read(authProvider.notifier).resendOtp(email);
                        if (!otpSuccess && context.mounted) {
                          final errorMsg = ref.read(authProvider).error ?? 'Failed to send OTP email. Please check your address.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMsg)),
                          );
                          return;
                        }
                        
                        if (context.mounted) {
                          context.go('/otp', extra: {
                            'name': '$firstName $lastName'.trim(),
                            'email': email,
                            'password': password,
                            'gender': _selectedGender,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: ref.watch(authProvider).isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
 
                  const SizedBox(height: 32),
                  
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: ThemeService.mutedColor,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/signin');
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);
    
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 15);
    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy, 
      firstEndPoint.dx, firstEndPoint.dy
    );
    
    var secondControlPoint = Offset(size.width - (size.width / 4), size.height - 30);
    var secondEndPoint = Offset(size.width, size.height - 5);
    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy, 
      secondEndPoint.dx, secondEndPoint.dy
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomRedLinePainter extends CustomPainter {
  final Color color;
  
  BottomRedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path = Path();
    path.moveTo(0, size.height - 25);
    
    var firstControlPoint = Offset(size.width / 4, size.height + 5);
    var firstEndPoint = Offset(size.width / 2, size.height - 10);
    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy, 
      firstEndPoint.dx, firstEndPoint.dy
    );
    
    var secondControlPoint = Offset(size.width - (size.width / 4), size.height - 25);
    var secondEndPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy, 
      secondEndPoint.dx, secondEndPoint.dy
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _TitleCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    String newText = '';
    for (int i = 0; i < newValue.text.length; i++) {
      if (i == 0 || newValue.text[i - 1] == ' ') {
        newText += newValue.text[i].toUpperCase();
      } else {
        newText += newValue.text[i];
      }
    }
    
    return TextEditingValue(
      text: newText,
      selection: newValue.selection,
    );
  }
}
