import 'dart:math';
import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OtpService {
  // Store both the OTP and its expiration time
  static final Map<String, Map<String, dynamic>> _otpCache = {};
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> sendOtpEmail(String recipientEmail, {bool isPasswordReset = false}) async {
    try {
      final String limitKey = isPasswordReset ? 'otp_limits_reset_$recipientEmail' : 'otp_limits_verify_$recipientEmail';
      final int maxPerHr = isPasswordReset ? 4 : 5;
      
      final String? historyJson = await _storage.read(key: limitKey);
      List<int> timestamps = [];
      if (historyJson != null) {
        try {
          timestamps = List<int>.from(jsonDecode(historyJson));
        } catch (_) {}
      }
      
      final int now = DateTime.now().millisecondsSinceEpoch;
      final int oneHourAgo = now - (60 * 60 * 1000);
      timestamps.removeWhere((ts) => ts < oneHourAgo);
      
      if (timestamps.length >= maxPerHr) {
        throw Exception(isPasswordReset ? 'Too many password reset requests. Please try again in 1 hour.' : 'Too many verification emails sent. Please try again in 1 hour.');
      }

      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 465,
        ssl: true,
        username: 'fadownoreply@gmail.com',
        password: 'klkgsgeufxycylwr',
      );

      // Generate 6-digit OTP
      final rnd = Random();
      final otp = (100000 + rnd.nextInt(900000)).toString();

      // Store in memory with 5-minute expiration
      _otpCache[recipientEmail] = {
        'otp': otp,
        'expiry': DateTime.now().add(const Duration(minutes: 5)),
      };

      final titleText = isPasswordReset ? "Account Password Recovery" : "Welcome to FuelVox!";
      final subtitleText = isPasswordReset ? "Password Reset" : "Account Verification";
      final actionText = isPasswordReset 
          ? "No worries! Use the verification code below<br>to reset your password."
          : "You're almost ready to get started. Enter the verification code below.";
      
      final securityContextText = isPasswordReset 
          ? "If you didn't request this password reset, you can safely ignore this email."
          : "For your security, never share this verification code with anyone. If you didn't create a FuelVox account, you can safely ignore this email.";
          
      final footerContent = isPasswordReset
          ? "<p style=\"color: #888888; font-size: 12px; margin: 0;\">Thank you for using FuelVox!</p>"
          : '''
            <p style="color: #666666; font-size: 13px; margin: 0 0 8px 0; font-weight: 500;">Thank you for choosing FuelVox!</p>
            <p style="color: #888888; font-size: 12px; margin: 0 0 15px 0; line-height: 1.5;">Manage your fuel expenses smarter and stay in control of your vehicle costs.</p>
            <p style="color: #888888; font-size: 12px; margin: 0;">Thank you,<br><strong>FuelVox Team</strong></p>
          ''';

      String otpBoxes = '';
      for (int i = 0; i < otp.length; i++) {
        otpBoxes += '''
          <span style="display: inline-block; margin: 0 3px; background-color: #ffffff; border: 1px solid #ffeaea; border-radius: 8px; width: 36px; height: 50px; line-height: 50px; font-size: 26px; font-weight: 700; color: #DE2425; text-align: center; box-shadow: 0 2px 4px rgba(222,36,37,0.05);">
            ${otp[i]}
          </span>
        ''';
      }

      final emailSubject = isPasswordReset ? 'FuelVox: Password Reset Code' : 'FuelVox: Your Verification Code';

      final String snippetSpacer = '&#847;&zwnj;&nbsp;' * 150;

      // Construct email
      final message = Message()
        ..from = const Address('fadownoreply@gmail.com', 'FuelVox Support')
        ..recipients.add(recipientEmail)
        ..subject = emailSubject
        ..html = '''
        <div style="display: none; font-size: 1px; color: #fefefe; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden;">
          Your verification code is $otp. $snippetSpacer
        </div>
        <div style="font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 40px 20px; background-color: #ffffff;">
          
          <!-- Logo & Subtitle -->
          <div style="text-align: center; margin-bottom: 20px;">
            <h1 style="color: #DE2425; font-size: 32px; font-weight: 800; letter-spacing: -0.5px; margin: 0; padding: 0;">FuelVox</h1>
            <p style="color: #64748B; font-size: 12px; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; margin: 8px 0 0 0;">$subtitleText</p>
          </div>
          
          <div style="text-align: center; margin-bottom: 30px;">
            <h2 style="color: #0F172A; font-size: 24px; font-weight: 700; margin: 0 0 20px 0;">$titleText</h2>
            <div style="height: 3px; width: 40px; background-color: #DE2425; margin: 0 auto 20px auto; border-radius: 2px;"></div>
            <p style="color: #334155; font-size: 15px; line-height: 1.6; margin: 0;">
              $actionText
            </p>
          </div>

          <!-- Verification Code Box -->
          <div style="background-color: #fdf5f5; border: 1px solid #f9e8e8; border-radius: 12px; padding: 30px 10px; text-align: center; margin-bottom: 15px;">
            <p style="color: #DE2425; font-weight: 600; font-size: 14px; margin: 0 0 20px 0;">Your verification code</p>
            <div style="text-align: center; white-space: nowrap;">
              $otpBoxes
            </div>
          </div>
          <div style="text-align: center; margin-bottom: 35px;">
            <p style="color: #64748B; font-size: 13px; font-weight: 500; margin: 0;">
              &#128338; This code expires in 5 minutes.
            </p>
          </div>

          <!-- Security Notice -->
          <div style="background-color: #F8FAFC; border-radius: 8px; padding: 20px; margin-bottom: 30px;">
            <h3 style="color: #0F172A; font-size: 15px; font-weight: 600; margin: 0 0 10px 0;">Keeping your account secure</h3>
            <p style="color: #475569; font-size: 14px; line-height: 1.5; margin: 0;">
              For your security, never share this verification code with anyone. If you didn't request this email, you can safely ignore it.
            </p>
          </div>

          <!-- Need Help -->
          <div style="text-align: center; padding-top: 20px; border-top: 1px solid #E2E8F0;">
            <h4 style="color: #0F172A; font-size: 14px; font-weight: 600; margin: 0 0 8px 0;">Need Help?</h4>
            <p style="color: #475569; font-size: 14px; margin: 0 0 12px 0;">Our support team is here for you.</p>
            <a href="mailto:support@fuelvox.app" style="color: #DE2425; font-size: 14px; font-weight: 600; text-decoration: none;">&#128231; support@fuelvox.app</a>
          </div>
          
          <!-- Footer -->
          <div style="text-align: center; margin-top: 40px;">
            $footerContent
          </div>
          
          <div style="display: none; font-size: 1px; color: transparent; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden;">
            <br><br><br>Ref: ${DateTime.now().millisecondsSinceEpoch}
          </div>
        </div>
        ''';

      await send(message, smtpServer);
      
      timestamps.add(now);
      await _storage.write(key: limitKey, value: jsonEncode(timestamps));
      
      return true;
    } catch (e) {
      if (e.toString().contains('Too many')) {
        rethrow;
      }
      print('SMTP Error: $e');
      return false;
    }
  }

  static bool verifyOtp(String email, String enteredOtp) {
    if (_otpCache.containsKey(email)) {
      final cacheEntry = _otpCache[email]!;
      final storedOtp = cacheEntry['otp'] as String;
      final expiryTime = cacheEntry['expiry'] as DateTime;

      if (DateTime.now().isBefore(expiryTime) && storedOtp == enteredOtp) {
        _otpCache.remove(email); // One-time use
        return true;
      } else {
        // Expired or wrong code
        if (DateTime.now().isAfter(expiryTime)) {
          _otpCache.remove(email); // Clean up expired OTP
        }
      }
    }
    return false;
  }
}
