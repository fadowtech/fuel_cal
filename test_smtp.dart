import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  print('Testing Zoho SMTP .in...');
  try {
    final smtpServer = SmtpServer(
      'smtp.zoho.in',
      port: 465,
      ssl: true,
      username: 'fuelvox@fadowtech.com',
      password: 'f5AP0PRE5e0Q',
    );

    final message = Message()
      ..from = const Address('fuelvox@fadowtech.com', 'FuelVox Support')
      ..recipients.add('fuelvox@fadowtech.com') // Send to self
      ..subject = 'Test Mail'
      ..text = 'This is a test mail.';

    final sendReport = await send(message, smtpServer);
    print('Message sent! .in Success!');
  } catch (e) {
    print('Failed with .in: $e');
  }

  print('Testing Zoho SMTP .com...');
  try {
    final smtpServerCom = SmtpServer(
      'smtp.zoho.com',
      port: 465,
      ssl: true,
      username: 'fuelvox@fadowtech.com',
      password: 'f5AP0PRE5e0Q',
    );

    final messageCom = Message()
      ..from = const Address('fuelvox@fadowtech.com', 'FuelVox Support')
      ..recipients.add('fuelvox@fadowtech.com')
      ..subject = 'Test Mail'
      ..text = 'This is a test mail.';

    final sendReportCom = await send(messageCom, smtpServerCom);
    print('Message sent! .com Success!');
  } catch (e) {
    print('Failed with .com: $e');
  }
}
