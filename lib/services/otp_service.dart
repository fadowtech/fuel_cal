import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class OtpService {
  static final Map<String, String> _otpCache = {};

  static Future<bool> sendOtpEmail(String recipientEmail) async {
    try {
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

      // Store in memory
      _otpCache[recipientEmail] = otp;

      // Construct email
      final message = Message()
        ..from = const Address('fadownoreply@gmail.com', 'FuelVox Support')
        ..recipients.add(recipientEmail)
        ..subject = 'Your Verification Code'
        ..html = '''
          <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
            <h2 style="color: #DE2425;">Verification Code</h2>
            <p>Thank you for signing up! Please use the following code to verify your email address:</p>
            <div style="background-color: #f4f4f4; padding: 15px; border-radius: 8px; text-align: center; margin: 20px 0;">
              <h1 style="letter-spacing: 5px; margin: 0; color: #333;">$otp</h1>
            </div>
            <p style="color: #888; font-size: 12px; margin-top: 40px;">If you didn't request this, you can safely ignore this email.</p>
          </div>
        ''';

      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('SMTP Error: $e');
      return false;
    }
  }

  static bool verifyOtp(String email, String enteredOtp) {
    if (_otpCache.containsKey(email) && _otpCache[email] == enteredOtp) {
      _otpCache.remove(email); // One-time use
      return true;
    }
    return false;
  }
}
