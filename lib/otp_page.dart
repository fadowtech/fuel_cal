import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fuel_cal/services/theme_service.dart';
import 'package:fuel_cal/providers/auth_provider.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String email;
  final String name;
  final String password;
  final String gender;
  final bool isResetPassword;
  
  const OtpPage({
    Key? key, 
    required this.email, 
    this.name = '', 
    this.password = '',
    this.gender = '',
    this.isResetPassword = false,
  }) : super(key: key);

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      }
    });
  }

  void _verifyOtp() async {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit OTP.')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(widget.email, otp);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please check your email.')),
      );
    } else if (success && mounted) {
      if (widget.isResetPassword) {
        context.go('/reset_password', extra: {'email': widget.email});
      } else {
        final signupSuccess = await ref.read(authProvider.notifier).signup(widget.name, widget.email, widget.password, gender: widget.gender);
        if (signupSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification successful! Please sign in.')),
          );
          context.go('/signin');
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup failed after verification. Please try again.')),
          );
        }
      }
    }
  }

  void _resendOtp() async {
    if (!_canResend) return;
    
    final success = await ref.read(authProvider.notifier).resendOtp(widget.email, isPasswordReset: widget.isResetPassword);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully!')),
      );
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeService.isDarkMode;
    final Color bgColor = isDark ? const Color(0xFF121217) : const Color(0xFFF9FAFB);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color redAccent = const Color(0xFFDE2425);
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.go('/signin'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Verify your account',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: ThemeService.mutedColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit verification code to\n'),
                    TextSpan(
                      text: widget.email,
                      style: TextStyle(
                        color: redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // OTP Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: redAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: redAccent.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Code sent to your email id',
                      style: TextStyle(
                        color: redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 44,
                          height: 56,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: redAccent,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              counterText: '',
                              filled: true,
                              fillColor: isDark ? ThemeService.surfaceColor : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: redAccent.withOpacity(0.3), width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: redAccent.withOpacity(0.3), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: redAccent, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  _focusNodes[index].unfocus();
                                }
                              } else {
                                if (index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Expiration Notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: redAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, color: redAccent, size: 20),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: ThemeService.mutedColor,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: 'Your code will expire in '),
                          TextSpan(
                            text: '5 minutes.',
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
              
              const SizedBox(height: 40),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend Text
              Center(
                child: GestureDetector(
                  onTap: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend 
                        ? 'Resend OTP' 
                        : 'Resend code in $_resendCountdown s',
                    style: TextStyle(
                      color: _canResend ? redAccent : ThemeService.mutedColor,
                      fontSize: 14,
                      fontWeight: _canResend ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
