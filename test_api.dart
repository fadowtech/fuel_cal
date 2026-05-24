import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  // 1. Signup
  final req = await client.postUrl(Uri.parse('http://184.174.37.4:8001/auth/signup'));
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode({
    'full_name': 'Test User API',
    'email': 'testuser12345@test.com',
    'password': 'password',
    'currency_code': 'USD'
  }));
  await req.close();

  // 2. Login
  final loginReq = await client.postUrl(Uri.parse('http://184.174.37.4:8001/auth/login'));
  loginReq.headers.contentType = ContentType.json;
  loginReq.write(jsonEncode({
    'email': 'testuser12345@test.com',
    'password': 'password'
  }));
  final loginRes = await loginReq.close();
  final loginBody = await loginRes.transform(utf8.decoder).join();
  print('LOGIN RESPONSE: $loginBody');
  
  final token = jsonDecode(loginBody)['access_token'];

  // 3. Try /users/me
  final meReq = await client.getUrl(Uri.parse('http://184.174.37.4:8001/users/me'));
  meReq.headers.add('Authorization', 'Bearer $token');
  final meRes = await meReq.close();
  final meBody = await meRes.transform(utf8.decoder).join();
  print('USERS ME RESPONSE: $meBody');

  client.close();
}
