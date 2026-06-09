import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  try {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: 'fadownoreply@gmail.com',
      password: 'klkgsgeufxycylwr',
    );

    final message = Message()
      ..from = const Address('fadownoreply@gmail.com', 'FuelVox Support')
      ..recipients.add('emishperraj@gmail.com')
      ..subject = 'Test SMTP'
      ..text = 'Test message';

    print('Sending email...');
    await send(message, smtpServer);
    print('Email sent successfully!');
  } catch (e) {
    print('SMTP Error: $e');
  }
}
