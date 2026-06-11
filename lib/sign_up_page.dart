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
              '''Welcome to Fuelvox!

1. Acceptance of Terms
By creating an account and using Fuelvox, you agree to comply with and be bound by these Terms & Conditions. If you do not agree to these terms, please do not use the app.

2. Description of Service
Fuelvox provides tools for tracking vehicle mileage, logging fuel expenses, and setting maintenance reminders. All calculations and statistics are estimates based on user-provided data. We do not guarantee the absolute accuracy of these estimates.

3. In-App Purchases & Subscriptions
Certain features, such as an ad-free experience, are available via auto-renewing subscriptions or one-time in-app purchases. Payments are processed securely through the Google Play Store. Subscriptions automatically renew unless canceled in your Google Play account settings.

4. Advertisements
The free version of Fuelvox displays banner advertisements provided by Google AdMob. By using the free version, you agree to the display of these ads.

5. User Accounts
You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account. 

6. Limitation of Liability
Fuelvox and its developers shall not be liable for any indirect, incidental, or consequential damages resulting from the use or inability to use the app, including any loss of data.''',
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
              '''At Fuelvox, your privacy is our priority. This policy outlines how we handle your data.

1. Information We Collect
• Personal Data: When you sign up, we collect your name, email address, and optionally your phone number and gender.
• Vehicle & Usage Data: We collect the vehicle details, fuel logs, and expense records you manually enter into the app to provide you with insights.

2. How We Use Your Data
We use your data strictly to operate and improve the Fuelvox service, sync your data across devices, and authenticate your account. We do not sell your personal data to third parties.

3. Third-Party Services
We use trusted third-party services that may collect information used to identify you:
• Google AdMob: Used to serve advertisements in the free version. AdMob may use advertising IDs and cookies to serve personalized ads based on your interests, in accordance with Google's Privacy & Terms.
• RevenueCat: Used to manage in-app subscriptions securely.

4. Data Security & Retention
Your data is stored securely. We retain your information as long as your account is active.

5. Your Rights
You have the right to access, modify, or permanently delete your account and all associated data at any time from within the app settings.

6. Changes to This Policy
We may update our Privacy Policy periodically. We will notify you of any changes by updating this page.''',
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
                            Text(
                              'First Name',
                              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
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
                  
                  Text(
                    'Email',
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
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
                  
                  Text(
                    'Gender',
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
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
                  
                  Text(
                    'Password',
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Create a password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: ThemeService.mutedColor,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Confirm Password',
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: ThemeService.mutedColor,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
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
